# Predictor workflow for Chapters 8-10; canonical source for the stage scripts.
# First finish Chapter 7, or run scripts/full-analysis.R to recreate everything.
# %% tree-load
source("scripts/course_setup.R")
source("scripts/tree_helpers.R")
require_tree_package()
if (!file.exists("outputs/checkpoints/farm-split.rds")) stop("Run Chapter 7 first, or scripts/full-analysis.R, to create the baseline inputs.")
outer_split <- readRDS("outputs/checkpoints/farm-split.rds")
# %% hand-tree
# Invented training values: this is a hand-built illustration, not a fitted rpart model.
hand <- data.frame(pasture_hours = c(0, 4, 12, 16), MSC_CFU_ml = c(1, 1, 100, 100))
hand$log10_msc <- log10(hand$MSC_CFU_ml)
hand
hand_baseline <- mean(hand$log10_msc)
hand_prediction <- ifelse(hand$pasture_hours < 8,
  mean(hand$log10_msc[hand$pasture_hours < 8]), mean(hand$log10_msc[hand$pasture_hours >= 8]))
data.frame(rule = c("One mean", "Two leaf means"),
           training_squared_error_sum = c(sum((hand$log10_msc - hand_baseline)^2),
                                          sum((hand$log10_msc - hand_prediction)^2)))
# %% survey-source
survey <- read_survey_features(fetch_course_survey())
train_survey <- attach_survey(outer_split$train, survey)
test_survey <- attach_survey(outer_split$test, survey)
stopifnot(identical(train_survey$log10_msc, outer_split$train$log10_msc))
stopifnot(identical(test_survey$log10_msc, outer_split$test$log10_msc))
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
# %% save-tree-input
dir.create("outputs/tree", recursive = TRUE, showWarnings = FALSE)
write.csv(predictor_audit, "outputs/tree/predictor-audit.csv", row.names = FALSE)
saveRDS(list(train = train_survey, test = test_survey, audit = predictor_audit),
        "outputs/checkpoints/tree-input.rds")
file.exists("outputs/checkpoints/tree-input.rds")
# %% load-tree-input
source("scripts/tree_helpers.R")
require_tree_package()
if (!file.exists("outputs/checkpoints/tree-input.rds")) stop("Run Chapter 8 first to create tree-input.rds.")
tree_input <- readRDS("outputs/checkpoints/tree-input.rds")
train_survey <- tree_input$train
# %% tree-formula
tree_formula <- log10_msc ~ pasture_hours + milking_cows
tree_formula
candidate_depths <- 1:3
# %% training-folds
RNGkind(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
set.seed(2027)
training_farms <- sort(unique(train_survey$FarmID), method = "radix")
fold_labels <- sample(rep(1:5, length.out = length(training_farms)))
fold_table <- data.frame(FarmID = training_farms, fold = fold_labels)
row_fold <- fold_table$fold[match(train_survey$FarmID, fold_table$FarmID)]
stopifnot(!any(fold_table$FarmID %in% tree_input$test$FarmID))
data.frame(fold = 1:5, validation_farms = as.integer(table(fold_labels)),
           validation_records = as.integer(table(row_fold)))
# %% validate-depth
# Each record is predicted once by a fit that has never seen its farm.
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
    candidate <- rpart::rpart(tree_formula, data = fitting, method = "anova",
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
# %% choose-depth
chosen_depth <- min(validation_scores$depth[validation_scores$OOF_RMSE_log10 <= min(validation_scores$OOF_RMSE_log10) + 1e-12])
validation_scores$selected <- validation_scores$depth == chosen_depth
validation_scores
baseline_validation
chosen_depth
# %% fit-tree
training_medians <- learn_medians(train_survey)
train_filled <- fill_predictors(train_survey, training_medians)
final_tree <- rpart::rpart(tree_formula, data = train_filled, method = "anova",
                          control = tree_control(chosen_depth))
data.frame(feature = tree_features, training_median = unname(training_medians))
# %% training-check
# An illustration after selection: these fits do not alter the chosen depth.
validation_scores$training_RMSE_log10 <- vapply(candidate_depths, function(depth) {
  fitted <- rpart::rpart(tree_formula, data = train_filled, method = "anova", control = tree_control(depth))
  sqrt(mean((train_filled$log10_msc - predict(fitted, newdata = train_filled))^2))
}, numeric(1))
validation_scores[c("depth", "training_RMSE_log10", "OOF_RMSE_log10", "selected")]
# %% save-tree-fit
write.csv(fold_table, "outputs/tree/training-farm-folds.csv", row.names = FALSE)
write.csv(do.call(rbind, fold_medians), "outputs/tree/fold-medians.csv", row.names = FALSE)
write.csv(do.call(rbind, validation_nodes), "outputs/tree/validation-nodes.csv", row.names = FALSE)
write.csv(validation_scores, "outputs/tree/validation-scores.csv", row.names = FALSE)
write.csv(baseline_validation, "outputs/tree/baseline-validation.csv", row.names = FALSE)
oof_table <- data.frame(FarmID = train_survey$FarmID, Sampling = train_survey$Sampling,
  fold = row_fold, observed_log10 = observed, baseline_prediction = oof_baseline,
  depth_1 = oof[, 1], depth_2 = oof[, 2], depth_3 = oof[, 3])
write.csv(oof_table, "outputs/tree/out-of-fold-predictions.csv", row.names = FALSE)
saveRDS(list(fit = final_tree, medians = training_medians, chosen_depth = chosen_depth,
             train = train_survey, test = tree_input$test, audit = tree_input$audit,
             validation = validation_scores, baseline_validation = baseline_validation),
        "outputs/checkpoints/tree-fit.rds")
cat("Saved tree-fit.rds; no tree test score has been calculated.\n")
# %% load-tree-fit
source("scripts/tree_helpers.R")
require_tree_package()
if (!file.exists("outputs/checkpoints/tree-fit.rds")) stop("Run Chapter 9 first to create tree-fit.rds.")
chosen <- readRDS("outputs/checkpoints/tree-fit.rds")
final_tree <- chosen$fit
train_filled <- fill_predictors(chosen$train, chosen$medians)
# %% predict-tree
# Test features use medians already learned from training. No refit or new choice.
test_filled <- fill_predictors(chosen$test, chosen$medians)
tree_prediction <- as.numeric(predict(final_tree, newdata = test_filled))
baseline_prediction <- rep(mean(chosen$train$log10_msc), nrow(test_filled))
head(data.frame(observed_log10 = test_filled$log10_msc,
                tree_prediction = tree_prediction, baseline_prediction = baseline_prediction), 3)
# %% tree-test-scores
tree_scores <- data.frame(model = c("Training-mean baseline", "Shallow regression tree"),
  maxdepth = c(0, chosen$chosen_depth), n_test = nrow(test_filled), test_farms = length(unique(test_filled$FarmID)),
  RMSE_log10_CFU_ml = c(sqrt(mean((test_filled$log10_msc - baseline_prediction)^2)),
                       sqrt(mean((test_filled$log10_msc - tree_prediction)^2))),
  MAE_log10_CFU_ml = c(mean(abs(test_filled$log10_msc - baseline_prediction)),
                      mean(abs(test_filled$log10_msc - tree_prediction))))
tree_scores
# %% check-leaves
nodes <- extract_tree_nodes(final_tree)
train_routes <- lapply(seq_len(nrow(train_filled)), function(i) trace_tree(train_filled[i, ], nodes))
train_leaf <- vapply(train_routes, function(route) route$leaf, integer(1))
train_prediction <- as.numeric(predict(final_tree, newdata = train_filled))
stopifnot(isTRUE(all.equal(vapply(train_routes, function(route) route$prediction, numeric(1)), train_prediction)))
leaf_means <- aggregate(train_filled$log10_msc, list(leaf = train_leaf), mean)
names(leaf_means)[2] <- "mean_from_training_records"
leaf_means$tree_prediction <- nodes$mean_log10[match(leaf_means$leaf, nodes$node)]
stopifnot(isTRUE(all.equal(leaf_means$mean_from_training_records, leaf_means$tree_prediction)))
leaf_means
# %% trace-one
first_route <- trace_tree(test_filled[1, ], nodes)
data.frame(feature = tree_features, recorded = unlist(chosen$test[1, tree_features], use.names = FALSE),
           used_by_model = unlist(test_filled[1, tree_features], use.names = FALSE))
first_route
stopifnot(isTRUE(all.equal(first_route$prediction, tree_prediction[1])))
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
  tree_prediction = tree_prediction, baseline_prediction = baseline_prediction)
write.csv(test_predictions, "outputs/tree/test-predictions.csv", row.names = FALSE)
saveRDS(list(fit = final_tree, medians = chosen$medians, features = tree_features), "outputs/tree/model.rds")
writeLines(capture.output(sessionInfo()), "outputs/tree/session-info.txt")
# %% new-samples
# Invented input profiles, without observed outcomes; not an evaluation dataset.
saved_model <- readRDS("outputs/tree/model.rds")
new_samples <- data.frame(pasture_hours = c(6, 6), milking_cows = c(50, 30))
new_ready <- fill_predictors(new_samples, saved_model$medians)
new_prediction <- as.numeric(predict(saved_model$fit, newdata = new_ready))
example_predictions <- data.frame(new_samples, prediction_log10 = new_prediction,
                                  concentration_expression_CFU_ml = 10^new_prediction)
example_predictions
write.csv(example_predictions, "outputs/tree/example-predictions.csv", row.names = FALSE)
# %% plot-tree
write_tree_mermaid(nodes, "outputs/tree/fitted-tree.mmd")
png("outputs/tree/fitted-tree.png", width = 1200, height = 720, res = 150)
par(mar = c(0, 0, 3, 0), xpd = NA, family = "sans")
draw_teaching_tree(final_tree, nodes)
invisible(dev.off())
cat("Saved outputs/tree/fitted-tree.png\n")
