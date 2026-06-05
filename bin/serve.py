#!/usr/bin/env python3
"""Debate Arena dashboard server (stdlib only, localhost only).

Static serving of the arena root plus a small JSON API used by the dashboard:

  GET  /api/debates                  list debates with phase/status
  POST /api/inbox?debate=<slug>      {"text","directive"}  append to human/INBOX.md
  POST /api/validate-path            {"path"}              existence check for wizard
  POST /api/debates                  {"slug","config_md","run_conf"}  scaffold debate
  POST /api/launch                   {"slug"}              fire-and-forget run-debate.sh
"""
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, parse_qs

ROOT = Path(__file__).resolve().parent.parent
SLUG_RE = re.compile(r"^[A-Za-z0-9._-]{1,128}$")

STATE_INIT = """# DEBATE STATE — single writer: MODERATOR
phase: 0
phase_name: setup
status: awaiting-moderator
awaiting_files:
  - exchange/P0-M-brief.md
notes_for_participants: Debate not started. Moderator boots first.
extension_phases_used: 0 of 5
gate_log: []
"""

INBOX_INIT = """# HUMAN INBOX
Drop notes here anytime; the moderator reads this at every gate.
Prefix a line with `DIRECTIVE:` to make it binding. Anything else is advisory.
"""

EXCHANGE_README = """Debate artifacts land here as P<phase>-<ROLE>-<slug>.md (see ../PROTOCOL.md §3).
A file is delivered only when its last line is `<!-- END <ROLE> P<phase> -->`.
"""


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def log_message(self, *args):  # keep the pane quiet
        pass

    def _json(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _body(self, limit=200000):
        n = int(self.headers.get("Content-Length") or 0)
        if not 0 < n <= limit:
            raise ValueError("bad payload size")
        return json.loads(self.rfile.read(n))

    # ── GET ──────────────────────────────────────────────────────────────
    def do_GET(self):
        if urlparse(self.path).path == "/api/debates":
            return self._list_debates()
        return super().do_GET()

    def _list_debates(self):
        out = []
        droot = ROOT / "debates"
        if droot.is_dir():
            for p in sorted(droot.iterdir()):
                if not (p / "DEBATE-CONFIG.md").is_file():
                    continue
                phase, status = "?", "not initialized"
                st = p / "STATE.md"
                if st.is_file():
                    t = st.read_text(encoding="utf-8", errors="replace")
                    m = re.search(r"^phase:\s*(\d+)", t, re.M)
                    s = re.search(r"^status:\s*(\S+)", t, re.M)
                    phase = m.group(1) if m else "?"
                    status = s.group(1) if s else "?"
                out.append({
                    "slug": p.name, "phase": phase, "status": status,
                    "final": (p / "output" / "UNIFIED-VISION.md").is_file(),
                })
        return self._json(200, {"ok": True, "debates": out})

    # ── POST ─────────────────────────────────────────────────────────────
    def do_POST(self):
        path = urlparse(self.path).path
        try:
            if path == "/api/inbox":
                return self._post_inbox()
            if path == "/api/validate-path":
                return self._post_validate()
            if path == "/api/debates":
                return self._post_create()
            if path == "/api/launch":
                return self._post_launch()
            return self._json(404, {"ok": False, "error": "unknown endpoint"})
        except ValueError as e:
            return self._json(400, {"ok": False, "error": str(e)})
        except Exception as e:  # noqa: BLE001 — surface to the UI
            return self._json(500, {"ok": False, "error": f"{type(e).__name__}: {e}"})

    def _post_inbox(self):
        slug = (parse_qs(urlparse(self.path).query).get("debate") or [""])[0]
        if not SLUG_RE.match(slug):
            return self._json(400, {"ok": False, "error": "bad debate slug"})
        inbox = ROOT / "debates" / slug / "human" / "INBOX.md"
        if not inbox.parent.is_dir():
            return self._json(404, {"ok": False, "error": "no such debate"})
        data = self._body(20000)
        text = str(data.get("text", "")).replace("\r", "").strip()
        directive = bool(data.get("directive"))
        if not text:
            return self._json(400, {"ok": False, "error": "empty note"})
        stamp = datetime.now().strftime("%Y-%m-%d %H:%M")
        lines = text.split("\n")
        first = ("DIRECTIVE: " if directive else "") + lines[0]
        entry = f"\n{first} (via dashboard {stamp})" + "".join("\n" + l for l in lines[1:]) + "\n"
        with open(inbox, "a", encoding="utf-8") as f:
            f.write(entry)
        return self._json(200, {"ok": True})

    def _post_validate(self):
        p = str(self._body().get("path", "")).strip()
        if not p.startswith("/"):
            return self._json(200, {"ok": True, "exists": False, "note": "must be an absolute path"})
        path = Path(p)
        if not path.exists():
            return self._json(200, {"ok": True, "exists": False})
        if path.is_dir():
            n = 0
            for f in path.rglob("*"):
                if f.is_file():
                    n += 1
                    if n >= 500:
                        break
            return self._json(200, {"ok": True, "exists": True, "type": "dir",
                                    "files": ("500+" if n >= 500 else n)})
        return self._json(200, {"ok": True, "exists": True, "type": "file",
                                "size": path.stat().st_size})

    def _post_create(self):
        data = self._body()
        slug = str(data.get("slug", ""))
        config_md = str(data.get("config_md", ""))
        run_conf = str(data.get("run_conf", ""))
        if not SLUG_RE.match(slug):
            return self._json(400, {"ok": False, "error": "bad slug (use letters/digits/._-)"})
        if not config_md.strip() or not run_conf.strip():
            return self._json(400, {"ok": False, "error": "missing config_md or run_conf"})
        d = ROOT / "debates" / slug
        if d.exists():
            return self._json(409, {"ok": False, "error": f"debate '{slug}' already exists"})
        for req in [ROOT / "PROTOCOL.md", ROOT / "prompts"]:
            if not req.exists():
                return self._json(500, {"ok": False, "error": f"arena missing {req.name}"})
        (d / "exchange").mkdir(parents=True)
        (d / "human").mkdir()
        (d / "output").mkdir()
        (d / "prompts").mkdir()
        shutil.copy(ROOT / "PROTOCOL.md", d / "PROTOCOL.md")
        for f in (ROOT / "prompts").glob("START-*.md"):
            shutil.copy(f, d / "prompts" / f.name)
        (d / "STATE.md").write_text(STATE_INIT, encoding="utf-8")
        (d / "human" / "INBOX.md").write_text(INBOX_INIT, encoding="utf-8")
        (d / "exchange" / "README.md").write_text(EXCHANGE_README, encoding="utf-8")
        (d / "DEBATE-CONFIG.md").write_text(config_md, encoding="utf-8")
        (d / "run.conf").write_text(run_conf, encoding="utf-8")
        return self._json(200, {"ok": True, "slug": slug})

    def _post_launch(self):
        slug = str(self._body().get("slug", ""))
        if not SLUG_RE.match(slug):
            return self._json(400, {"ok": False, "error": "bad slug"})
        d = ROOT / "debates" / slug
        if not (d / "run.conf").is_file():
            return self._json(404, {"ok": False, "error": "no such debate / no run.conf"})
        subprocess.Popen(
            ["bash", str(ROOT / "bin" / "run-debate.sh"), slug],
            cwd=str(ROOT), stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        tmux = shutil.which("tmux") is not None
        return self._json(200, {
            "ok": True, "tmux": tmux,
            "note": (f"tmux session starting — attach with: tmux attach -t debate-{slug}"
                     if tmux else "Terminal windows are opening (macOS)"),
        })


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8787
    srv = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"Debate Arena server on http://localhost:{port}  (root: {ROOT})")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
