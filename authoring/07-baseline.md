# 7. Learn and evaluate a baseline

**Open:** restart R and save the supplied script as `scripts/my-07-baseline.R`.

**Input:** `outputs/checkpoints/farm-split.rds` from Chapter 6. **Result:** a score table, predictions and a plot you can explain.

## 7.1 Fit one transparent rule

Run the supplied `load-split` block to restore the training and test tables:

{{r:load-split}}

Compute a mean using **training outcomes only**, then repeat it for each test record:

{{r:baseline}}

The learned value is about **0.7450 log10 CFU/mL**. Every held-out sample receives it. No weather or management predictors enter this rule.

## 7.2 Read the result table

A residual is observed minus predicted. As in the hand example, MAE averages absolute residuals; RMSE averages their squares and takes a square root.

{{r:metrics}}

**How to read these numbers:**

- **105:** the number of held-out test records, from 21 farms. Each record contributes one equally weighted error.
- **RMSE about 0.529; MAE about 0.409:** prediction errors on the **log10** target scale.
- **Their role:** a starting point for evaluating later procedures on an appropriate validation design.

RMSE 0.529 is not a 52.9% error rate. An error of 1 on a log10 scale corresponds to a tenfold concentration ratio, but RMSE should not be relabeled as a typical fold error without further definition. The [two-row hand calculation](04-small-farm-example.ipynb) explains the operations on an easier scale.

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

Before making a stronger claim, ask what comparison, acceptable error or study design it would require. A single baseline score does not establish an application-ready predictor.

**Finish:** locate your score, plot and AI-use record, explain one residual, then restart R and run a my- copy of `scripts/worked-example.R` from the beginning. It should recreate the real-data outputs.
