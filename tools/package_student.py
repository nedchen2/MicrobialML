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
             ROOT / "data/practice_counts.csv", ROOT / "data/practice_farms.csv", ROOT / "data/data-dictionary.csv",
             ROOT / "data/predictor-dictionary.csv"]
    files += [ROOT / "scripts" / f"{name}.R" for name in [*LESSONS, "worked-example", "course_setup",
                                                           "tree-workflow", "tree_helpers", "full-analysis"]]
    files += sorted((ROOT / "templates").glob("*.txt"))
    with zipfile.ZipFile(target / "microbial-ml-student.zip", "w", zipfile.ZIP_DEFLATED) as z:
        for path in files:
            z.write(path, Path("microbial-ml") / path.relative_to(ROOT))
    for old, new in [("test-scores.csv", "tree-scores.csv"), ("validation-scores.csv", "tree-validation.csv"),
                     ("predictor-audit.csv", "predictor-audit.csv")]:
        shutil.copyfile(ROOT / "outputs/tree" / old, target / new)
    print(f"Packaged student project: {len(files)} files; base R plus rpart for trees; no complete raw dataset")


if __name__ == "__main__":
    package()
