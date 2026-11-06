"""Check the actual student ZIP and independently verify the R baseline arithmetic."""
from pathlib import Path
import argparse
import csv
import hashlib
import json
import math
import shutil
import statistics
import subprocess
import tempfile
import zipfile

import nbformat
from assemble_notebooks import LESSONS, read_cells

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def main(cold):
    executed = 0
    for name in LESSONS:
        notebook = nbformat.read(ROOT / "chapters" / f"{name}.ipynb", as_version=4)
        code = [cell for cell in notebook.cells if cell.cell_type == "code"]
        canonical = list(read_cells(ROOT / "scripts" / f"{name}.R").values())
        assert [cell.source for cell in code] == canonical
        assert all(cell.execution_count is not None for cell in code)
        assert not any(out.output_type == "error" for cell in code for out in cell.outputs)
        executed += len(code)
    zip_path = ROOT / "downloads/microbial-ml-student.zip"
    with tempfile.TemporaryDirectory(prefix="microbial-ml-student-") as work:
        with zipfile.ZipFile(zip_path) as z:
            assert z.testzip() is None
            assert not any("/data/raw/" in p for p in z.namelist())
            z.extractall(work)
        project = Path(work) / "microbial-ml"
        if not cold:
            (project / "data/raw").mkdir(parents=True)
            shutil.copyfile(ROOT / "data/raw/Raw_Milk_Micro_Data.csv", project / "data/raw/Raw_Milk_Micro_Data.csv")
        for name in LESSONS:
            result = subprocess.run(["Rscript", "--vanilla", "scripts/"+name+".R"], cwd=project,
                                    text=True, capture_output=True, timeout=180)
            if result.returncode:
                raise AssertionError(result.stdout + result.stderr)
        first = (project / "outputs/baseline/scores.csv").read_bytes()
        subprocess.run(["Rscript", "--vanilla", "scripts/worked-example.R"], cwd=project,
                       check=True, text=True, capture_output=True, timeout=120)
        assert (project / "outputs/baseline/scores.csv").read_bytes() == first
        assert (ROOT / "outputs/baseline/scores.csv").read_bytes() == first
        source = project / "data/raw/Raw_Milk_Micro_Data.csv"
        assert hashlib.md5(source.read_bytes()).hexdigest() == "66057392dd1c31f6be47ec0c75ee2cb4"
        rows = read(source)
        msc = [r for r in rows if r["Test"] == "MSC"]
        eligible = [r for r in msc if r["Notes"].strip() in ["", "NA"] and
                    math.isfinite(float(r["Conc"])) and float(r["Conc"]) > 0]
        assignments = {r["FarmID"]: r["split"] for r in read(project / "outputs/baseline/farm-split.csv")}
        training = [math.log10(float(r["Conc"])) for r in eligible if assignments[r["FarmID"]] == "train"]
        testing = [math.log10(float(r["Conc"])) for r in eligible if assignments[r["FarmID"]] == "test"]
        mean = statistics.mean(training)
        rmse = math.sqrt(statistics.mean((y-mean)**2 for y in testing))
        mae = statistics.mean(abs(y-mean) for y in testing)
        r_score = read(project / "outputs/baseline/scores.csv")[0]
        for independent, column in [(mean, "training_mean_log10"), (rmse, "RMSE_log10_CFU_ml"), (mae, "MAE_log10_CFU_ml")]:
            assert math.isclose(independent, float(r_score[column]), abs_tol=1e-12)
        assert len(rows) == 2736 and len(msc) == 562 and len(eligible) == 525
        assert len(training) == 420 and len(testing) == 105
        assert sum(float(r["Conc"]) == .125 for r in eligible) == 30
        assert len(set(r["FarmID"] for r in eligible)) == 102
        assert len({(r["FarmID"], r["Sampling"]) for r in eligible}) == 525
    info = {"canonical_R_cells_match_executed_notebooks": True, "executed_R_cells": executed,
            "unhandled_notebook_errors": 0, "all_four_scripts_run_in_fresh_Rscript_sessions": True,
            "student_zip_contains_complete_raw_dataset": False,
            "student_zip_extracted_and_executed": True,
            "first_source_download_tested_from_empty_cache": cold,
            "second_baseline_run_byte_identical": True,
            "student_and_notebook_score_files_byte_identical": True,
            "independent_python_mean_rmse_mae_checks": True,
            "source_MD5_verified": True,
            "independent_results": {"training_mean_log10": mean, "rmse": rmse, "mae": mae}}
    (ROOT / "validation/student-project-check.json").write_text(json.dumps(info, indent=2))
    print(json.dumps(info, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cold-download", action="store_true")
    main(parser.parse_args().cold_download)
