# Chapter 3 reference. Save As scripts/my-03-working-with-ai.R before editing.
# The AI replies are invented teaching examples, not a real chat log.
# %% context
practice <- read.csv("data/practice_counts.csv", stringsAsFactors = FALSE)
names(practice)
practice
# %% runtime-error
# To see R stop in the Console, select ONLY the mean(...) line and Run.
# Then run this whole supplied block to capture the error for the lesson record.
# The guard also lets the complete script run through this expected failure.
runtime_failure <- tryCatch({
  mean(milk_data$count_cfu_ml, na.rm = TRUE)
}, error = function(e) e)
stopifnot(inherits(runtime_failure, "error"))
cat("Expected R error: ", conditionMessage(runtime_failure), "\n", sep = "")
# %% runtime-repair
runtime_mean <- mean(practice$count_cfu_ml, na.rm = TRUE)
runtime_mean
stopifnot(runtime_mean == (10 + 20 + 30) / 3)
stopifnot(is.na(practice$count_cfu_ml[4]))
# %% faulty-answer
# Deliberate error: zero imputation changes this task.
working <- practice
working$count_cfu_ml[is.na(working$count_cfu_ml)] <- 0
bad_mean <- mean(working$count_cfu_ml)
bad_mean
# %% inspect-answer
sum(is.na(practice$count_cfu_ml))
bad_mean == (10 + 20 + 30) / 3
# %% repaired-answer
missing_n <- sum(is.na(practice$count_cfu_ml))
recorded_n <- sum(!is.na(practice$count_cfu_ml))
mean_recorded <- mean(practice$count_cfu_ml, na.rm = TRUE)
summary_table <- data.frame(missing_n, recorded_n, mean_recorded)
summary_table
# %% verify-repair
stopifnot(missing_n == 1, recorded_n == 3, mean_recorded == (10 + 20 + 30) / 3)
stopifnot(is.na(practice$count_cfu_ml[4]))
cat("The requested summary passes; the source observation is still missing.\n")
# %% save-evidence
dir.create("outputs/ch03", recursive = TRUE, showWarnings = FALSE)
write.csv(summary_table, "outputs/ch03/summary.csv", row.names = FALSE)
writeLines(c(paste("Expected R error:", conditionMessage(runtime_failure)),
             "Correct object: practice",
             paste("Repaired recorded-count mean:", runtime_mean)),
           "outputs/ch03/runtime-error-and-repair.txt")
if (!file.exists("outputs/ch03/ai-use-log.txt")) {
  file.copy("templates/ai-use-log.txt", "outputs/ch03/ai-use-log.txt")
}
file.exists("outputs/ch03/summary.csv")
