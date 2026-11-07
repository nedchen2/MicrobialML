# Generated from tree-workflow.R for Chapter 09; edit that canonical source as author.
# Students: save a working copy as my-09-choose-tree.R; follow the matching page.
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
head(data.frame(observed_log10 = validation_ready$log10_msc,
                predicted_log10 = as.numeric(round_predictions)), 3)
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
# %% choose-depth
# Treat RMSEs within 1e-12 of the lowest score as tied. Pick the shallowest tied tree.
chosen_depth <- min(validation_scores$depth[validation_scores$OOF_RMSE_log10 <= min(validation_scores$OOF_RMSE_log10) + 1e-12])
validation_scores$selected <- validation_scores$depth == chosen_depth
validation_scores
baseline_validation
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
oof_table <- data.frame(FarmID = train_survey$FarmID, Sampling = train_survey$Sampling,
  fold = row_fold, observed_log10 = observed, baseline_prediction = oof_baseline,
  depth_1 = oof[, 1], depth_2 = oof[, 2], depth_3 = oof[, 3])
write.csv(oof_table, "outputs/tree/out-of-fold-predictions.csv", row.names = FALSE)
saveRDS(list(fit = final_tree, medians = training_medians, chosen_depth = chosen_depth,
             train = train_survey, test = tree_input$test, audit = tree_input$audit,
             validation = validation_scores, baseline_validation = baseline_validation),
        "outputs/checkpoints/tree-fit.rds")
cat("Saved tree-fit.rds; no tree test score has been calculated.\n")
