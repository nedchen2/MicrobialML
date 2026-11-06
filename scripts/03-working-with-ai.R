# Chapter 3 reference. Save As scripts/my-03-working-with-ai.R before editing.
# The faulty answer below is an explicitly invented teaching response, not a real chat log.
# %% context
practice <- read.csv("data/practice_counts.csv", stringsAsFactors = FALSE)
names(practice)
practice
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
if (!file.exists("outputs/ch03/ai-use-log.txt")) {
  file.copy("templates/ai-use-log.txt", "outputs/ch03/ai-use-log.txt")
}
file.exists("outputs/ch03/summary.csv")
