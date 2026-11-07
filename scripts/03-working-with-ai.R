# Chapter 3 reference. Save As scripts/my-03-working-with-ai.R before editing.
# run-first-ai-reply adapts an author-reported AI reply: only milk became practice.
# Lesson prompts, follow-ups and the fill-zero reply are teaching examples.
# %% load-practice-data
practice <- read.csv("data/practice_counts.csv", stringsAsFactors = FALSE)
names(practice)
practice
# %% run-first-ai-reply
mean_count_cfu_ml <- round(mean(practice$count_cfu_ml), 2)
mean_count_cfu_ml
# %% summarize-recorded-counts
missing_n <- sum(is.na(practice$count_cfu_ml))
recorded_n <- sum(!is.na(practice$count_cfu_ml))
mean_recorded <- mean(practice$count_cfu_ml, na.rm = TRUE)
summary_table <- data.frame(missing_n, recorded_n, mean_recorded)
summary_table
# %% try-filling-with-zero
# Deliberate error: zero imputation changes this task.
working <- practice
# Find the missing counts in the copy and replace just those positions with zero.
working$count_cfu_ml[is.na(working$count_cfu_ml)] <- 0
bad_mean <- mean(working$count_cfu_ml)
bad_mean
# %% check-zero-fill-result
sum(is.na(practice$count_cfu_ml))
bad_mean == (10 + 20 + 30) / 3
# %% verify-recorded-summary
stopifnot(missing_n == 1, recorded_n == 3, mean_recorded == (10 + 20 + 30) / 3)
stopifnot(is.na(practice$count_cfu_ml[4]))
cat("The requested summary passes; the source observation is still missing.\n")
# %% save-summary-and-log
dir.create("outputs/ch03", recursive = TRUE, showWarnings = FALSE)
write.csv(summary_table, "outputs/ch03/summary.csv", row.names = FALSE)
writeLines(c(paste("First reply result:", mean_count_cfu_ml),
             paste("Fill-zero example result:", bad_mean),
             paste("Recorded measurements:", recorded_n),
             paste("Missing measurements:", missing_n),
             paste("Checked recorded-count mean:", mean_recorded),
             paste("Original fourth count still missing:", is.na(practice$count_cfu_ml[4]))),
           "outputs/ch03/summary-check.txt")
if (!file.exists("outputs/ch03/ai-use-log.txt")) {
  file.copy("templates/ai-use-log.txt", "outputs/ch03/ai-use-log.txt")
}
file.exists("outputs/ch03/summary.csv")
# %% capture-missing-object-error
# Additional practice: restart R and run the load-practice-data block first.
# Select ONLY the mean(...) line to see R stop; then run this supplied block.
runtime_failure <- tryCatch({
  mean(milk_data$count_cfu_ml, na.rm = TRUE)
}, error = function(e) e)
runtime_error_observed <- inherits(runtime_failure, "error")
if (runtime_error_observed) {
  runtime_message <- conditionMessage(runtime_failure)
  cat("Recorded R error: ", runtime_message, "\n", sep = "")
} else {
  runtime_message <- "No R error: the teaching line was edited, or milk_data already exists."
  cat(runtime_message, "\nKeep the original error example for comparison; put your repair in the live-work area.\n", sep = "")
}
# %% use-correct-object-name
runtime_mean <- mean(practice$count_cfu_ml, na.rm = TRUE)
runtime_mean
stopifnot(runtime_mean == (10 + 20 + 30) / 3)
stopifnot(is.na(practice$count_cfu_ml[4]))
# %% save-object-error-record
dir.create("outputs/ch03", recursive = TRUE, showWarnings = FALSE)
writeLines(c(paste("R error observed:", runtime_error_observed),
             paste("Recorded condition:", runtime_message),
             "Correct object: practice",
             paste("Repaired recorded-count mean:", runtime_mean)),
           "outputs/ch03/runtime-error-and-repair.txt")
file.exists("outputs/ch03/runtime-error-and-repair.txt")
# %% live-workspace
# My live AI attempt: first reply
# Add only your AI's first R code here in your my- copy.
# My live AI attempt: revised summary
# Add only your AI's revised R summary here in your my- copy.
# My live AI attempt: object-name repair
# Add only your optional AI object-name repair here in your my- copy.
