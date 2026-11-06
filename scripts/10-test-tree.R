# Generated from tree-workflow.R for Chapter 10; edit that canonical source as author.
# Students: save a working copy as my-10-test-tree.R; follow the matching page.
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
