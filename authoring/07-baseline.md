# 7. Learn and evaluate a baseline

**Open:** restart R and save the supplied script as `scripts/my-07-baseline.R`.

**Input:** `outputs/checkpoints/farm-split.rds` from Chapter 6. **Result:** a score table, predictions and a plot you can explain.

## 7.1 Fit one transparent rule

Run the supplied `load-split` block to restore the training and test tables:

{{r:load-split}}

Compute a mean using **training outcomes only**, then repeat it for each test record:

{{r:baseline}}

The learned value is about **0.7450 log10 CFU/mL**. Every held-out sample receives it. No weather or management predictors enter this rule.

**Connect it to Chapter 5:** the invented example's mean log10 prediction was 1, equivalent to `10^1 = 10` CFU/mL. Here it is 0.7450, equivalent to `10^0.7450`, about **5.56 CFU/mL**.

Run the supplied `baseline-scale` block. It compares three calculations from the same training records:

{{r:baseline-scale}}

The original-scale arithmetic mean is about **16.78 CFU/mL**. The inverse log10 mean, 5.56, is the geometric mean of the stored training concentrations, including the below-limit substitutions. It expresses our fixed log10 prediction on another scale. If a future task asks for the average concentration on the original scale, this conversion alone does not answer it.

**Check:** can we replace the log10 prediction 0.7450 with 5.56 when scoring log10 observations? No: observations and predictions must use the same scale.

## 7.2 Read the result table

A residual is observed minus predicted. As in the hand example, MAE averages absolute residuals; RMSE averages their squares and takes a square root.

{{r:metrics}}

**How to read these numbers:**

- **105:** the number of held-out test records, from 21 farms. Each record contributes one equally weighted error.
- **RMSE about 0.529; MAE about 0.409:** prediction errors on the **log10** target scale.
- **Their role:** a starting point for evaluating later procedures on an appropriate validation design.

To give a log10 residual some meaning, compare two invented predictions:

| Predicted CFU/mL | Observed CFU/mL | Original-scale difference | Observed / predicted | log10 residual |
|---:|---:|---:|---:|---:|
| 10 | 20 | 10 | 2 | about 0.301 |
| 100 | 200 | 100 | 2 | about 0.301 |

Both observations are twice their predictions, so their log10 residuals match even though their concentration differences do not. A log10 residual of 1 corresponds to an observed concentration ten times its prediction; −1 corresponds to one tenth.

RMSE 0.529 summarizes many residuals; it is **not a 52.9% error rate**. Nor does it say every sample has a concentration ratio of `10^0.529`. A single baseline score cannot tell us whether the error is acceptable for an application; that needs a suitable comparison and a defined error requirement.

```{admonition} Why a record and a farm can have different weights
:class: tip dropdown
Invented example: farm A has one record of 10, and farm B has three records of 30 CFU/mL. Averaging all records gives 25. Averaging the two farm means, 10 and 30, gives 20. These use different weights. Here each record contributes equally to the training mean and the test metrics; farms with more records therefore contribute more. Holding out whole farms does not itself give every farm equal weight.
```

## 7.3 Reconstruct one error yourself

Run the supplied `independent` check. It also displays three observed values, predictions and residuals:

{{r:independent}}

Choose the first row. Subtract predicted from observed by hand and compare with its residual. Display rounding can cause a small difference; the automated check uses full precision.

**Ask AI:** give it the actual columns and your hand calculation. Ask it to reconstruct RMSE without refitting the model or changing the split. Compare its answer with your saved observations and predictions.

## 7.4 Save and inspect the evidence

Select **all remaining supplied blocks**, from `sensitivity` through `audit-save`, and Run. They perform an additional target-limit check and save the outputs. The blocks still run even if you leave their technical details collapsed.

**Additional check — `sensitivity`:** the same fixed predictions are evaluated on the quantified test subset. This describes another subset; it does not recover true below-detection concentrations or fix that limitation.

{{r:sensitivity}}

**File export — `save`:**

{{r:save}}

**Plot export — `plot`:**

{{r:plot}}

![Training log10 MSC distribution with the training mean marked by a vertical line.](../outputs/baseline/training-distribution.png)

The plot is written directly to `outputs/baseline/training-distribution.png`. Open that file in Files; it may not appear in the Plots pane.

**Selection record — `audit-save`:**

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

**Finish:** locate your score, plot and AI-use record, explain one residual, then restart R and run a my- copy of `scripts/worked-example.R` from the beginning. It should recreate the real-data outputs.
