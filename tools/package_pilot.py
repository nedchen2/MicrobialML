"""Package only this book's public sources and built HTML, plus separate TA notes."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
FILES = [".gitignore", "myst.yml", "intro.md", "README.md", "STUDENT_README.txt",
         "microbial-ml.Rproj", "requirements-build.txt", "preview.command",
         "PUBLICATION.md", "CHANGELOG.md"]
DIRECTORIES = ["assets", "authoring", "chapters", "reference", "scripts", "tools",
               "downloads", "validation", ".github"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path,
                        default=ROOT.parent / "output/JupyterBook_MicrobialML_Pilot.zip")
    args = parser.parse_args()
    sources = [ROOT / name for name in FILES]
    for name in DIRECTORIES:
        sources.extend(p for p in (ROOT / name).rglob("*") if p.is_file()
                       and "__pycache__" not in p.parts and p.suffix != ".pyc")
    sources += [ROOT / "data/practice_counts.csv", ROOT / "data/data-dictionary.csv"]
    html = ROOT / "_build/html"
    assert (html / "index.html").is_file(), "Build the HTML before packaging."
    sources.extend(p for p in html.rglob("*") if p.is_file())
    sources = sorted(set(sources))
    assert all(p.is_file() for p in sources)
    assert not any("data/raw" in p.relative_to(ROOT).as_posix() for p in sources)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(args.output, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as bundle:
        for source in sources:
            bundle.write(source, ROOT.name + "/" + source.relative_to(ROOT).as_posix())
        # These files sit outside the public book root, also inside the bundle.
        for name in ["PILOT_REVIEW.md", "COURSE_PLAN.md"]:
            note = ROOT.parent / "teaching_plan" / name
            if note.is_file():
                bundle.write(note, "TA-notes/" + name)
    with zipfile.ZipFile(args.output) as bundle:
        assert bundle.testzip() is None
        count = len(bundle.namelist())
    report = {"bundle": str(args.output), "entries": count,
              "bytes": args.output.stat().st_size,
              "sha256": hashlib.sha256(args.output.read_bytes()).hexdigest(),
              "complete_raw_dataset_included": False,
              "author_environment_directories_included": False}
    args.output.with_suffix(".manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
