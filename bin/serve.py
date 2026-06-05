#!/usr/bin/env python3
"""Debate Arena dashboard server (stdlib only).

Serves the arena root over HTTP (like python3 -m http.server) plus ONE write
endpoint used by the dashboard's Human inbox composer:

    POST /api/inbox?debate=<slug>      body: {"text": "...", "directive": true|false}

Append-only into debates/<slug>/human/INBOX.md — the only file the human owns
in the protocol. Binds to 127.0.0.1 only. Slug is strictly validated.
"""
import json
import re
import sys
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, parse_qs

ROOT = Path(__file__).resolve().parent.parent
SLUG_RE = re.compile(r"^[A-Za-z0-9._-]{1,128}$")


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

    def do_POST(self):
        url = urlparse(self.path)
        if url.path != "/api/inbox":
            return self._json(404, {"ok": False, "error": "unknown endpoint"})

        slug = (parse_qs(url.query).get("debate") or [""])[0]
        if not SLUG_RE.match(slug):
            return self._json(400, {"ok": False, "error": "bad debate slug"})
        inbox = ROOT / "debates" / slug / "human" / "INBOX.md"
        if not inbox.parent.is_dir():
            return self._json(404, {"ok": False, "error": "no such debate"})

        try:
            n = int(self.headers.get("Content-Length") or 0)
            if not 0 < n <= 20000:
                return self._json(413, {"ok": False, "error": "bad payload size"})
            data = json.loads(self.rfile.read(n))
            text = str(data.get("text", "")).replace("\r", "").strip()
            directive = bool(data.get("directive"))
        except Exception:
            return self._json(400, {"ok": False, "error": "bad JSON"})
        if not text:
            return self._json(400, {"ok": False, "error": "empty note"})

        # Protocol grammar: binding lines must START with "DIRECTIVE: ".
        stamp = datetime.now().strftime("%Y-%m-%d %H:%M")
        lines = text.split("\n")
        first = ("DIRECTIVE: " if directive else "") + lines[0]
        entry = f"\n{first} (via dashboard {stamp})"
        entry += "".join("\n" + l for l in lines[1:])
        entry += "\n"
        with open(inbox, "a", encoding="utf-8") as f:
            f.write(entry)
        return self._json(200, {"ok": True})


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
