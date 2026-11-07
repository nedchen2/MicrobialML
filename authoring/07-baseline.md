# 7. Learn and evaluate a baseline

**Open:** restart R and save the supplied script as `scripts/my-07-baseline.R`.

**Input:** `outputs/checkpoints/farm-split.rds` from Chapter 6. **Result:** a score table, predictions and a plot you can explain.

## 7.1 Fit one transparent rule

Run the supplied {span .script-block}`BLOCK · load-split` block to restore the training and test tables:

{{r:load-split}}

Compute a mean using **training outcomes only**, then repeat it for each test record:

{span .script-block}`BLOCK · baseline`

{{r:baseline}}

The learned value is about **0.7450 log10 CFU/mL**. Every held-out sample receives it. No weather or management predictors enter this rule.

As in Chapter 5, we take each training concentration's log10 value before averaging. Let $x_i$ be training record $i$'s stored concentration in CFU/mL and let $b$ be the baseline prediction on the log10 scale. Run {span .script-block}`BLOCK · baseline-scale` and match the three output columns to their calculations.

{{r:baseline-scale}}

| R output | Calculation | Result |
|---|---|---:|
| `mean_log10` | Average the log10 values, $b=\frac{1}{420}\sum_{i=1}^{420}\log_{10}(x_i)$. | 0.7450 on the log10 scale |
| `same_prediction_CFU_ml` | Convert the prediction back to a concentration, $10^b$. | 5.56 CFU/mL |
| `arithmetic_mean_CFU_ml` | Average the original concentrations directly, $\frac{1}{420}\sum_{i=1}^{420}x_i$. | 16.78 CFU/mL |

The symbol $\sum$ tells you to add across the training records. The back-transformed prediction, 5.56 CFU/mL, is the geometric mean of the stored concentrations, including the below-limit substitutions.

**Check:** can we replace the log10 prediction 0.7450 with 5.56 when scoring log10 observations? No: observations and predictions must use the same scale.

## 7.2 Read the result table

**Study data.** For each test record, subtract its predicted log10 value from its observed log10 value. Use those residuals in the MAE and RMSE calculations from the [hand example in Chapter 4](04-small-farm-example.ipynb#id-4-4-turn-predictions-into-errors).

{span .script-block}`BLOCK · metrics`

{{r:metrics}}

**How to read these numbers:**

- **105:** the number of held-out test records, from 21 farms. Each record contributes one equally weighted error.
- **RMSE about 0.529; MAE about 0.409:** prediction errors on the **log10** target scale.
- **Their role:** a starting point for evaluating later procedures on an appropriate validation design.

For an observed concentration $a$ and a predicted concentration $p$, both expressed in CFU/mL, the log10 residual measures their ratio on the log10 scale.

$$
\log_{10}(a)-\log_{10}(p)=\log_{10}\!\left(\frac{a}{p}\right).
$$

```{admonition} Invented data — what a log10 residual means
:class: note

For each pair of made-up values, compare the difference in CFU/mL with the ratio.

| Predicted CFU/mL | Observed CFU/mL | Original-scale difference | Observed / predicted | log10 residual |
|---:|---:|---:|---:|---:|
| 10 | 20 | 10 | 2 | about 0.301 |
| 100 | 200 | 100 | 2 | about 0.301 |

Both observations are twice their predictions, so their log10 residuals match even though their concentration differences do not. A log10 residual of 1 corresponds to an observed concentration ten times its prediction; −1 corresponds to one tenth.
```

**Back to the study data.** RMSE 0.529 summarizes the residuals of all 105 test records. It is **not a 52.9% error rate**. Nor does it say every sample has a concentration ratio of `10^0.529`. A single baseline score cannot tell us whether the error is acceptable for an application; that needs a suitable comparison and a defined error requirement.

```{admonition} Invented data — why counting records and counting farms differ
:class: note dropdown

Suppose farm A has one record of 10 CFU/mL and farm B has three records of 30 CFU/mL. Averaging the four records gives 25 CFU/mL. Averaging the two farm means, 10 and 30, gives 20 CFU/mL.
```

In the study results, each record contributes equally to the training mean and the test metrics. Farms with more records therefore contribute more.

## 7.3 Reconstruct one error yourself

Run the supplied {span .script-block}`BLOCK · cross-check-error-metrics` check. It also displays three observed values, predictions and residuals:

{{r:cross-check-error-metrics}}

The first row shows an observed log10 value of 0.8129 and a prediction of 0.7450. Subtract them by hand and compare the result with the printed residual.

$$
e_1\approx 0.8129-0.7450=0.0679.
$$

The printed values are rounded. The code calculates the residuals and scores using full precision.

**Check the scope:** the three printed rows are a preview, not all 105 test records. Run {span .script-block}`BLOCK · rmse-scope`:

{{r:rmse-scope}}

The **preview RMSE of 0.616** uses the three displayed residuals. The **test RMSE of 0.529** uses all 105 residuals. For the test score, $e_i$ denotes the log10 residual for test record $i$.

$$
\mathrm{RMSE}_{\mathrm{test}}=\sqrt{\frac{e_1^2+\cdots+e_{105}^2}{105}}.
$$

## 7.4 Save and inspect the evidence

Select **all remaining supplied blocks**, from {span .script-block}`BLOCK · score-quantified-records` through {span .script-block}`BLOCK · audit-save`, and Run. These are **required supplied blocks**. The target-limit calculation creates objects used by the export, so run it even if you leave the details folded. They then save the outputs. The blocks still run even if you leave their technical details collapsed.

**Required supplied calculation — {span .script-block}`BLOCK · score-quantified-records`:** the same fixed predictions are evaluated on the quantified test subset. This describes another subset; it does not recover true below-detection concentrations or fix that limitation.

{{r:score-quantified-records}}

**File export — {span .script-block}`BLOCK · save-baseline-results`:**

{{r:save-baseline-results}}

**Plot export — {span .script-block}`BLOCK · plot-training-counts`:**

{{r:plot-training-counts}}

![Training log10 MSC distribution with the training mean marked by a vertical line.](../outputs/baseline/training-distribution.png)

The plot is written directly to `outputs/baseline/training-distribution.png`. Open that file in Files; it may not appear in the Plots pane.

**Selection record — {span .script-block}`BLOCK · audit-save`:**

{{r:audit-save}}

| Find in outputs/baseline | What you can check |
|---|---|
| `scores.csv` | The fitted mean and the two error metrics |
| `farm-split.csv` | Which role each farm was assigned |
| `test-predictions.csv` | Observed values, predictions and residuals |
| `training-distribution.png` | Where the learned mean lies in the training distribution |

## 7.5 Write a conclusion that fits the evidence

Write two sentences: name the rule and its test error, then state one important limit. Keep the target scale and held-out setting explicit.

```{admonition} Reference write-up — open after you try
:class: tip dropdown
A training-mean baseline achieved RMSE about 0.529 and MAE about 0.409 log10 CFU/mL on 105 records from 21 held-out farms. This is a fixed-split microbial-quality benchmark; below-detection target substitutions and the represented study setting limit its interpretation. It does not establish a causal effect or a milk-safety decision.
```

Different questions require different evidence:

| Question | What this exercise provides |
|---|---|
| How well does this rule predict MSC for held-out farms in the study? | A baseline error on the stated log10 target and fixed split. |
| Would changing a farm's management reduce MSC? | No intervention evidence; prediction alone does not establish a causal effect. |
| Is a particular bottle of milk safe? | No safety decision; an MSC prediction is not a complete safety assessment. |

**Explain:** why would even a lower predictive RMSE leave the last two questions unanswered?

## 7.6 Check the full score with AI

**Optional live activity:** keep the reference blocks intact. At the end of your my- script, the supplied work area contains comments only until you add code:

{span .script-block}`BLOCK · baseline-live-workspace`

{{r:baseline-live-workspace}}

**Ask AI for code to run locally**, rather than asking it to infer the full score from three pasted rows:

```text
I am using base R. My object test already has 105 held-out records.
Observed log10 values are in test$log10_msc, and fixed predictions are in
test$prediction_log10. Write a small R block to print the row count and
calculate RMSE over ALL 105 rows. Do not refit a model, sample rows,
change the split or modify test. I will run the code locally.
```

In your my- script, find **My AI RMSE check** at the end and add the returned R code below that comment. After completing the earlier required blocks, run only your added lines. The object `test` already exists in this session; this check uses that full table directly. Check that the row count is 105 and RMSE is about 0.529. If you cannot use live chat, inspect this reference calculation and label your route as code inspection:

```r
nrow(test)
sqrt(mean((test$log10_msc - test$prediction_log10)^2))
```

The reference uses every row because neither column is shortened with `head()`. Keep your hand check and actual AI-use record separately from the supplied results.

**Finish:** locate your score, plot and AI-use record, explain one residual, then restart R and run a my- copy of `scripts/worked-example.R` from the beginning. It should recreate the real-data outputs.

**Next:** [could group averages make a useful tree?](08-first-tree.ipynb)
