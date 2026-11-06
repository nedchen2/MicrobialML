"""Reject files outside this textbook's explicit public-source boundary."""
from pathlib import Path, PurePosixPath
import subprocess

ROOT = Path(__file__).resolve().parents[1]
root_files = {".gitignore", "README.md", "STUDENT_README.txt", "myst.yml",
              "intro.md", "microbial-ml.Rproj", "requirements-build.txt",
              "preview.command", "PUBLICATION.md", "CHANGELOG.md"}
extensions = {"assets": {".svg", ".css"}, "authoring": {".md"},
              "chapters": {".md", ".ipynb"}, "reference": {".md"},
              "scripts": {".R"}, "tools": {".py"}}
exact_paths = {"data/practice_counts.csv", "data/data-dictionary.csv",
               "downloads/baseline-scores.csv", "downloads/data-audit.csv",
               ".github/workflows/deploy.yml"}
files = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
files = [file for file in files if file]
assert files, "No public source files found in the Git index"
unexpected = []
for name in files:
    path = PurePosixPath(name)
    allowed = name in root_files or name in exact_paths
    if len(path.parts) == 2 and path.parts[0] in extensions:
        allowed = path.suffix in extensions[path.parts[0]]
    if not allowed:
        unexpected.append(name)
assert not unexpected, "Unreviewed public paths: " + ", ".join(unexpected)
print(f"Checked {len(files)} public source files; no raw cache, environment, TA notes or unrelated documents.")
