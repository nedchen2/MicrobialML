"""Package a minimal R-only student project, without redistributing raw source data."""
from pathlib import Path
import shutil
import zipfile
from assemble_notebooks import LESSONS

ROOT = Path(__file__).resolve().parents[1]


def package():
    target = ROOT / "downloads"
    target.mkdir(exist_ok=True)
    source = ROOT / "outputs" / "baseline"
    for old, new in [("scores.csv", "baseline-scores.csv"), ("data-audit.csv", "data-audit.csv")]:
        shutil.copyfile(source / old, target / new)
    files = [ROOT / "microbial-ml.Rproj", ROOT / "STUDENT_README.txt",
             ROOT / "data/practice_counts.csv", ROOT / "data/practice_farms.csv", ROOT / "data/data-dictionary.csv"]
    files += [ROOT / "scripts" / f"{name}.R" for name in [*LESSONS, "worked-example", "course_setup"]]
    files += sorted((ROOT / "templates").glob("*.txt"))
    with zipfile.ZipFile(target / "microbial-ml-student.zip", "w", zipfile.ZIP_DEFLATED) as z:
        for path in files:
            z.write(path, Path("microbial-ml") / path.relative_to(ROOT))
    print(f"Packaged student project: {len(files)} files, base R only, no complete raw dataset")


if __name__ == "__main__":
    package()
