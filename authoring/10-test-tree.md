# 10. Predict, check and explain

**Did the tree improve predictions for the same farms?** Use the final tree from Chapter 9 on the 21 held-out farms. Start with the same milk sample you checked by hand in Chapter 7, then compare both methods on all 105 records.

**Open.** Restart R and save the supplied script as `scripts/my-10-test-tree.R`. This chapter uses `outputs/checkpoints/tree-fit.rds` from Chapter 9. Run the named blocks in order.

## 10.1 Load and read the final tree

Run {span .script-block}`BLOCK · load-rpart` and {span .script-block}`BLOCK · load-tree-fit` to restore the final tree and its training medians. If the checkpoint is missing, complete the save step in Chapter 9.

{{r:load-rpart}}

{span .script-block}`BLOCK · load-tree-fit`

{{r:load-tree-fit}}

Run {span .script-block}`BLOCK · plot-tree`. The diagram is also saved at `outputs/tree/fitted-tree.png`.

{{r:plot-tree}}

![The final tree asks whether the farm has at least 36.5 milking cows. The leaves show the mean log10 MSC and number of training records in each group.](../outputs/tree/fitted-tree.png)

Chapter 9 selected a maximum depth of 1. Look at the fitted tree. **Which input determines the branch? Where does the number in each leaf come from?**

```{admonition} Check your reading of the tree
:class: tip dropdown

The tree splits on milking-cow count. The cutoff of 36.5 separates herds of 36 cows or fewer from herds of 37 or more. The prediction in each leaf is the mean log10 MSC of the training records that reached it.
```

## 10.2 Compare two predictions for one real record

**Study data.** Find **farm R15, sampling round A**. This is the first test record you checked by hand with the baseline in [Section 7.2](07-baseline.ipynb#id-7-2-check-one-prediction-by-hand). The farm had **50 milking cows** that day. Follow the tree diagram to find its leaf and prediction before running the blocks.

Run {span .script-block}`BLOCK · prepare-test` to fill missing test inputs with the saved training medians.

{{r:prepare-test}}

Run {span .script-block}`BLOCK · predict-tree` to make the test predictions.

{{r:predict-tree}}

Run {span .script-block}`BLOCK · trace-one-test-prediction`. Check the farm ID, sampling round and leaf. For R15/A, the recorded cow count and the count used by the model are both **50**. The tree sends the record to **leaf 2**.

{{r:trace-one-test-prediction}}

**Work it out.** The lab result is about **0.8129** on the log10 scale. The baseline predicts **0.7450**, and the tree predicts **0.6873**. For each method, subtract the prediction from the same lab result. Which prediction is closer?

Run {span .script-block}`BLOCK · check-one-test-residual` after you try. Its last column shows both residuals.

{{r:check-one-test-residual}}

The baseline missed by about **+0.0679** and the tree by about **+0.1256**. Both predictions were lower than the measured value. The baseline was closer on this record.

Run {span .script-block}`BLOCK · check-leaves` to see where the tree’s prediction comes from. The **354 training records** that reached leaf 2 have a mean of about **0.6873** on the log10 scale.

{{r:check-leaves}}

## 10.3 Compare all 105 predictions and write a conclusion

**Does the baseline also come closer across the whole test set?** Run {span .script-block}`BLOCK · tree-errors` to repeat your subtraction for every test record.

{{r:tree-errors}}

This block stores the residuals in R. When the Console returns to the `>` prompt, continue to the score table.

Run {span .script-block}`BLOCK · tree-test-scores`. Compare the two rows. Both methods use the same **105 records from 21 test farms**, and both scores use the log10 CFU/mL scale.

{{r:tree-test-scores}}

The baseline has the lower **RMSE** (about **0.529** versus **0.545**) and **MAE** (about **0.409** versus **0.426**). On these held-out records, the training-mean prediction performed better than the tree.

Run {span .script-block}`BLOCK · save-tree-results`. In **Files → outputs → tree**, open `test-scores.csv` and `test-predictions.csv`. The first file gives the comparison. The second lets you find R15/A and check both predictions against its lab result.

{{r:save-tree-results}}

**Write three sentences in English.** Name the candidate inputs and the depth chosen in Chapter 9. Compare the two methods on the test records. Then explain one limitation that matters to the result.

```{admonition} Reference conclusion — open after you try
:class: tip dropdown

We offered pasture hours and milking-cow count as inputs, and five-fold validation within the training farms selected depth 1. On 105 records from 21 held-out farms, the baseline had the lower RMSE, about 0.529 versus 0.545 for the tree on the log10 CFU/mL scale. The tree’s score includes predictions for records whose missing survey inputs were filled with training medians.
```

You have completed the test comparison when you can show the score table and explain your conclusion. Next, save the tree for another prediction and plan how to repeat the workflow with a different model.

## 10.4 Save the model and try a new input

Chapter 9 saved `tree-fit.rds` to carry the fitted tree and the study tables into this chapter. For future predictions, `model.rds` bundles the **fitted tree, training medians and input names**. The medians are part of the prediction process because a new profile can have missing inputs.

Run {span .script-block}`BLOCK · save-model` to write `outputs/tree/model.rds`. Then run {span .script-block}`BLOCK · reload-model` to read it back as `saved_model`.

{{r:save-model}}

{span .script-block}`BLOCK · reload-model`

{{r:reload-model}}

```{admonition} Invented data — try the saved tree on farm profiles
:class: note

The two practice profiles have six hours of pasture time and cow counts of 50 and 30. They have no measured MSC. Use them to see how the saved rule makes predictions.
```

Run {span .script-block}`BLOCK · new-samples`, {span .script-block}`BLOCK · prepare-new` and {span .script-block}`BLOCK · new-predict`. The preparation uses `saved_model$medians`. Prediction uses `saved_model$fit`.

{{r:new-samples}}

{span .script-block}`BLOCK · prepare-new`

{{r:prepare-new}}

{span .script-block}`BLOCK · new-predict`

{{r:new-predict}}

**Change one input.** In your my- copy, change **30 cows to 37** in {span .script-block}`BLOCK · new-samples`. Which side of the cutoff will that profile reach? Rerun **new-samples → prepare-new → new-predict** and check your guess. The last column gives the same prediction in CFU/mL using `10^prediction`.

```{admonition} Check the changed profile
:class: tip dropdown

At 30 cows, the profile reaches leaf 3 and receives about 1.0545 on the log10 scale. At 37 cows it reaches leaf 2, so the prediction becomes about 0.6873.
```

## 10.5 Take this workflow to the next model

Imagine you want to try another model on the milk study. Fill in these four lines before asking AI for code. Use your tree workflow as the example.

| Decision | What to write down |
|---|---|
| **What will I predict?** | What does one row represent? Which column is the answer? Which inputs will be available when I predict? |
| **How will I split the data?** | Which records stay together? Which farms choose settings, and which farms are reserved for the final comparison? |
| **How will the model learn?** | What preparation and fitting steps will I learn from training records? How will I choose any model settings? |
| **How will I compare results?** | Which predictions and lab results will I compare? What will I calculate and save? |

```{admonition} Reference worksheet for the tree
:class: tip dropdown

1. Predict log10 MSC for one farm and sampling round using the two survey inputs available before the lab result, as assumed in this exercise.
2. Keep each farm’s records together. Choose settings within the 81 training farms and reserve 21 farms for testing.
3. Learn missing-input references inside each fitting group. Choose tree depth by validation, then refit on all training farms.
4. Compare the tree and baseline on the same 105 test records using RMSE and MAE. Save the scores and the individual predictions.
```

**Finish.** Keep your `test-scores.csv`, your `test-predictions.csv` with **R15, round A**, your three-sentence English conclusion and your four worksheet answers.

**Optional reproduction exercise.** To replay the full reference analysis, restart R and run a my- copy of `scripts/full-analysis.R`. To check an edit of your own, run the changed blocks in your chapter script.

## 10.6 Optional AI check

Return to the **study data** and ask AI to repeat two familiar operations: fit the tree using the settings chosen in Chapter 9, then predict the same held-out records. Use your my- copy and a browser chat from [AI access](01-first-run.ipynb#id-1-5-ai-access).

Run {span .script-block}`BLOCK · restore-selected-tree-settings` so the chosen settings are available as `selected_settings`.

{{r:restore-selected-tree-settings}}

```text
I am using R and rpart. Fit a numeric regression tree called ai_tree
using train_filled, with log10_msc as the outcome and pasture_hours
and milking_cows as the two inputs. Use method = "anova" and
control = selected_settings. Then use predict() on test_filled and
store the results as ai_prediction. Use the existing split, settings
and prepared tables. Explain which line fits and which predicts.
```

Read the reply before running it. The fitting call should use `train_filled` and `selected_settings`. The prediction call should use `test_filled`. In your my- script, add the returned R code below **My live AI attempt**, then run it and check:

```r
all.equal(as.numeric(ai_prediction), as.numeric(tree_prediction))
```

Matching predictions give **TRUE**. If you see a difference or error, compare the code and output with the supplied blocks. Save your prompt, reply and check in your AI-use log.

**Code-inspection route.** For the same exercise without live chat, find the fitting call in {span .script-block}`BLOCK · fit-tree` in Chapter 9 and the prediction call in {span .script-block}`BLOCK · predict-tree` here. Use the checklist above to explain the role of each table and setting. Record the route as **code inspection**.
