# Generated from tree-workflow.R for Chapter 10; edit that canonical source as author.
# Students: save a working copy as my-10-test-tree.R; follow the matching page.
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
head(data.frame(observed_log10 = test_filled$log10_msc,
                tree_prediction = as.numeric(tree_prediction)), 3)
# %% trace-one-test-prediction
first_route <- trace_tree(test_filled[1, ], nodes)
data.frame(feature = tree_features, recorded = unlist(chosen$test[1, tree_features], use.names = FALSE),
           used_by_model = unlist(test_filled[1, tree_features], use.names = FALSE))
data.frame(rule = paste(first_route$path, collapse = "; "), leaf = first_route$leaf,
           prediction_log10 = first_route$prediction)
stopifnot(isTRUE(all.equal(first_route$prediction, as.numeric(tree_prediction[1]))))
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
tree_errors <- test_filled$log10_msc - tree_prediction
sqrt(mean(tree_errors^2))
mean(abs(tree_errors))
# %% tree-test-scores
baseline_prediction <- rep(mean(chosen$train$log10_msc), nrow(test_filled))
tree_scores <- data.frame(model = c("Training-mean baseline", "Shallow regression tree"),
  maxdepth = c(0, chosen$chosen_depth), n_test = nrow(test_filled), test_farms = length(unique(test_filled$FarmID)),
  RMSE_log10_CFU_ml = c(sqrt(mean((test_filled$log10_msc - baseline_prediction)^2)), sqrt(mean(tree_errors^2))),
  MAE_log10_CFU_ml = c(mean(abs(test_filled$log10_msc - baseline_prediction)), mean(abs(tree_errors))))
tree_scores[c("model", "RMSE_log10_CFU_ml", "MAE_log10_CFU_ml")]
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
