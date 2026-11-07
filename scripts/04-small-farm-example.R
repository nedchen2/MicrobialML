# Chapter 4: six invented records, not observations from the publication.
# Save As scripts/my-04-small-farm-example.R; run blocks in the page order.
# %% load-toy-farm-data
toy <- read.csv("data/practice_farms.csv", stringsAsFactors = FALSE)
toy[c("FarmID", "Sampling")]
stopifnot(nrow(toy) == 6, length(unique(toy$FarmID)) == 3)
# %% toy-split
# Decide to hold out C before calculating a score.
toy_train <- toy[toy$FarmID != "C", ]
toy_test <- toy[toy$FarmID == "C", ]
data.frame(FarmID = c("A", "B", "C"), role = c("train", "train", "test"))
# %% check-toy-farm-overlap
intersect(unique(toy_train$FarmID), unique(toy_test$FarmID))
stopifnot(nrow(toy_train) == 4, nrow(toy_test) == 2)
# %% compare-baseline-guesses
# Compare fixed guesses using training outcomes only.
toy_candidates <- data.frame(guess_CFU_ml = c(10, 20, 30),
  training_squared_error_sum = c(sum((toy_train$count_cfu_ml - 10)^2),
    sum((toy_train$count_cfu_ml - 20)^2), sum((toy_train$count_cfu_ml - 30)^2)))
toy_candidates
# %% toy-predict
toy_mean <- mean(toy_train$count_cfu_ml)
toy_mean
toy_test$prediction <- rep(toy_mean, nrow(toy_test))
# %% toy-errors
toy_test$error <- toy_test$count_cfu_ml - toy_test$prediction
toy_errors <- data.frame(observed = toy_test$count_cfu_ml, predicted = toy_test$prediction,
                         residual = toy_test$error, absolute_error = abs(toy_test$error),
                         squared_error = toy_test$error^2)
toy_errors
# %% toy-metrics
toy_rmse <- sqrt(mean(toy_test$error^2))
toy_mae <- mean(abs(toy_test$error))
data.frame(RMSE_CFU_ml = toy_rmse, MAE_CFU_ml = toy_mae)
# %% toy-leakage
# Deliberately wrong: a separate counterexample, never a replacement model.
wrong_mean <- mean(toy$count_cfu_ml)
wrong_errors <- toy_test$count_cfu_ml - wrong_mean
toy_leakage <- data.frame(rule = c("Training only", "All records: leaks test answers"),
  prediction_CFU_ml = c(toy_mean, wrong_mean),
  MAE_CFU_ml = c(toy_mae, mean(abs(wrong_errors))),
  RMSE_CFU_ml = c(toy_rmse, sqrt(mean(wrong_errors^2))))
toy_leakage
# %% toy-wrong-split
# A separate counterexample; it does not replace toy_train or toy_test.
bad_train <- toy[c(1, 3, 5), ]
bad_test <- toy[c(2, 4, 6), ]
intersect(unique(bad_train$FarmID), unique(bad_test$FarmID))
# %% toy-save
dir.create("outputs/toy", recursive = TRUE, showWarnings = FALSE)
write.csv(toy_errors, "outputs/toy/error-table.csv", row.names = FALSE)
write.csv(toy_candidates, "outputs/toy/training-guesses.csv", row.names = FALSE)
write.csv(toy_leakage, "outputs/toy/leakage-comparison.csv", row.names = FALSE)
stopifnot(toy_mean == 20, isTRUE(all.equal(toy_rmse, sqrt(500))), toy_mae == 20)
stopifnot(length(intersect(toy_train$FarmID, toy_test$FarmID)) == 0)
cat("Toy checks passed: mean 20, MAE 20, RMSE about 22.36; all counts are invented.\n")
