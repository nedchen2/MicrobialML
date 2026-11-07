# Generated from tree-workflow.R for Chapter 08; edit that canonical source as author.
# Students: save a working copy as my-08-first-tree.R; follow the matching page.
# %% tree-package
# If not installed yet, run install.packages("rpart") in the Console once.
library(rpart)
# %% tree-load
source("scripts/course_setup.R")
source("scripts/tree_helpers.R")
if (!file.exists("outputs/checkpoints/farm-split.rds")) stop("Run Chapter 7 first, or scripts/full-analysis.R, to create the baseline inputs.")
outer_split <- readRDS("outputs/checkpoints/farm-split.rds")
dir.create("outputs/tree", recursive = TRUE, showWarnings = FALSE)
# %% hand-data
# Invented records for hand arithmetic, not an rpart fit on four rows.
hand <- data.frame(pasture_hours = c(0, 4, 12, 16), MSC_CFU_ml = c(1, 1, 100, 100))
hand$log10_msc <- log10(hand$MSC_CFU_ml)
hand
# %% hand-mean
hand_baseline <- mean(hand$log10_msc)
hand_baseline
# %% hand-left
left_group <- hand[hand$pasture_hours < 8, ]
left_group
left_mean <- mean(left_group$log10_msc)
left_mean
# %% hand-right
right_group <- hand[hand$pasture_hours >= 8, ]
right_group
right_mean <- mean(right_group$log10_msc)
right_mean
# %% hand-new
new_hours <- 6
hand_new_prediction <- ifelse(new_hours < 8, left_mean, right_mean)
hand_new_prediction
10^hand_new_prediction
# %% hand-errors
hand$two_mean_prediction <- c(left_mean, left_mean, right_mean, right_mean)
one_mean_errors <- hand$log10_msc - hand_baseline
two_mean_errors <- hand$log10_msc - hand$two_mean_prediction
sum(one_mean_errors^2)
sum(two_mean_errors^2)
# %% hand-surprise
# An invented counterexample with a now-known outcome, not a real survey record.
surprise_observed <- log10(100)
surprise_observed - hand_baseline
surprise_observed - hand_new_prediction
# %% survey-source
survey <- read_survey_features(fetch_course_survey())
train_survey <- attach_survey(outer_split$train, survey)
test_survey <- attach_survey(outer_split$test, survey)
stopifnot(identical(train_survey$log10_msc, outer_split$train$log10_msc))
stopifnot(identical(test_survey$log10_msc, outer_split$test$log10_msc))
# %% predictor-preview
head(train_survey[c("pasture_hours", "milking_cows", "log10_msc")], 3)
# %% predictor-audit
predictor_audit <- do.call(rbind, lapply(list(train = train_survey, test = test_survey), function(data) {
  data.frame(records = nrow(data), survey_matched = sum(data$survey_matched),
    survey_unmatched = sum(!data$survey_matched), pasture_hours_missing = sum(is.na(data$pasture_hours)),
    milking_cows_missing = sum(is.na(data$milking_cows)))
}))
predictor_audit$role <- row.names(predictor_audit)
row.names(predictor_audit) <- NULL
predictor_audit <- predictor_audit[c("role", "records", "survey_matched", "survey_unmatched",
                                     "pasture_hours_missing", "milking_cows_missing")]
predictor_audit
stopifnot(nrow(train_survey) == 420, nrow(test_survey) == 105)
stopifnot(length(intersect(train_survey$FarmID, test_survey$FarmID)) == 0)
stopifnot(identical(predictor_audit$survey_unmatched, c(18L, 11L)))
# %% median-example
# Invented predictor values: keep the recorded values unchanged.
recorded_cows <- c(30, 40, NA, 200)
reference_cows <- median(recorded_cows, na.rm = TRUE)
model_cows <- recorded_cows
model_cows[is.na(model_cows)] <- reference_cows
data.frame(recorded = recorded_cows, used_by_model = model_cows)
# %% first-medians
training_medians <- c(
  pasture_hours = median(train_survey$pasture_hours, na.rm = TRUE),
  milking_cows = median(train_survey$milking_cows, na.rm = TRUE)
)
training_medians
# %% first-fill
train_ready <- train_survey
train_ready$pasture_hours[is.na(train_ready$pasture_hours)] <- training_medians[["pasture_hours"]]
train_ready$milking_cows[is.na(train_ready$milking_cows)] <- training_medians[["milking_cows"]]
# %% first-fit
first_settings <- fixed_tree_settings
first_settings$maxdepth <- 1
first_tree <- rpart(log10_msc ~ pasture_hours + milking_cows,
                    data = train_ready, method = "anova", control = first_settings)
# %% first-plot
first_nodes <- extract_tree_nodes(first_tree)
png("outputs/tree/first-tree.png", width = 1200, height = 720, res = 150)
par(mar = c(0, 0, 3, 0), xpd = NA, family = "sans")
draw_teaching_tree(first_tree, first_nodes)
invisible(dev.off())
cat("Saved outputs/tree/first-tree.png\n")
# %% first-inputs
# Invented inputs only: neither row has a known MSC result.
first_inputs <- data.frame(pasture_hours = c(6, 6), milking_cows = c(50, 30))
first_inputs
# %% first-predict
first_predictions <- predict(first_tree, newdata = first_inputs)
data.frame(first_inputs, prediction_log10 = as.numeric(first_predictions))
# %% save-tree-input
write.csv(predictor_audit, "outputs/tree/predictor-audit.csv", row.names = FALSE)
saveRDS(list(train = train_survey, test = test_survey, audit = predictor_audit),
        "outputs/checkpoints/tree-input.rds")
file.exists("outputs/checkpoints/tree-input.rds")
