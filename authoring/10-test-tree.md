# 10. Predict, check and explain

**Open:** restart R; save the supplied script as `scripts/my-10-test-tree.R`.

**Input:** Chapter 9's saved tree. **Question:** did the extra complexity earn its place?

## 10.1 Predict without learning from the answers

Run the supplied `load-tree-fit` block:

{{r:load-tree-fit}}

Then run `predict-tree`. The test inputs receive the **saved training medians**. `predict()` applies the fitted tree; it does not refit it:

{{r:predict-tree}}

The baseline still uses the same training mean as Chapter 7. Both methods predict the same 105 records from 21 held-out farms, on the same log10 target scale.

## 10.2 Let the comparison answer the question

**Before running:** what evidence would justify keeping the more complicated rule?

Run `tree-test-scores`:

{{r:tree-test-scores}}

In this supplied example the tree's RMSE is about **0.545**, compared with **0.529** for the baseline. Its MAE is also higher. The added model did **not** improve these test predictions. The baseline was also slightly better in the training-only OOF comparison.

That is a result you can explain. Two survey variables and a shallow tree did not earn extra complexity here; it does not show that all trees fail or that the inputs have no biological relevance. Keep this result rather than repeatedly changing the analysis to improve a now-visible test score. The test split was already displayed in the baseline lesson, so this remains a fixed teaching comparison, not a fresh blinded evaluation.

## 10.3 Check what a leaf actually predicts

Run the supplied `check-leaves` block:

{{r:check-leaves}}

One column recomputes the average outcome from the training records in each leaf; the other reads the fitted tree's prediction. They agree. This is the same averaging idea as the baseline, now applied separately to groups.

Run `trace-one` to follow the first test record. The table shows the recorded inputs and what the model used after any missing-value filling:

{{r:trace-one}}

The supplied tree splits at **36.5 milking cows**. There is no half cow: this separates integer counts of 36 or fewer from 37 or more. The first record has 50 cows, enters leaf 2 and receives its training mean, about 0.6873 log10 MSC.

Pasture hours were offered to the model but were not used in this selected tree. A learned branch is an association in this training data, not advice to change herd size or a safety threshold.

## 10.4 Save, reload and use the model

Run the supplied `save-tree-results` block:

{{r:save-tree-results}}

`outputs/tree/model.rds` stores the fitted tree and training medians together. Keeping both lets new inputs receive the same preparation used by the model.

**Predict first:** the next two input profiles both have 6 pasture hours, but one has 50 cows and the other 30. Which leaf will each enter? These profiles are invented and have no observed MSC, so they cannot be used to calculate predictive accuracy.

Run `new-samples` to reload the saved model and predict:

{{r:new-samples}}

The final column expresses each log10 prediction as `10^prediction` CFU/mL, as in Chapter 7. It does not turn the prediction into an arithmetic-mean concentration or a safety verdict. Comparing these two profiles is not an intervention experiment.

In your **my- copy**, change one input and predict the direction or lack of change before running again. Explain the answer using the branch, rather than asking AI to invent a biological story.

## 10.5 Inspect the tree and keep your evidence

Run the supplied `plot-tree` block, then open the saved image:

{{r:plot-tree}}

![Fitted shallow regression tree. Leaves show mean log10 MSC and the number of training records.](../outputs/tree/fitted-tree.png)

| Find in outputs/tree | What it lets you explain |
|---|---|
| `predictor-audit.csv` | Missing survey information and records kept |
| `validation-scores.csv` | Why this depth was selected |
| `test-scores.csv` | Same-record comparison with the baseline |
| `leaf-means.csv` and `nodes.csv` | Where the predictions came from |
| `model.rds` and `example-predictions.csv` | Reuse of the fitted rule and its preparation |

**Write three sentences:** name the inputs and validation choice; compare the two test errors; state one limit. Missing survey answers were filled by a simple rule, samples repeat within farms, and this split cannot establish performance in a different region, causal effects or milk safety.

## 10.6 Take the workflow to another model

| Step | When the algorithm changes |
|---|---|
| Define the task | Keep the target, available information and intended new-farm setting explicit |
| Prepare inputs | A new method may need different preparation; learn it inside each fitting partition |
| Fit and choose settings | Replace the tree and depth setting; keep whole-farm training validation |
| Predict and compare | Evaluate the chosen procedure on appropriate held-out records, without using their answers to choose it |
| Explain and verify | Keep saved predictions and checks; leaf means are specific to this tree, so other models need their own explanation checks |

**Finish:** save optional changed-input results under a different filename if you want to keep them. Restart R and run a my- copy of `scripts/full-analysis.R`; it recreates the supplied reference baseline and tree workflow from the original source downloads. Explain which parts of the table you could reuse for your next model.
