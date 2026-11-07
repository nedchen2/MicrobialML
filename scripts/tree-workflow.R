# Predictor workflow for Chapters 8-10; canonical source for the stage scripts.
# First finish Chapter 7, or run scripts/full-analysis.R to recreate everything.
# %% load-rpart-for-first-tree
# If not installed yet, run install.packages("rpart") in the Console once.
library(rpart)
# %% load-farm-split-for-tree
source("scripts/course_setup.R")
source("scripts/tree_helpers.R")
if (!file.exists("outputs/checkpoints/farm-split.rds")) stop("Run Chapter 7 first, or scripts/full-analysis.R, to create the baseline inputs.")
outer_split <- readRDS("outputs/checkpoints/farm-split.rds")
dir.create("outputs/tree", recursive = TRUE, showWarnings = FALSE)
# %% hand-data
# Invented records for hand arithmetic, not an rpart fit on four rows.
hand <- data.frame(pasture_hours = c(0, 4, 12, 16), MSC_CFU_ml = c(1, 1, 100, 100))
hand$log10_msc <- log10(hand$MSC_CFU_ml)
hand
# %% hand-mean
hand_baseline <- mean(hand$log10_msc)
hand_baseline
# %% hand-left
left_group <- hand[hand$pasture_hours < 8, ]
left_group
left_mean <- mean(left_group$log10_msc)
left_mean
# %% hand-right
right_group <- hand[hand$pasture_hours >= 8, ]
right_group
right_mean <- mean(right_group$log10_msc)
right_mean
# %% hand-new
new_hours <- 6
hand_new_prediction <- ifelse(new_hours < 8, left_mean, right_mean)
hand_new_prediction
10^hand_new_prediction
# %% hand-errors
hand$two_mean_prediction <- c(left_mean, left_mean, right_mean, right_mean)
one_mean_errors <- hand$log10_msc - hand_baseline
two_mean_errors <- hand$log10_msc - hand$two_mean_prediction
sum(one_mean_errors^2)
sum(two_mean_errors^2)
# %% hand-surprise
# An invented counterexample with a now-known outcome, not a real survey record.
surprise_observed <- log10(100)
surprise_observed - hand_baseline
surprise_observed - hand_new_prediction
# %% join-farm-survey
survey <- read_survey_features(fetch_course_survey())
train_survey <- attach_survey(outer_split$train, survey)
test_survey <- attach_survey(outer_split$test, survey)
stopifnot(identical(train_survey$log10_msc, outer_split$train$log10_msc))
stopifnot(identical(test_survey$log10_msc, outer_split$test$log10_msc))
# %% predictor-preview
head(train_survey[c("pasture_hours", "milking_cows", "log10_msc")], 3)
# %% predictor-audit
predictor_audit <- do.call(rbind, lapply(list(train = train_survey, test = test_survey), function(data) {
  data.frame(records = nrow(data), survey_matched = sum(data$survey_matched),
    survey_unmatched = sum(!data$survey_matched), pasture_hours_missing = sum(is.na(data$pasture_hours)),
    milking_cows_missing = sum(is.na(data$milking_cows)))
}))
predictor_audit$role <- row.names(predictor_audit)
row.names(predictor_audit) <- NULL
predictor_audit <- predictor_audit[c("role", "records", "survey_matched", "survey_unmatched",
                                     "pasture_hours_missing", "milking_cows_missing")]
predictor_audit
stopifnot(nrow(train_survey) == 420, nrow(test_survey) == 105)
stopifnot(length(intersect(train_survey$FarmID, test_survey$FarmID)) == 0)
stopifnot(identical(predictor_audit$survey_unmatched, c(18L, 11L)))
# %% median-example
# Invented predictor values: keep the recorded values unchanged.
recorded_cows <- c(30, 40, NA, 200)
reference_cows <- median(recorded_cows, na.rm = TRUE)
model_cows <- recorded_cows
model_cows[is.na(model_cows)] <- reference_cows
data.frame(recorded = recorded_cows, used_by_model = model_cows)
# %% learn-training-medians
training_medians <- c(
  pasture_hours = median(train_survey$pasture_hours, na.rm = TRUE),
  milking_cows = median(train_survey$milking_cows, na.rm = TRUE)
)
training_medians
# %% fill-missing-training-inputs
train_ready <- train_survey
train_ready$pasture_hours[is.na(train_ready$pasture_hours)] <- training_medians[["pasture_hours"]]
train_ready$milking_cows[is.na(train_ready$milking_cows)] <- training_medians[["milking_cows"]]
# %% fit-first-tree
first_settings <- fixed_tree_settings
first_settings$maxdepth <- 1
first_tree <- rpart(log10_msc ~ pasture_hours + milking_cows,
                    data = train_ready, method = "anova", control = first_settings)
# %% first-plot
first_nodes <- extract_tree_nodes(first_tree)
png("outputs/tree/first-tree.png", width = 1200, height = 720, res = 150)
par(mar = c(0, 0, 3, 0), xpd = NA, family = "sans")
draw_teaching_tree(first_tree, first_nodes)
invisible(dev.off())
cat("Saved outputs/tree/first-tree.png\n")
# %% first-inputs
# Invented inputs only: neither row has a known MSC result.
first_inputs <- data.frame(pasture_hours = c(6, 6), milking_cows = c(50, 30))
first_inputs
# %% first-predict
first_predictions <- predict(first_tree, newdata = first_inputs)
data.frame(first_inputs, prediction_log10 = as.numeric(first_predictions))
# %% save-tree-input
write.csv(predictor_audit, "outputs/tree/predictor-audit.csv", row.names = FALSE)
saveRDS(list(train = train_survey, test = test_survey, audit = predictor_audit),
        "outputs/checkpoints/tree-input.rds")
file.exists("outputs/checkpoints/tree-input.rds")
# %% load-rpart-for-validation
library(rpart)
# %% load-tree-input
source("scripts/tree_helpers.R")
if (!file.exists("outputs/checkpoints/tree-input.rds")) stop("Run Chapter 8 first to create tree-input.rds.")
tree_input <- readRDS("outputs/checkpoints/tree-input.rds")
train_survey <- tree_input$train
# %% depth-candidates
candidate_depths <- 1:3
candidate_depths
# %% training-folds
# Fix the algorithms as in Chapter 6, then set the starting point for this shuffle.
RNGkind(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
set.seed(2027)
training_farms <- sort(unique(train_survey$FarmID), method = "radix")
# Repeat the labels 1 to 5 until there is one per farm, then shuffle them.
fold_labels <- sample(rep(1:5, length.out = length(training_farms)))
fold_table <- data.frame(FarmID = training_farms, fold = fold_labels)
# match() finds each record's farm in fold_table so we can look up its fold number.
row_fold <- fold_table$fold[match(train_survey$FarmID, fold_table$FarmID)]
stopifnot(!any(fold_table$FarmID %in% tree_input$test$FarmID))
data.frame(fold = 1:5, validation_farms = as.integer(table(fold_labels)),
           validation_records = as.integer(table(row_fold)))
# %% one-round-data
fitting <- train_survey[row_fold != 1, ]
validation <- train_survey[row_fold == 1, ]
data.frame(role = c("Fit", "Validate"), records = c(nrow(fitting), nrow(validation)),
           farms = c(length(unique(fitting$FarmID)), length(unique(validation$FarmID))))
# %% one-round-prepare
# Same median rule as Chapter 8, now learned only from this round's fitting records.
round_medians <- learn_medians(fitting)
fitting_ready <- fill_predictors(fitting, round_medians)
validation_ready <- fill_predictors(validation, round_medians)
data.frame(feature = tree_features, fitting_median = unname(round_medians))
# %% one-round-fit
round_settings <- fixed_tree_settings
round_settings$maxdepth <- 1
round_tree <- rpart(log10_msc ~ pasture_hours + milking_cows,
                    data = fitting_ready, method = "anova", control = round_settings)
# %% one-round-predict
round_predictions <- predict(round_tree, newdata = validation_ready)
# Show the first record with the two labels that identify it.
round_one_record <- data.frame(
  FarmID = validation_ready$FarmID[1],
  Sampling = validation_ready$Sampling[1],
  observed_log10 = validation_ready$log10_msc[1],
  predicted_log10 = as.numeric(round_predictions[1]))
round_one_record
# %% one-round-error
round_errors <- validation_ready$log10_msc - round_predictions
sqrt(mean(round_errors^2))
# %% validate-depth
# Repeat the illustrated fit/predict steps for all five folds and three depths.
tree_formula <- log10_msc ~ pasture_hours + milking_cows
oof <- matrix(NA_real_, nrow(train_survey), length(candidate_depths))
oof_baseline <- rep(NA_real_, nrow(train_survey))
fold_medians <- list()
validation_nodes <- list()
for (fold in 1:5) {
  fitting <- train_survey[row_fold != fold, ]
  validation <- train_survey[row_fold == fold, ]
  stopifnot(length(intersect(fitting$FarmID, validation$FarmID)) == 0)
  medians <- learn_medians(fitting)
  fold_medians[[fold]] <- data.frame(fold = fold, feature = tree_features, median = unname(medians))
  fitting <- fill_predictors(fitting, medians)
  validation <- fill_predictors(validation, medians)
  oof_baseline[row_fold == fold] <- mean(fitting$log10_msc)
  for (j in seq_along(candidate_depths)) {
    candidate <- rpart(tree_formula, data = fitting, method = "anova",
                       control = tree_control(candidate_depths[j]))
    candidate_nodes <- extract_tree_nodes(candidate)
    candidate_nodes$fold <- fold
    candidate_nodes$depth <- candidate_depths[j]
    validation_nodes[[length(validation_nodes) + 1L]] <- candidate_nodes
    oof[row_fold == fold, j] <- predict(candidate, newdata = validation)
  }
}
stopifnot(all(is.finite(oof)), all(is.finite(oof_baseline)))
observed <- train_survey$log10_msc
validation_scores <- data.frame(depth = candidate_depths,
  OOF_RMSE_log10 = vapply(seq_along(candidate_depths), function(j) sqrt(mean((observed - oof[, j])^2)), numeric(1)),
  OOF_MAE_log10 = vapply(seq_along(candidate_depths), function(j) mean(abs(observed - oof[, j])), numeric(1)))
baseline_validation <- data.frame(model = "Training-fold mean", depth = 0,
  OOF_RMSE_log10 = sqrt(mean((observed - oof_baseline)^2)), OOF_MAE_log10 = mean(abs(observed - oof_baseline)))
# %% trace-validation-record
oof_table <- data.frame(FarmID = train_survey$FarmID, Sampling = train_survey$Sampling,
  fold = row_fold, observed_log10 = observed, baseline_prediction = oof_baseline,
  depth_1 = oof[, 1], depth_2 = oof[, 2], depth_3 = oof[, 3])
# Find the row with both the same farm ID and the same sampling round.
same_farm <- oof_table$FarmID == round_one_record$FarmID
same_round <- oof_table$Sampling == round_one_record$Sampling
traced_record <- oof_table[same_farm & same_round,
                           c("FarmID", "Sampling", "fold", "observed_log10", "depth_1")]
traced_record
# %% choose-depth
# Treat RMSEs within 1e-12 of the lowest score as tied. Pick the shallowest tied tree.
chosen_depth <- min(validation_scores$depth[validation_scores$OOF_RMSE_log10 <= min(validation_scores$OOF_RMSE_log10) + 1e-12])
validation_scores$selected <- validation_scores$depth == chosen_depth
validation_scores
chosen_depth
# %% compare-training-and-validation-errors
# An illustration after selection: these fits do not alter the chosen depth.
training_medians <- learn_medians(train_survey)
train_filled <- fill_predictors(train_survey, training_medians)
validation_scores$training_RMSE_log10 <- vapply(candidate_depths, function(depth) {
  fitted <- rpart(tree_formula, data = train_filled, method = "anova", control = tree_control(depth))
  sqrt(mean((train_filled$log10_msc - predict(fitted, newdata = train_filled))^2))
}, numeric(1))
validation_scores[c("depth", "training_RMSE_log10", "OOF_RMSE_log10", "selected")]
baseline_validation
# %% fit-tree
selected_settings <- fixed_tree_settings
selected_settings$maxdepth <- chosen_depth
final_tree <- rpart(log10_msc ~ pasture_hours + milking_cows,
                    data = train_filled, method = "anova", control = selected_settings)
# %% save-tree-fit
write.csv(fold_table, "outputs/tree/training-farm-folds.csv", row.names = FALSE)
write.csv(do.call(rbind, fold_medians), "outputs/tree/fold-medians.csv", row.names = FALSE)
write.csv(do.call(rbind, validation_nodes), "outputs/tree/validation-nodes.csv", row.names = FALSE)
write.csv(validation_scores, "outputs/tree/validation-scores.csv", row.names = FALSE)
write.csv(baseline_validation, "outputs/tree/baseline-validation.csv", row.names = FALSE)
write.csv(oof_table, "outputs/tree/out-of-fold-predictions.csv", row.names = FALSE)
saveRDS(list(fit = final_tree, medians = training_medians, chosen_depth = chosen_depth,
             train = train_survey, test = tree_input$test, audit = tree_input$audit,
             validation = validation_scores, baseline_validation = baseline_validation),
        "outputs/checkpoints/tree-fit.rds")
cat("Saved tree-fit.rds; no tree test score has been calculated.\n")
# %% load-rpart
library(rpart)
# %% load-tree-fit
source("scripts/tree_helpers.R")
if (!file.exists("outputs/checkpoints/tree-fit.rds")) stop("Run Chapter 9 first to create tree-fit.rds.")
chosen <- readRDS("outputs/checkpoints/tree-fit.rds")
final_tree <- chosen$fit
train_filled <- fill_predictors(chosen$train, chosen$medians)
# %% plot-tree
nodes <- extract_tree_nodes(final_tree)
write_tree_mermaid(nodes, "outputs/tree/fitted-tree.mmd")
png("outputs/tree/fitted-tree.png", width = 1200, height = 720, res = 150)
par(mar = c(0, 0, 3, 0), xpd = NA, family = "sans")
draw_teaching_tree(final_tree, nodes)
invisible(dev.off())
cat("Saved outputs/tree/fitted-tree.png\n")
# %% prepare-test
# Test inputs use saved training medians, with no refit or new choice.
test_filled <- fill_predictors(chosen$test, chosen$medians)
# %% predict-tree
tree_prediction <- predict(final_tree, newdata = test_filled)
# %% trace-one-test-prediction
first_tree_test_record <- test_filled[1, ]
first_route <- trace_tree(first_tree_test_record, nodes)
data.frame(feature = tree_features, recorded = unlist(chosen$test[1, tree_features], use.names = FALSE),
           used_by_model = unlist(first_tree_test_record[tree_features], use.names = FALSE))
data.frame(FarmID = first_tree_test_record$FarmID, Sampling = first_tree_test_record$Sampling,
           observed_log10 = first_tree_test_record$log10_msc,
           rule = paste(first_route$path, collapse = "; "), leaf = first_route$leaf,
           prediction_log10 = first_route$prediction)
stopifnot(isTRUE(all.equal(first_route$prediction, as.numeric(tree_prediction[1]))))
# %% check-one-test-residual
baseline_prediction <- rep(mean(chosen$train$log10_msc), nrow(test_filled))
first_observed <- first_tree_test_record$log10_msc
first_predictions <- c(baseline_prediction[1], as.numeric(tree_prediction[1]))
first_test_comparison <- data.frame(
  model = c("Training-mean baseline", "Shallow regression tree"),
  observed_log10 = first_observed,
  predicted_log10 = first_predictions,
  residual_log10 = first_observed - first_predictions)
first_test_comparison
# %% check-leaves
train_routes <- lapply(seq_len(nrow(train_filled)), function(i) trace_tree(train_filled[i, ], nodes))
train_leaf <- vapply(train_routes, function(route) route$leaf, integer(1))
train_prediction <- as.numeric(predict(final_tree, newdata = train_filled))
stopifnot(isTRUE(all.equal(vapply(train_routes, function(route) route$prediction, numeric(1)), train_prediction)))
# Group the training outcomes by leaf and calculate one mean per leaf.
leaf_means <- aggregate(train_filled$log10_msc, list(leaf = train_leaf), mean)
names(leaf_means)[2] <- "mean_from_training_records"
leaf_means$tree_prediction <- nodes$mean_log10[match(leaf_means$leaf, nodes$node)]
stopifnot(isTRUE(all.equal(leaf_means$mean_from_training_records, leaf_means$tree_prediction)))
leaf_means
# %% tree-errors
baseline_errors <- test_filled$log10_msc - baseline_prediction
tree_errors <- test_filled$log10_msc - tree_prediction
# %% tree-test-scores
tree_scores <- data.frame(model = c("Training-mean baseline", "Shallow regression tree"),
  maxdepth = c(0, chosen$chosen_depth), n_test = nrow(test_filled), test_farms = length(unique(test_filled$FarmID)),
  RMSE_log10_CFU_ml = c(sqrt(mean(baseline_errors^2)), sqrt(mean(tree_errors^2))),
  MAE_log10_CFU_ml = c(mean(abs(baseline_errors)), mean(abs(tree_errors))))
tree_scores[c("model", "n_test", "test_farms", "RMSE_log10_CFU_ml", "MAE_log10_CFU_ml")]
# %% save-tree-results
write.csv(tree_scores, "outputs/tree/test-scores.csv", row.names = FALSE)
write.csv(nodes, "outputs/tree/nodes.csv", row.names = FALSE)
write.csv(leaf_means, "outputs/tree/leaf-means.csv", row.names = FALSE)
write.csv(data.frame(feature = tree_features, median = unname(chosen$medians)),
          "outputs/tree/training-medians.csv", row.names = FALSE)
training_predictions <- data.frame(FarmID = train_filled$FarmID, Sampling = train_filled$Sampling,
  observed_log10 = train_filled$log10_msc, train_filled[tree_features], leaf = train_leaf,
  tree_prediction = train_prediction)
write.csv(training_predictions, "outputs/tree/training-predictions.csv", row.names = FALSE)
test_predictions <- data.frame(FarmID = test_filled$FarmID, Sampling = test_filled$Sampling,
  observed_log10 = test_filled$log10_msc, test_filled[tree_features],
  pasture_hours_missing = is.na(chosen$test$pasture_hours), milking_cows_missing = is.na(chosen$test$milking_cows),
  tree_prediction = as.numeric(tree_prediction), baseline_prediction = baseline_prediction)
write.csv(test_predictions, "outputs/tree/test-predictions.csv", row.names = FALSE)
writeLines(capture.output(sessionInfo()), "outputs/tree/session-info.txt")
# %% save-model
model_for_reuse <- list(fit = final_tree, medians = chosen$medians, features = tree_features)
saveRDS(model_for_reuse, "outputs/tree/model.rds")
# %% reload-model
saved_model <- readRDS("outputs/tree/model.rds")
# %% new-samples
# Invented input profiles, without observed outcomes; not an evaluation dataset.
new_samples <- data.frame(pasture_hours = c(6, 6), milking_cows = c(50, 30))
new_samples
# %% prepare-new
new_ready <- fill_predictors(new_samples, saved_model$medians)
# %% new-predict
new_prediction <- predict(saved_model$fit, newdata = new_ready)
example_predictions <- data.frame(new_samples, prediction_log10 = as.numeric(new_prediction),
                                  concentration_expression_CFU_ml = 10^as.numeric(new_prediction))
example_predictions
write.csv(example_predictions, "outputs/tree/example-predictions.csv", row.names = FALSE)
# %% restore-selected-tree-settings
selected_settings <- fixed_tree_settings
selected_settings$maxdepth <- chosen$chosen_depth
# My live AI attempt: add returned code and your check below in your my- copy.
