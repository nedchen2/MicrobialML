# Complete real-data workflow. Chapters 5-7 are generated from these same cells.
# Open microbial-ml.Rproj; run from the top in a fresh session.
# %% load-milk-data
source("scripts/course_setup.R")
source_file <- fetch_course_data()
milk <- read.csv(source_file, stringsAsFactors = FALSE, na.strings = c("", "NA"))
dim(milk)
names(milk)
stopifnot(identical(names(milk), c("FarmID", "Sampling", "Test", "Conc", "Notes")))
stopifnot(nrow(milk) == 2736)
# %% raw-preview
head(milk, 3)
# %% list-assays
table(milk$Test)
# %% select-msc-records
msc <- milk[milk$Test == "MSC", ]
nrow(msc)
table(msc$Notes, useNA = "ifany")  # Count NA as a category when present.
# %% filter-usable-msc-records
# A note counts as blank if it is missing or empty after trimming spaces.
blank_note <- is.na(msc$Notes) | trimws(msc$Notes) == ""
# is.finite() rules out missing and infinite values. Also require a count above zero.
positive_count <- is.finite(msc$Conc) & msc$Conc > 0
usable <- msc[blank_note & positive_count, ]
rownames(usable) <- NULL
nrow(usable)
length(unique(usable$FarmID))
stopifnot(nrow(usable) == 525)
stopifnot(length(unique(usable$FarmID)) == 102)
stopifnot(anyDuplicated(usable[c("FarmID", "Sampling")]) == 0)
# %% usable-preview
head(usable[c("FarmID", "Sampling", "Conc")], 3)
# %% create-log10-msc
usable$left_censored <- usable$Conc == 0.125
usable$log10_msc <- log10(usable$Conc)
table(usable$left_censored)
stopifnot(sum(usable$left_censored) == 30)
stopifnot(all(is.finite(usable$log10_msc)))
# %% log-intuition
# Invented values for understanding the scale, separate from the real data.
demo_counts <- c(1, 10, 100)
demo_log_mean <- mean(log10(demo_counts))
data.frame(mean_log10 = demo_log_mean,
           inverse_mean_log10_CFU_ml = 10^demo_log_mean,
           arithmetic_mean_CFU_ml = mean(demo_counts))
# %% prepare-audit
audit <- data.frame(check = c("source rows", "raw MSC rows", "excluded lab-error rows",
  "excluded TNTC rows", "excluded other-note rows", "eligible MSC rows",
  "farms", "left-censored encoded rows", "missing eligible counts",
  "duplicate eligible farm-round keys"),
  value = c(nrow(milk), nrow(msc), sum(msc$Notes == "lab error", na.rm = TRUE),
  sum(msc$Notes == "TNTC", na.rm = TRUE), sum(msc$Notes == "other 8-E was 160", na.rm = TRUE),
  nrow(usable), length(unique(usable$FarmID)), sum(usable$left_censored), sum(is.na(usable$Conc)),
  anyDuplicated(usable[c("FarmID", "Sampling")])))
# %% save-prepared
dir.create("outputs/checkpoints", recursive = TRUE, showWarnings = FALSE)
saveRDS(list(data = usable, audit = audit), "outputs/checkpoints/msc-prepared.rds")
file.exists("outputs/checkpoints/msc-prepared.rds")
# %% load-prepared
if (!file.exists("outputs/checkpoints/msc-prepared.rds")) stop("Run Chapter 5 first to create msc-prepared.rds.")
prepared <- readRDS("outputs/checkpoints/msc-prepared.rds")
usable <- prepared$data
stopifnot(nrow(usable) == 525)
# %% split-by-farm
# kind sets how R generates random numbers. sample.kind sets how sample() draws.
# normal.kind applies to draws from a normal distribution.
RNGkind(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
set.seed(2026)  # Set the starting point so sample() can repeat the draw.
farm_ids <- sort(unique(usable$FarmID), method = "radix")  # Sort one ID per farm.
test_farms <- sample(farm_ids, size = ceiling(0.20 * length(farm_ids)))
# %in% checks if a farm is on the test list. ! reverses that check for training.
train <- usable[!usable$FarmID %in% test_farms, ]
test <- usable[usable$FarmID %in% test_farms, ]
c(train_rows = nrow(train), test_rows = nrow(test),
  train_farms = length(unique(train$FarmID)),
  test_farms = length(unique(test$FarmID)))
# %% check-farm-overlap
overlap <- intersect(unique(train$FarmID), unique(test$FarmID))
overlap
stopifnot(length(overlap) == 0)
stopifnot(nrow(train) + nrow(test) == nrow(usable))
# %% save-split
split_audit <- rbind(prepared$audit,
  data.frame(check = "train/test farm overlap", value = length(overlap)))
saveRDS(list(train = train, test = test, farm_ids = farm_ids,
             test_farms = test_farms, audit = split_audit), "outputs/checkpoints/farm-split.rds")
file.exists("outputs/checkpoints/farm-split.rds")
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
# Check the averages by adding the squared or absolute errors and dividing by the row count.
# RMSE takes the square root of that average.
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
