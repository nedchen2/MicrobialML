# Chapter 4: six invented records, not observations from the publication.
# Save As scripts/my-04-small-farm-example.R; run blocks in the page order.
# %% toy-read
toy <- read.csv("data/practice_farms.csv", stringsAsFactors = FALSE)
toy
stopifnot(nrow(toy) == 6, length(unique(toy$FarmID)) == 3)
# %% toy-split
# Decide to hold out C before calculating a score.
toy_train <- toy[toy$FarmID != "C", ]
toy_test <- toy[toy$FarmID == "C", ]
data.frame(FarmID = c("A", "B", "C"), role = c("train", "train", "test"))
# %% toy-overlap
intersect(unique(toy_train$FarmID), unique(toy_test$FarmID))
stopifnot(nrow(toy_train) == 4, nrow(toy_test) == 2)
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
# %% toy-wrong-split
# A separate counterexample; it does not replace toy_train or toy_test.
bad_train <- toy[c(1, 3, 5), ]
bad_test <- toy[c(2, 4, 6), ]
intersect(unique(bad_train$FarmID), unique(bad_test$FarmID))
# %% toy-save
dir.create("outputs/toy", recursive = TRUE, showWarnings = FALSE)
write.csv(toy_errors, "outputs/toy/error-table.csv", row.names = FALSE)
stopifnot(toy_mean == 20, toy_rmse == 10, toy_mae == 10)
stopifnot(length(intersect(toy_train$FarmID, toy_test$FarmID)) == 0)
cat("Toy checks passed: mean 20, MAE 10, RMSE 10; all counts are invented.\n")
