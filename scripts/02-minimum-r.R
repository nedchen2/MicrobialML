# Chapter 2. Every chapter can run in a fresh R session.
# %% vector
counts <- c(10, 20, 30)
counts
# %% function
mean(counts)
sum(counts) / length(counts)
# %% import
practice <- read.csv("data/practice_counts.csv", stringsAsFactors = FALSE)
practice
# %% structure
dim(practice)
names(practice)
str(practice)
# %% column
practice$count_cfu_ml
class(practice$count_cfu_ml)
# %% missing
is.na(practice$count_cfu_ml)
sum(is.na(practice$count_cfu_ml))
mean(practice$count_cfu_ml)
# %% explicit-missing
mean(practice$count_cfu_ml, na.rm = TRUE)
# %% subset
known_counts <- practice[!is.na(practice$count_cfu_ml), ]
known_counts
# %% factor
handling <- factor(c("routine", "routine", "changed"))
levels(handling)
# %% export
dir.create("outputs/practice", recursive = TRUE, showWarnings = FALSE)
write.csv(known_counts, "outputs/practice/known-counts.csv", row.names = FALSE)
round_trip <- read.csv("outputs/practice/known-counts.csv")
isTRUE(all.equal(known_counts, round_trip, check.attributes = FALSE))
# %% assertion
stopifnot(nrow(practice) == 4)
stopifnot(sum(is.na(practice$count_cfu_ml)) == 1)
stopifnot(mean(known_counts$count_cfu_ml) == 20)
cat("Chapter 2 checks passed.\n")
