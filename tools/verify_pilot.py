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
from assemble_notebooks import LESSONS, WORKFLOWS, CELL_DISPLAY, read_cells
from verify_tree import verify_tree

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def main(cold):
    executed = 0
    for workflow, stages in WORKFLOWS.items():
        complete = read_cells(ROOT / "scripts" / workflow)
        for name, keys in stages.items():
            assert read_cells(ROOT / "scripts" / f"{name}.R") == {key: complete[key] for key in keys}
    for name in LESSONS:
        notebook = nbformat.read(ROOT / "chapters" / f"{name}.ipynb", as_version=4)
        code = [cell for cell in notebook.cells if cell.cell_type == "code"]
        canonical = list(read_cells(ROOT / "scripts" / f"{name}.R").values())
        assert [cell.source for cell in code] == canonical
        assert all(cell.execution_count is not None for cell in code)
        assert not any(out.output_type == "error" for cell in code for out in cell.outputs)
        for cell, key in zip(code, read_cells(ROOT / "scripts" / f"{name}.R")):
            assert cell.metadata.get("tags", []) == CELL_DISPLAY.get(name, {}).get(key, [])
            assert "skip-execution" not in cell.metadata.get("tags", [])
        executed += len(code)
    zip_path = ROOT / "downloads/microbial-ml-student.zip"
    with tempfile.TemporaryDirectory(prefix="microbial-ml-student-") as work:
        with zipfile.ZipFile(zip_path) as z:
            assert z.testzip() is None
            assert not any("/data/raw/" in p for p in z.namelist())
            z.extractall(work)
        project = Path(work) / "microbial-ml"
        for name, prerequisite in [("06-split-farms", "Chapter 5"), ("07-baseline", "Chapter 6"),
                                   ("08-first-tree", "Chapter 7"), ("09-choose-tree", "Chapter 8"),
                                   ("10-test-tree", "Chapter 9")]:
            missing = subprocess.run(["Rscript", "--vanilla", "scripts/"+name+".R"], cwd=project,
                                     text=True, capture_output=True, timeout=30)
            assert missing.returncode != 0 and prerequisite in missing.stderr
        if not cold:
            (project / "data/raw").mkdir(parents=True)
            for filename in ["Raw_Milk_Micro_Data.csv", "Farm_Survey_Data.csv"]:
                shutil.copyfile(ROOT / "data/raw" / filename, project / "data/raw" / filename)
        # A learner can finish the supplied main route before the additional
        # runtime-error or live-chat exercises, using only the extracted ZIP.
        chapter_3 = (project / "scripts/03-working-with-ai.R").read_text()
        main_route, boundary, _ = chapter_3.partition("\n# %% runtime-error\n")
        assert boundary
        practice_path = project / "data/practice_counts.csv"
        practice_bytes = practice_path.read_bytes()
        main_run = subprocess.run(["Rscript", "--vanilla", "-e", main_route], cwd=project,
                                  text=True, capture_output=True, timeout=30)
        assert main_run.returncode == 0, main_run.stdout + main_run.stderr
        main_output = project / "outputs/ch03"
        assert not (main_output / "runtime-error-and-repair.txt").exists()
        assert (main_output / "ai-use-log.txt").is_file()
        main_record = (main_output / "summary-check.txt").read_text().splitlines()
        assert {"First reply result: NA", "Fill-zero example result: 15",
                "Checked recorded-count mean: 20", "Original fourth count still missing: TRUE"} <= set(main_record)
        assert read(main_output / "summary.csv") == [{"missing_n": "1", "recorded_n": "3", "mean_recorded": "20"}]
        assert practice_path.read_bytes() == practice_bytes
        for name in LESSONS:
            result = subprocess.run(["Rscript", "--vanilla", "scripts/"+name+".R"], cwd=project,
                                    text=True, capture_output=True, timeout=180)
            if result.returncode:
                raise AssertionError(result.stdout + result.stderr)
        # Check the new learning bridges against the actual fitted workflow.
        # This is a reference-code check, not a claimed live AI interaction.
        baseline_cells = read_cells(project / "scripts/07-baseline.R")
        before_export = []
        for key, value in baseline_cells.items():
            if key == "sensitivity":
                break
            before_export.append(value)
        learning_checks = "\n".join(before_export) + r'''
# The student's local-data AI check works before any export block is run.
ai_rmse <- sqrt(mean((test$log10_msc - test$prediction_log10)^2))
stopifnot(nrow(test) == 105, isTRUE(all.equal(ai_rmse, rmse)))
stopifnot(abs(sqrt(mean(preview_errors^2)) - ai_rmse) > 0.08)
source("scripts/08-first-tree.R")
stopifnot(hand_baseline == 1, left_mean == 0, right_mean == 2)
stopifnot(hand_new_prediction == 0, sum(one_mean_errors^2) == 4, sum(two_mean_errors^2) == 0)
stopifnot(surprise_observed - hand_baseline == 1, surprise_observed - hand_new_prediction == 2)
stopifnot(is.na(recorded_cows[3]), identical(model_cows, c(30, 40, 40, 200)))
stopifnot(sum(is.na(train_survey$milking_cows)) == 20, sum(is.na(train_ready$milking_cows)) == 0)
first_fit_for_check <- first_tree
source("scripts/09-choose-tree.R")
stopifnot(isTRUE(all.equal(as.numeric(round_predictions), as.numeric(oof[row_fold == 1, 1]))))
stopifnot(isTRUE(all.equal(first_fit_for_check$frame, final_tree$frame)))
stopifnot(isTRUE(all.equal(first_fit_for_check$splits, final_tree$splits)))
source("scripts/10-test-tree.R")
quiz_inputs <- data.frame(pasture_hours = c(6, 6, 6, 6, 18, 6), milking_cows = c(50, 60, 36, 37, 50, 30))
quiz_predictions <- as.numeric(predict(saved_model$fit, newdata = quiz_inputs))
stopifnot(quiz_predictions[1] == quiz_predictions[2], quiz_predictions[1] == quiz_predictions[5])
stopifnot(quiz_predictions[1] == quiz_predictions[4], quiz_predictions[3] == quiz_predictions[6])
stopifnot(quiz_predictions[3] != quiz_predictions[4])
ai_tree <- rpart(log10_msc ~ pasture_hours + milking_cows, data = train_filled,
                 method = "anova", control = selected_settings)
ai_prediction <- predict(ai_tree, newdata = test_filled)
stopifnot(isTRUE(all.equal(as.numeric(ai_prediction), as.numeric(tree_prediction))))
'''
        learning = subprocess.run(["Rscript", "--vanilla", "-e", learning_checks], cwd=project,
                                  text=True, capture_output=True, timeout=120)
        if learning.returncode:
            raise AssertionError(learning.stdout + learning.stderr)
        changed = read(project / "outputs/practice/practice_counts_changed.csv")
        original_practice = read(project / "data/practice_counts.csv")
        assert [float(r["count_cfu_ml"]) for r in changed] == [10, 20, 30, 40]
        assert statistics.mean(float(r["count_cfu_ml"]) for r in changed) == 25
        assert original_practice[-1]["count_cfu_ml"] in ["", "NA"]
        summary = read(project / "outputs/ch03/summary.csv")[0]
        assert {key: float(summary[key]) for key in summary} == {"missing_n": 1, "recorded_n": 3, "mean_recorded": 20}
        # Run the student's single-line mistake without the supplied guard:
        # it must be a genuine R execution failure, not a printed imitation.
        runtime_error = subprocess.run(["Rscript", "--vanilla", "-e",
            'practice <- read.csv("data/practice_counts.csv"); mean(milk_data$count_cfu_ml, na.rm = TRUE)'],
            cwd=project, text=True, capture_output=True, timeout=30)
        assert runtime_error.returncode != 0 and "milk_data" in runtime_error.stderr
        runtime_record = (project / "outputs/ch03/runtime-error-and-repair.txt").read_text()
        assert "milk_data" in runtime_record and "Correct object: practice" in runtime_record
        assert "Repaired recorded-count mean: 20" in runtime_record
        assert read(project / "data/practice_counts.csv")[-1]["count_cfu_ml"] in ["", "NA"]
        assert "R error observed: TRUE" in runtime_record
        # A learner may repair the intentional line in place. It must finish
        # with truthful guidance, rather than failing a second error assertion.
        edited_script = project / "scripts/my-03-edited-error.R"
        edited_script.write_text((project / "scripts/03-working-with-ai.R").read_text().replace(
            "mean(milk_data$count_cfu_ml, na.rm = TRUE)",
            "mean(practice$count_cfu_ml, na.rm = TRUE)"))
        edited_run = subprocess.run(["Rscript", "--vanilla", str(edited_script)], cwd=project,
                                    text=True, capture_output=True, timeout=30)
        assert edited_run.returncode == 0, edited_run.stdout + edited_run.stderr
        assert "No R error" in edited_run.stdout and "live-work area" in edited_run.stdout
        edited_record = (project / "outputs/ch03/runtime-error-and-repair.txt").read_text()
        assert "R error observed: FALSE" in edited_record
        assert "Repaired recorded-count mean: 20" in edited_record
        subprocess.run(["Rscript", "--vanilla", "scripts/03-working-with-ai.R"], cwd=project,
                       check=True, capture_output=True, text=True, timeout=30)
        log_path = project / "outputs/ch03/ai-use-log.txt"
        log_path.write_text("My completed student log: preserve this on rerun.\n")
        subprocess.run(["Rscript", "--vanilla", "scripts/03-working-with-ai.R"], cwd=project,
                       check=True, capture_output=True, text=True, timeout=30)
        assert log_path.read_text() == "My completed student log: preserve this on rerun.\n"
        toy = read(project / "outputs/toy/error-table.csv")
        assert [float(r["residual"]) for r in toy] == [10, 30]
        assert statistics.mean(float(r["absolute_error"]) for r in toy) == 20
        assert math.isclose(math.sqrt(statistics.mean(float(r["squared_error"]) for r in toy)), math.sqrt(500))
        toy_input = read(project / "data/practice_farms.csv")
        toy_train = [float(r["count_cfu_ml"]) for r in toy_input if r["FarmID"] != "C"]
        toy_test = [float(r["count_cfu_ml"]) for r in toy_input if r["FarmID"] == "C"]
        guesses = read(project / "outputs/toy/training-guesses.csv")
        for row in guesses:
            guess = float(row["guess_CFU_ml"])
            assert sum((y - guess)**2 for y in toy_train) == float(row["training_squared_error_sum"])
        assert [float(r["training_squared_error_sum"]) for r in guesses] == [800, 400, 800]
        leakage = read(project / "outputs/toy/leakage-comparison.csv")
        assert len(leakage) == 2
        for row, fitting_values in zip(leakage, [toy_train, toy_train + toy_test]):
            guess = statistics.mean(fitting_values)
            assert math.isclose(float(row["prediction_CFU_ml"]), guess, abs_tol=1e-12)
            assert math.isclose(float(row["MAE_CFU_ml"]), statistics.mean(abs(y - guess) for y in toy_test), abs_tol=1e-12)
            assert math.isclose(float(row["RMSE_CFU_ml"]), math.sqrt(statistics.mean((y - guess)**2 for y in toy_test)), abs_tol=1e-12)
        assert all(float(r["predicted"]) == statistics.mean(toy_train) == 20 for r in toy)
        assert float(leakage[1]["RMSE_CFU_ml"]) < float(leakage[0]["RMSE_CFU_ml"])
        first = (project / "outputs/baseline/scores.csv").read_bytes()
        subprocess.run(["Rscript", "--vanilla", "scripts/worked-example.R"], cwd=project,
                       check=True, text=True, capture_output=True, timeout=120)
        assert (project / "outputs/baseline/scores.csv").read_bytes() == first
        assert (ROOT / "outputs/baseline/scores.csv").read_bytes() == first
        first_tree = (project / "outputs/tree/test-scores.csv").read_bytes()
        subprocess.run(["Rscript", "--vanilla", "scripts/full-analysis.R"], cwd=project,
                       check=True, text=True, capture_output=True, timeout=180)
        assert (project / "outputs/tree/test-scores.csv").read_bytes() == first_tree
        assert (ROOT / "outputs/tree/test-scores.csv").read_bytes() == first_tree
        assert (project / "outputs/baseline/scores.csv").read_bytes() == first
        original_cv = (project / "outputs/tree/validation-scores.csv").read_bytes()
        poison_check = '''
original_input <- readRDS("outputs/checkpoints/tree-input.rds")
original_fit <- readRDS("outputs/checkpoints/tree-fit.rds")
poisoned <- original_input
poisoned$test$log10_msc <- rep(1e6, nrow(poisoned$test))
poisoned$test$pasture_hours <- rep(1e6, nrow(poisoned$test))
poisoned$test$milking_cows <- rep(1e6, nrow(poisoned$test))
saveRDS(poisoned, "outputs/checkpoints/tree-input.rds")
source("scripts/09-choose-tree.R")
new_fit <- readRDS("outputs/checkpoints/tree-fit.rds")
stopifnot(identical(original_fit$chosen_depth, new_fit$chosen_depth))
stopifnot(isTRUE(all.equal(original_fit$medians, new_fit$medians)))
stopifnot(isTRUE(all.equal(original_fit$fit$frame, new_fit$fit$frame)))
stopifnot(isTRUE(all.equal(original_fit$fit$splits, new_fit$fit$splits)))
saveRDS(original_input, "outputs/checkpoints/tree-input.rds")
saveRDS(original_fit, "outputs/checkpoints/tree-fit.rds")
'''
        subprocess.run(["Rscript", "--vanilla", "-e", poison_check], cwd=project,
                       check=True, text=True, capture_output=True, timeout=120)
        assert (project / "outputs/tree/validation-scores.csv").read_bytes() == original_cv
        assert (project / "outputs/tree/test-scores.csv").read_bytes() == first_tree
        tree_info = verify_tree(project)
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
        assert math.isclose(rmse, 0.528923133228833, abs_tol=1e-12)
        assert math.isclose(mae, 0.40914804613120787, abs_tol=1e-12)
    info = {"canonical_R_cells_match_executed_notebooks": True, "executed_R_cells": executed,
            "unhandled_notebook_errors": 0, "all_chapter_scripts_run_in_fresh_Rscript_sessions": True,
            "chapter_scripts": len(LESSONS), "stage_scripts_match_complete_canonical_workflow": True,
            "collapsed_cells_still_executed_and_match_display_policy": True,
            "missing_prerequisite_has_actionable_error": True,
            "changed_copy_exercise_25_and_original_preserved": True,
            "AI_summary_1_3_20_and_completed_log_preserved": True,
            "chapter_3_main_route_saves_NA_15_and_20_without_optional_exercises": True,
            "unguarded_student_line_produces_real_R_error": True,
            "guarded_error_record_and_repaired_mean_20_checked": True,
            "edited_intentional_error_has_guidance_without_secondary_failure": True,
            "local_full_105_row_RMSE_check_distinguished_from_three_row_preview": True,
            "toy_residuals_and_metrics_independently_checked": True,
            "toy_training_guesses_and_separate_leakage_example_checked": True,
            "baseline_numerically_matches_v01": True,
            "student_zip_contains_complete_raw_dataset": False,
            "student_zip_extracted_and_executed": True,
            "first_source_download_tested_from_empty_cache": cold,
            "second_baseline_run_byte_identical": True,
            "student_and_notebook_score_files_byte_identical": True,
            "independent_python_mean_rmse_mae_checks": True,
            "source_MD5_verified": True,
            "full_analysis_recreates_baseline_and_tree": True,
            "test_outcomes_and_features_cannot_change_tree_selection_or_fit": True,
            "hand_tree_counterexample_and_missing_input_copy_checked": True,
            "first_fit_and_one_round_demo_agree_with_selected_workflow": True,
            "branch_change_exercises_and_AI_reference_code_checked": True,
            "live_AI_interaction_automated_or_claimed": False,
            "independent_tree_checks": tree_info,
            "independent_results": {"training_mean_log10": mean, "rmse": rmse, "mae": mae}}
    (ROOT / "validation/student-project-check.json").write_text(json.dumps(info, indent=2))
    print(json.dumps(info, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cold-download", action="store_true")
    main(parser.parse_args().cold_download)
