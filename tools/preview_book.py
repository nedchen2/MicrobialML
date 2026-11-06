"""Serve the already-built book on this computer, without build dependencies."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    site = Path(__file__).resolve().parents[1] / "_build" / "html"
    if not (site / "index.html").is_file():
        parser.error("Built HTML is missing. Extract the complete pilot bundle or build the book first.")
    handler = partial(SimpleHTTPRequestHandler, directory=str(site))
    try:
        server = ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    except OSError as error:
        parser.exit(1, f"Cannot start preview: {error}. Close the earlier server or use --port 8766.\n")
    print(f"Open http://127.0.0.1:{args.port}/ in your browser.", flush=True)
    print("Keep this terminal open. Press Ctrl+C to stop.", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nPreview stopped.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
