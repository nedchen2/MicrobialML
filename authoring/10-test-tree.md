# 10. Predict, check and explain

**Open:** restart R; save the supplied script as `scripts/my-10-test-tree.R`.

**Input:** Chapter 9's saved tree. **Today:** read the learned rule, check its predictions, compare it with the baseline and reuse it on new inputs.

## 10.1 Read the tree before running predictions

Run `prediction-package`, then the supplied `load-tree-fit` block to restore the selected tree and its training preparation:

{{r:prediction-package}}

{{r:load-tree-fit}}

Run the supplied `plot-tree` block. Open `outputs/tree/fitted-tree.png` in Files; the code saves the image directly.

{{r:plot-tree}}

![Selected shallow regression tree. Each final group predicts its own mean training log10 MSC. Counts are training records, not independent farms.](../outputs/tree/fitted-tree.png)

Validation selected depth 1 here, so the final diagram matches Chapter 8's first example. The difference is that we have now checked that depth against two deeper candidates inside training farms.

**Point before you run:**

| Input change | What do you expect from this tree? |
|---|---|
| 50 cows versus 30 cows | Which branch and leaf for each? |
| 50 cows becomes 60 | Does it cross the cut? |
| Only pasture hours changes | Is that variable used anywhere in this tree? |
| 36 cows becomes 37 | Does it cross the cut? |

```{admonition} Open after tracing the branches
:class: tip dropdown
50 and 60 cows both satisfy “at least 36.5”, enter leaf 2 and receive about 0.6873 log10 MSC. 30 and 36 enter leaf 3 and receive about 1.0545; 37 enters leaf 2. Changing pasture hours alone does not change this selected tree's prediction. All records in a leaf receive the same value.
```

The cut separates 36 or fewer from 37 or more cows; it is not a half cow. Pasture hours were offered, but not selected. These are associations learned from the training records, not intervention advice or a safety threshold.

## 10.2 Follow one real record and check its leaf

**Supplied preparation — `prepare-test`:** run this block to give missing test inputs the saved **training** medians. The medians do not change after seeing test inputs.

{{r:prepare-test}}

Run `predict-tree`:

{{r:predict-tree}}

As in Chapter 8, `predict()` follows an existing rule; it does not fit a new one. Although this table contains known lab answers for evaluation, the fitting formula uses only pasture hours and cow count as inputs.

Run the supplied `trace-one` block. First compare recorded inputs with the model's inputs; then read the rule, leaf and prediction:

{{r:trace-one}}

The first record has **50 cows**. On the diagram, follow “Yes” to leaf 2: it predicts about **0.6873 log10 MSC**. The observed answer is about 0.8129, so observed minus predicted is about **0.1256**. Reconstruct that subtraction before looking at an overall score.

Where does 0.6873 come from? Run the supplied `check-leaves` block:

{{r:check-leaves}}

One column calculates each leaf's average from its training records; the other reads the model's prediction. They agree. The 354 training records in leaf 2 supplied its average. The new test record follows the rule but does not join the average or change it.

## 10.3 Compare predictions on the same test records

**Before running:** what evidence would justify the more complicated rule?

Run `tree-errors`. The three lines calculate residuals, RMSE and MAE:

{{r:tree-errors}}

Then run the supplied `tree-test-scores` block to place those scores beside the Chapter 7 baseline:

{{r:tree-test-scores}}

Both methods predict the **same 105 records from the same 21 held-out farms**, on the same log10 scale. Lower errors are better. Tree RMSE is about **0.545**, compared with **0.529** for the baseline; its MAE is also higher. This tree did not improve these test predictions. The baseline was also slightly better in the training-only OOF comparison.

That is an explainable result. Two survey variables and a shallow tree did not earn extra complexity here. It does not show that all trees fail or that the inputs lack biological relevance. Keep the result rather than repeatedly changing the analysis to improve a visible test score. The test split was already displayed in the baseline lesson, so this is a fixed teaching comparison, not a fresh blinded evaluation.

**Supplied evidence export — `save-tree-results`:** run this block to save the comparisons and prediction checks.

{{r:save-tree-results}}

## 10.4 Save, reload and predict new inputs

A reusable prediction needs both the learned tree and the references for preparing missing inputs. A **list** bundles named R objects together; `$fit` later retrieves the item named `fit`.

Run `save-model`. `saveRDS()` writes the bundle to a file:

{{r:save-model}}

Run `reload-model`. `readRDS()` reads it back into R:

{{r:reload-model}}

These operations save and restore a rule, not train another tree.

Run `new-samples` to create the two **invented** input profiles from Chapter 8. Neither has an observed MSC:

{{r:new-samples}}

**Predict first:** at 6 pasture hours, which leaf will 50 cows enter? Which will 30 cows enter?

Run the supplied `prepare-new` block. It applies the saved missing-input rule; neither of these complete rows needs filling.

{{r:prepare-new}}

Run `new-predict`:

{{r:new-predict}}

The predictions are about 0.6873 and 1.0545 log10 MSC, just as the diagram suggests. The last column expresses them as `10^prediction` CFU/mL, as in Chapter 7. It is not an arithmetic-mean concentration or a safety verdict. With no observed outcomes, these two rows provide no accuracy score.

**Change one thing in your my- copy:** in `new-samples`, change 50 cows to 60. Predict whether the result changes. Then rerun **new-samples → prepare-new → new-predict**. Changing the input alone does not automatically refresh an old prediction. Next try 30 cows to 37, or change only pasture hours. Explain each result using the branch, rather than asking AI to invent a biological story. Comparing invented inputs is not an intervention experiment.

## 10.5 Ask AI for two familiar operations

Choose a chat from [AI access](01-first-run.ipynb#id-1-5-ai-access) and use your **my- copy**, keeping the supplied reference script intact. The chat cannot inspect your R session unless you provide its contents.

Give AI this small, explicit task:

> I am using R and rpart. My prepared training data frame is train_filled. The numeric target is log10_msc; the only predictors are pasture_hours and milking_cows. selected_settings already contains my training-validation choice. My prepared held-out data frame is test_filled. Write only the code to fit a numeric regression tree called ai_tree on train_filled, then predict test_filled into ai_prediction. Do not change the settings, split or preparation. Do not use held-out outcomes for fitting or choosing settings. Explain which line learns and which line only predicts.

**Inspect before running:**

| Check in the returned code | Why it matters |
|---|---|
| Fitting `data` is `train_filled` | Hidden answers must not train the model |
| Left of `~` is `log10_msc`; right lists only the two inputs | The answer and farm labels must not become predictors |
| Numeric method and existing `selected_settings` are used | This is the procedure already chosen in training |
| `predict()` uses `newdata = test_filled` | We need predictions for those new rows |

Run `ai-settings` to recreate the settings name in this session:

{{r:ai-settings}}

In your my- script, find the **My live AI attempt** comment at the end. Add the AI code below it, then add this check comparing its predictions with the reference `tree_prediction`. Run your added lines after completing the earlier blocks:

```r
all.equal(as.numeric(ai_prediction), as.numeric(tree_prediction))
```

For an equivalent fit, expect TRUE. If it differs or errors, give AI the actual code and message and investigate; do not change the test answers or invent a successful check. Append the prompt, returned code, your check and any repair to your AI-use log; keep your Chapter 3 record. If you cannot access a chat, inspect the visible `fit-tree` and `predict-tree` blocks and label this as a code-inspection exercise rather than a completed AI interaction.

## 10.6 Keep the evidence and transfer the workflow

| Find in outputs/tree | What it lets you explain |
|---|---|
| `predictor-audit.csv` | Missing survey information and records kept |
| `validation-scores.csv` | Why this depth was selected |
| `test-scores.csv` | Same-record comparison with the baseline |
| `leaf-means.csv` and `nodes.csv` | Where the predictions came from |
| `model.rds` and `example-predictions.csv` | Reuse of the rule and its preparation |

**Write three sentences:** name the inputs and validation choice; compare the two test errors; state one limit. Missing survey answers were filled by a simple assumption, samples repeat within farms, and this split cannot establish performance in another region, causal effects or milk safety.

```{admonition} Reference conclusion — open after writing yours
:class: tip dropdown
A regression tree used pasture hours and milking-cow count, with depth 1 selected by five-fold validation within the training farms. On the same 105 test records from 21 farms, tree RMSE was about 0.545 versus 0.529 for the mean baseline, so the tree did not improve this comparison. Missing-input filling and the study's fixed split limit interpretation; these predictions do not establish causality or milk safety.
```

| Step | When the algorithm changes |
|---|---|
| Define the task | Keep the target, available information and intended new-farm setting explicit |
| Prepare inputs | A new method may need different preparation; learn it inside each fitting partition |
| Fit and choose settings | Replace the fitting function and settings; keep whole-farm training validation |
| Predict and compare | Predict appropriate held-out records, without using their answers to choose the procedure |
| Explain and verify | Keep predictions and checks; a different model needs an explanation suited to its own rules |

**Finish:** save optional changed-input results under another filename if you want to keep them. Restart R and run a my- copy of `scripts/full-analysis.R`; it recreates the supplied reference baseline and tree from the original downloads. Explain which steps you can reuse when requesting another model from AI.
