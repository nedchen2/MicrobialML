# Generated from worked-example.R for Chapter 07; edit that canonical source as author.
# Students: save a working copy as my-07-baseline.R; follow the matching page.
# %% load-split
if (!file.exists("outputs/checkpoints/farm-split.rds")) stop("Run Chapter 6 first to create farm-split.rds.")
split_checkpoint <- readRDS("outputs/checkpoints/farm-split.rds")
train <- split_checkpoint$train
test <- split_checkpoint$test
farm_ids <- split_checkpoint$farm_ids
test_farms <- split_checkpoint$test_farms
# %% baseline
baseline_log10 <- mean(train$log10_msc)
baseline_log10
test$prediction_log10 <- rep(baseline_log10, nrow(test))
stopifnot(all(test$prediction_log10 == mean(train$log10_msc)))
# %% baseline-scale
# Interpret the fixed prediction using training records only; do not refit it.
data.frame(mean_log10 = baseline_log10,
           same_prediction_CFU_ml = 10^baseline_log10,
           arithmetic_mean_CFU_ml = mean(train$Conc))
# %% metrics
test$error_log10 <- test$log10_msc - test$prediction_log10
rmse <- sqrt(mean(test$error_log10^2))
mae <- mean(abs(test$error_log10))
data.frame(model = "Training-mean baseline", n_test = nrow(test),
           RMSE_log10_CFU_ml = rmse, MAE_log10_CFU_ml = mae)
# %% cross-check-error-metrics
rmse_check <- sqrt(sum((test$log10_msc - baseline_log10)^2) / nrow(test))
mae_check <- sum(abs(test$log10_msc - baseline_log10)) / nrow(test)
stopifnot(isTRUE(all.equal(rmse, rmse_check)))
stopifnot(isTRUE(all.equal(mae, mae_check)))
round(data.frame(observed = head(test$log10_msc, 3),
                 predicted = head(test$prediction_log10, 3),
                 residual = head(test$error_log10, 3)), 4)
# %% rmse-scope
# Three displayed records are a preview; the complete score uses all test records.
preview_errors <- head(test$error_log10, 3)
data.frame(records_used = c(length(preview_errors), nrow(test)),
           RMSE_log10 = c(sqrt(mean(preview_errors^2)), rmse))
# %% score-quantified-records
# Evaluation subset only: the baseline is not refitted or chosen using this result.
quantified_test <- test[!test$left_censored, ]
quantified_rmse <- sqrt(mean(quantified_test$error_log10^2))
data.frame(evaluation = c("All eligible test records", "Quantified test records only"),
           n = c(nrow(test), nrow(quantified_test)),
           RMSE_log10_CFU_ml = c(rmse, quantified_rmse))
# %% save-baseline-results
dir.create("outputs/baseline", recursive = TRUE, showWarnings = FALSE)
score <- data.frame(model = "Training-mean baseline", training_mean_log10 = baseline_log10,
                    train_rows = nrow(train), test_rows = nrow(test),
                    train_farms = length(unique(train$FarmID)), test_farms = length(test_farms),
                    RMSE_log10_CFU_ml = rmse, MAE_log10_CFU_ml = mae,
                    quantified_test_n = nrow(quantified_test), quantified_test_RMSE = quantified_rmse)
write.csv(score, "outputs/baseline/scores.csv", row.names = FALSE)
split_table <- data.frame(FarmID = farm_ids,
                         split = ifelse(farm_ids %in% test_farms, "test", "train"))
write.csv(split_table, "outputs/baseline/farm-split.csv", row.names = FALSE)
write.csv(test[c("FarmID", "Sampling", "left_censored", "log10_msc", "prediction_log10", "error_log10")],
          "outputs/baseline/test-predictions.csv", row.names = FALSE)
writeLines(capture.output(sessionInfo()), "outputs/baseline/session-info.txt")
file.exists("outputs/baseline/scores.csv")
# %% plot-training-counts
png("outputs/baseline/training-distribution.png", width = 1200, height = 720, res = 150)
par(mar = c(4.5, 4.5, 2.5, 1), family = "sans", col.axis = "#294943", col.lab = "#294943")
hist(train$log10_msc, breaks = 18, col = "#8cc7b6", border = "white",
     main = "The baseline is learned from training farms",
     xlab = "Training log10 MSC (CFU/mL)", ylab = "Number of records")
abline(v = baseline_log10, col = "#a94c31", lwd = 3)
legend("topright", "Training mean", col = "#a94c31", lwd = 3, bty = "n")
invisible(dev.off())
cat("Saved outputs/baseline/training-distribution.png\n")
# %% audit-save
write.csv(split_checkpoint$audit, "outputs/baseline/data-audit.csv", row.names = FALSE)
cat("All data and baseline checks passed.\n")
# %% baseline-live-workspace
# My AI RMSE check: add your returned R code below in your my- copy.
# Use all rows of test, not just the three-row preview.
