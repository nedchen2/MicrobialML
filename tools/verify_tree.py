"""Independently reconstruct numeric tree routing, medians and held-out scores."""
import csv
import hashlib
import math
from pathlib import Path
import statistics


def rows(path, encoding="utf-8"):
    with Path(path).open(encoding=encoding, newline="") as stream:
        return list(csv.DictReader(stream))


def close(actual, expected):
    assert math.isclose(float(actual), expected, rel_tol=1e-12, abs_tol=1e-12), (actual, expected)


def verify_tree(project):
    source = project / "data/raw/Farm_Survey_Data.csv"
    assert hashlib.md5(source.read_bytes()).hexdigest() == "948ed520f7564bda2694111b56ccc8cb"
    dictionary = rows(project / "data/predictor-dictionary.csv")
    features = [r["variable"] for r in dictionary]
    assert features == ["pasture_hours", "milking_cows"]
    survey = [{k.strip(): v.strip() for k, v in r.items()} for r in rows(source, "utf-8-sig")]
    survey_map = {(r["FarmID"], r["Sampling"]): r for r in survey}
    assert len(survey) == len(survey_map) == 540
    raw = rows(project / "data/raw/Raw_Milk_Micro_Data.csv")
    eligible = [r for r in raw if r["Test"] == "MSC" and r["Notes"].strip() in ["", "NA"]
                and math.isfinite(float(r["Conc"])) and float(r["Conc"]) > 0]
    targets = {(r["FarmID"], r["Sampling"]): math.log10(float(r["Conc"])) for r in eligible}
    inputs = {}
    for key in targets:
        survey_row = survey_map.get(key, {})
        values = {}
        for definition in dictionary:
            value = survey_row.get(definition["source_column"], "")
            values[definition["variable"]] = None if value in ["", "NA", "??"] else float(value)
        inputs[key] = values
    assignment = {r["FarmID"]: r["split"] for r in rows(project / "outputs/baseline/farm-split.csv")}
    train = [key for key in targets if assignment[key[0]] == "train"]
    test = [key for key in targets if assignment[key[0]] == "test"]
    assert len(train) == 420 and len(test) == 105
    folds = {r["FarmID"]: int(r["fold"]) for r in rows(project / "outputs/tree/training-farm-folds.csv")}
    assert set(folds) == {key[0] for key in train}
    assert set(folds.values()) == {1, 2, 3, 4, 5}
    assert not set(folds).intersection(key[0] for key in test)

    def medians(keys):
        return {feature: statistics.median(inputs[key][feature] for key in keys if inputs[key][feature] is not None)
                for feature in features}

    def filled(key, values):
        return {feature: inputs[key][feature] if inputs[key][feature] is not None else values[feature]
                for feature in features}

    def walk(values, nodes):
        node = 1
        visited = []
        while True:
            row = nodes[node]
            visited.append(node)
            if row["feature"] == "<leaf>":
                return node, float(row["mean_log10"]), visited
            assert row["feature"] in features
            less = values[row["feature"]] < float(row["cut"])
            left = less if row["less_goes_left"] == "TRUE" else not less
            node = 2 * node if left else 2 * node + 1
            assert len(visited) <= 4

    def check_fit(nodes, fitting, values, depth):
        membership = {node: [] for node in nodes}
        for key in fitting:
            _, _, visited = walk(filled(key, values), nodes)
            for node in visited:
                membership[node].append(key)
        for node, row in nodes.items():
            assert membership[node]
            assert len(membership[node]) == int(row["records"])
            close(row["mean_log10"], statistics.mean(targets[key] for key in membership[node]))
            assert node.bit_length() - 1 <= depth
            if row["feature"] == "<leaf>":
                assert len(membership[node]) >= 10

    reported_medians = {(int(r["fold"]), r["feature"]): float(r["median"])
                        for r in rows(project / "outputs/tree/fold-medians.csv")}
    cv_nodes = rows(project / "outputs/tree/validation-nodes.csv")
    oof = rows(project / "outputs/tree/out-of-fold-predictions.csv")
    assert len(oof) == len(train)
    assert [(r["FarmID"], r["Sampling"]) for r in oof] == train
    for fold in range(1, 6):
        fitting = [key for key in train if folds[key[0]] != fold]
        hidden = [key for key in train if folds[key[0]] == fold]
        values = medians(fitting)
        for feature in features:
            close(reported_medians[fold, feature], values[feature])
        for depth in [1, 2, 3]:
            nodes = {int(r["node"]): r for r in cv_nodes if int(r["fold"]) == fold and int(r["depth"]) == depth}
            check_fit(nodes, fitting, values, depth)
            for row in oof:
                key = row["FarmID"], row["Sampling"]
                if key not in hidden:
                    continue
                assert int(row["fold"]) == fold
                close(row["observed_log10"], targets[key])
                close(row["baseline_prediction"], statistics.mean(targets[k] for k in fitting))
                close(row[f"depth_{depth}"], walk(filled(key, values), nodes)[1])

    def errors(records, column):
        residuals = [float(r["observed_log10"]) - float(r[column]) for r in records]
        return math.sqrt(statistics.mean(e * e for e in residuals)), statistics.mean(abs(e) for e in residuals)

    validation = rows(project / "outputs/tree/validation-scores.csv")
    assert [int(r["depth"]) for r in validation] == [1, 2, 3]
    for row in validation:
        rmse, mae = errors(oof, "depth_" + row["depth"])
        close(row["OOF_RMSE_log10"], rmse)
        close(row["OOF_MAE_log10"], mae)
    best = min(float(r["OOF_RMSE_log10"]) for r in validation)
    depth = min(int(r["depth"]) for r in validation if float(r["OOF_RMSE_log10"]) <= best + 1e-12)
    assert [int(r["depth"]) for r in validation if r["selected"] == "TRUE"] == [depth]
    baseline_validation = rows(project / "outputs/tree/baseline-validation.csv")[0]
    rmse, mae = errors(oof, "baseline_prediction")
    close(baseline_validation["OOF_RMSE_log10"], rmse)
    close(baseline_validation["OOF_MAE_log10"], mae)

    values = medians(train)
    for row in rows(project / "outputs/tree/training-medians.csv"):
        close(row["median"], values[row["feature"]])
    nodes = {int(r["node"]): r for r in rows(project / "outputs/tree/nodes.csv")}
    check_fit(nodes, train, values, depth)
    for filename, keys in [("training-predictions.csv", train), ("test-predictions.csv", test)]:
        predictions = rows(project / "outputs/tree" / filename)
        assert [(r["FarmID"], r["Sampling"]) for r in predictions] == keys
        for row, key in zip(predictions, keys):
            close(row["observed_log10"], targets[key])
            expected = filled(key, values)
            for feature in features:
                close(row[feature], expected[feature])
            leaf, prediction, _ = walk(expected, nodes)
            close(row["tree_prediction"], prediction)
            if "leaf" in row:
                assert int(row["leaf"]) == leaf
            if "baseline_prediction" in row:
                close(row["baseline_prediction"], statistics.mean(targets[k] for k in train))
                for feature in features:
                    assert (row[feature + "_missing"] == "TRUE") == (inputs[key][feature] is None)
    predictions = rows(project / "outputs/tree/test-predictions.csv")
    scores = rows(project / "outputs/tree/test-scores.csv")
    assert len(scores) == 2
    for score, column in zip(scores, ["baseline_prediction", "tree_prediction"]):
        rmse, mae = errors(predictions, column)
        assert int(score["n_test"]) == 105 and int(score["test_farms"]) == 21
        close(score["RMSE_log10_CFU_ml"], rmse)
        close(score["MAE_log10_CFU_ml"], mae)
    assert int(scores[1]["maxdepth"]) == depth
    for row in rows(project / "outputs/tree/example-predictions.csv"):
        prediction = walk({feature: float(row[feature]) for feature in features}, nodes)[1]
        close(row["prediction_log10"], prediction)
        close(row["concentration_expression_CFU_ml"], 10 ** prediction)
    # These document the frozen teaching result; they never guide model selection.
    assert depth == 1
    assert nodes[1]["feature"] == "milking_cows" and nodes[1]["less_goes_left"] == "FALSE"
    close(nodes[1]["cut"], 36.5)
    close(scores[1]["RMSE_log10_CFU_ml"], 0.544897029474068)
    close(scores[1]["MAE_log10_CFU_ml"], 0.426426372143913)
    assert float(scores[1]["RMSE_log10_CFU_ml"]) > float(scores[0]["RMSE_log10_CFU_ml"])
    return {"original_survey_MD5_verified": True, "record_and_farm_roles_preserved": True,
            "all_15_validation_tree_node_means_and_OOF_routes_reconstructed": True,
            "fold_and_final_medians_independently_reconstructed": True,
            "final_leaf_means_and_all_prediction_routes_reconstructed": True,
            "pooled_validation_metrics_and_selection_reconstructed": True,
            "test_metrics_and_saved_model_example_predictions_reconstructed": True,
            "chosen_depth": depth, "tree_test_RMSE": float(scores[1]["RMSE_log10_CFU_ml"]),
            "tree_test_MAE": float(scores[1]["MAE_log10_CFU_ml"])}
