# Generated from tree-workflow.R for Chapter 08; edit that canonical source as author.
# Students: save a working copy as my-08-first-tree.R; follow the matching page.
# %% tree-load
source("scripts/course_setup.R")
source("scripts/tree_helpers.R")
require_tree_package()
if (!file.exists("outputs/checkpoints/farm-split.rds")) stop("Run Chapter 7 first, or scripts/full-analysis.R, to create the baseline inputs.")
outer_split <- readRDS("outputs/checkpoints/farm-split.rds")
# %% hand-tree
# Invented training values: this is a hand-built illustration, not a fitted rpart model.
hand <- data.frame(pasture_hours = c(0, 4, 12, 16), MSC_CFU_ml = c(1, 1, 100, 100))
hand$log10_msc <- log10(hand$MSC_CFU_ml)
hand
hand_baseline <- mean(hand$log10_msc)
hand_prediction <- ifelse(hand$pasture_hours < 8,
  mean(hand$log10_msc[hand$pasture_hours < 8]), mean(hand$log10_msc[hand$pasture_hours >= 8]))
data.frame(rule = c("One mean", "Two leaf means"),
           training_squared_error_sum = c(sum((hand$log10_msc - hand_baseline)^2),
                                          sum((hand$log10_msc - hand_prediction)^2)))
# %% survey-source
survey <- read_survey_features(fetch_course_survey())
train_survey <- attach_survey(outer_split$train, survey)
test_survey <- attach_survey(outer_split$test, survey)
stopifnot(identical(train_survey$log10_msc, outer_split$train$log10_msc))
stopifnot(identical(test_survey$log10_msc, outer_split$test$log10_msc))
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
# %% save-tree-input
dir.create("outputs/tree", recursive = TRUE, showWarnings = FALSE)
write.csv(predictor_audit, "outputs/tree/predictor-audit.csv", row.names = FALSE)
saveRDS(list(train = train_survey, test = test_survey, audit = predictor_audit),
        "outputs/checkpoints/tree-input.rds")
file.exists("outputs/checkpoints/tree-input.rds")
