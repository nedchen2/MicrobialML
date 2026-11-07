# Reference: File > Save As scripts/my-02-minimum-r.R before editing.
# Chapter 2. Every chapter can run in a fresh R session.
# %% make-count-vector
counts <- c(10, 20, 30)
counts
# %% calculate-mean
mean(counts)
sum(counts) / length(counts)
# %% load-practice-data
practice <- read.csv("data/practice_counts.csv", stringsAsFactors = FALSE)
practice
# %% inspect-practice-table
dim(practice)
names(practice)
str(practice)
# %% show-count-column
practice$count_cfu_ml
class(practice$count_cfu_ml)
# %% check-missing-counts
is.na(practice$count_cfu_ml)
sum(is.na(practice$count_cfu_ml))
mean(practice$count_cfu_ml)
# %% mean-of-recorded-counts
mean(practice$count_cfu_ml, na.rm = TRUE)
# %% keep-recorded-rows
known_counts <- practice[!is.na(practice$count_cfu_ml), ]
known_counts
# %% export-known-counts
dir.create("outputs/practice", recursive = TRUE, showWarnings = FALSE)
write.csv(known_counts, "outputs/practice/known-counts.csv", row.names = FALSE)
round_trip <- read.csv("outputs/practice/known-counts.csv")
# Compare the saved values, ignoring details such as R's row labels.
# isTRUE() gives FALSE if all.equal() reports a difference.
isTRUE(all.equal(known_counts, round_trip, check.attributes = FALSE))
# %% check-expected-values
stopifnot(nrow(practice) == 4)
stopifnot(sum(is.na(practice$count_cfu_ml)) == 1)
stopifnot(mean(known_counts$count_cfu_ml) == 20)
cat("Chapter 2 checks passed.\n")
# %% exercise-copy
# Extension exercise: write and read a NEW file; preserve the original input.
changed <- practice
changed$count_cfu_ml[4] <- 40  # Replace the fourth count in the copy.
write.csv(changed, "outputs/practice/practice_counts_changed.csv", row.names = FALSE)
# %% exercise-read
changed <- read.csv("outputs/practice/practice_counts_changed.csv")
data.frame(missing_n = sum(is.na(changed$count_cfu_ml)), mean_count = mean(changed$count_cfu_ml))
# %% exercise-old-rule
old_rule_holds <- sum(is.na(changed$count_cfu_ml)) == 1
old_rule_holds
# %% exercise-check
stopifnot(sum(is.na(changed$count_cfu_ml)) == 0, mean(changed$count_cfu_ml) == 25)
original_again <- read.csv("data/practice_counts.csv")
stopifnot(is.na(original_again$count_cfu_ml[4]))
cat("Changed-copy exercise passed; original input preserved.\n")
