"""Check local page, fragment and asset targets in the static HTML export."""
from html.parser import HTMLParser
import argparse
import json
from pathlib import Path
from urllib.parse import unquote, urlsplit
import yaml

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_build" / "html"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--base-url", default="", help="Deployment subpath, e.g. /MicrobialML")
base_url = parser.parse_args().base_url.rstrip("/")
assert not base_url or base_url.startswith("/"), "Use a root-relative base URL"


class Page(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.links = []
        self.ids = set()
        self.feed(source)

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        if "id" in attributes:
            self.ids.add(attributes["id"])
        for name in ("href", "src"):
            if attributes.get(name):
                self.links.append(attributes[name])


pages = {p.resolve(): Page(p.read_text()) for p in SITE.rglob("*.html")}
def toc_files(entries):
    return sum((1 if "file" in entry else 0) + toc_files(entry.get("children", [])) for entry in entries)
expected_pages = toc_files(yaml.safe_load((ROOT / "myst.yml").read_text())["project"]["toc"])
assert len(pages) == expected_pages, f"Expected {expected_pages} book pages, found {len(pages)}"
failures = []
checked = 0
for path, page in pages.items():
    for link in page.links:
        url = urlsplit(link)
        if url.scheme or url.netloc:
            continue
        target_path = unquote(url.path)
        if base_url and target_path.startswith("/"):
            if target_path == base_url or target_path.startswith(base_url + "/"):
                target_path = target_path[len(base_url):] or "/"
            else:
                failures.append(f"Local URL outside deployment subpath: {link}")
        if not target_path:
            target = path
        elif target_path.startswith("/"):
            target = SITE / target_path.lstrip("/")
        else:
            target = path.parent / target_path
        target = target.resolve()
        if target.is_dir():
            target /= "index.html"
        if not target.exists() and not target.suffix:
            target /= "index.html"
        checked += 1
        if not target.is_file():
            failures.append(f"{path.relative_to(SITE.resolve())}: {link}")
        elif url.fragment and target in pages:
            if unquote(url.fragment) not in pages[target].ids:
                failures.append(f"Missing fragment: {link} in {path.name}")

report = {
    "html_pages": len(pages),
    "base_url": base_url,
    "local_link_and_asset_references_checked": checked,
    "missing_local_targets_or_fragments": failures,
    "external_links_checked_by_this_script": False,
}
(ROOT / "validation" / "html-check.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report, indent=2))
assert not failures, "Broken local targets; see validation/html-check.json"
