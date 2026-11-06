# 7. Learn and evaluate a baseline

**Estimated session:** 30–45 minutes, plus time to write your interpretation.

| Before running | Your task |
|---|---|
| Input | `outputs/checkpoints/farm-split.rds` from Chapter 6 |
| Working file | Open `scripts/07-baseline.R`; Save As `scripts/my-07-baseline.R` |
| Starting state | Restart R; reload the split in the first block |
| Stop after | Saving audit counts and completing the final checkpoint |
| Finish with | `outputs/baseline/scores.csv`, predictions, plot and a short interpretation |

## 7.1 Load the saved roles

{{r:load-split}}

The container restores the tables called train and test. We will learn from train and evaluate on test. No object from an earlier R session is required.

## 7.2 Fit a rule you can explain


Use **only the training outcomes** to calculate a mean. Every test record receives that same prediction. No weather or management predictors are used in this baseline.

{{r:baseline}}

The prediction is about 0.7450 log10 CFU/mL for every held-out record. Do not calculate the baseline from all 525 outcomes: that would use the test outcomes in the model.


The fitted model here is this one estimated mean, not a set of weather or management coefficients. Every held-out sample receives it. It is useful as a reference against which later procedures can be compared.

## 7.3 Calculate and interpret error


A residual here is **observed minus predicted**. RMSE is the square root of the average squared residual; MAE is the average absolute residual. Both are reported on the log10 CFU/mL scale, and smaller values mean less error.

{{r:metrics}}

These are record-weighted errors on this one held-out set. They are not confidence intervals and do not establish which later model will perform best. This split is used here for a fixed baseline demonstration; later model tuning must use the training portion rather than repeatedly consulting these test results.


Return to the two-row hand table in [Chapter 4](04-small-farm-example.ipynb) if the formulas feel abstract. Here the observed and predicted values are both on the log10 scale. An error of 1 on that scale corresponds to a tenfold concentration ratio; the signs show which value was larger. RMSE 0.529 is **not a 52.9% error rate**, and it should not be described as a typical fold error without further definition.

We have established a starting score on one fixed split. Judging whether it is useful requires the intended application, acceptable errors and comparisons evaluated using an appropriate validation procedure. The current pilot does not establish an application-ready predictor.

## 7.4 Reconstruct before accepting


{{r:independent}}

Use the first displayed row to subtract predicted from observed yourself. The table is rounded for display; the assertions use full precision. The second expressions for RMSE and MAE check the calculation over every test row.

**Ask AI:**

> I split my milk records by FarmID before calculating the training mean of log10 MSC. Write a short base-R check that no farms occur in both train and test, and reconstruct RMSE from the saved observations and predictions. Do not refit the model or change the split. Explain what this check does not establish.

Compare the proposed check with the actual objects and output above. An assistant must not invent a better score or claim that the split proves independence.


## 7.5 Keep the detection-limit caveat visible


The main score includes the encoded below-detection outcomes. As a descriptive sensitivity check, evaluate the **same fixed predictions** on test rows not carrying that flag:

{{r:sensitivity}}

Only one test record has the flag in this split. The second score describes a different subset. It does not estimate error for all unobserved true concentrations, and it does not fix the censoring problem. A later study would examine more suitable censored-data methods and sensitivity analyses.


## 7.6 Save the evidence


{{r:save}}

Open **Files → outputs → baseline**. You should see:

- `scores.csv`: the fitted training mean and evaluation metrics;
- `farm-split.csv`: the saved group assignment;
- `test-predictions.csv`: the held-out observations, predictions and residuals;
- `session-info.txt`: the R environment used for this run.

Create a plot using the training data:

{{r:plot}}

![Distribution of training log10 MSC with the training mean marked by a vertical line.](../outputs/baseline/training-distribution.png)

Export the selection and verification counts:

{{r:audit-save}}


## 7.7 Write a result that matches your run


> Using the prespecified farm-level split, a training-mean baseline predicted held-out log10 MSC with RMSE about 0.529 and MAE about 0.409 log10 CFU/mL. The model used 420 training records and was evaluated on 105 records from 21 other farms. It used no management or weather predictors. Its score depends on this split and the treatment of below-detection values. The result does not establish causality or product safety.

The figures above come from executed code. When your input, split or target changes, regenerate the results and update the text. Do not reuse a paragraph containing stale numbers.

```{admonition} Final checkpoint
:class: tip
Find your my-07 script and saved outputs. Explain the input checkpoint and the training-only mean. Then restart R and run a my- copy of `scripts/worked-example.R` from top to bottom to reconstruct the whole real-data route. Show the zero-overlap result, reconstruct one residual, locate the saved score, and explain why the baseline mean came from training data only.
```

**Transfer exercise:** in a separate copy, use a different seed. Before running, predict which outputs can change and which scientific rules must remain true. Record the original and revised settings; do not pick a seed because it produces a preferred score.

[Download the full R script](../scripts/worked-example.R). The [downloads page](../reference/downloads.md) also contains the complete student project.

```{admonition} Open after you try: reference interpretation
:class: tip dropdown
The supplied split gives RMSE about 0.5289 and MAE about 0.4091 log10 CFU/mL on 105 records from 21 held-out farms. These are errors on the transformed target, not accuracy percentages, confidence intervals, causal effects or milk-safety decisions. The 0.125 source encoding remains a target limitation. A single score does not establish which later model will perform best.
```
