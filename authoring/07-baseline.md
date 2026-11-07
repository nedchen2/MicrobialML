# 7. Learn and evaluate a baseline

**How far off is one fixed prediction on farms we’ve never seen?** Imagine your lab needs an MSC prediction for each sample from a new farm. Start with one number for every sample. Once the lab results are available, check one prediction yourself and then score the whole set.

**Open.** Restart R and save the supplied script as `scripts/my-07-baseline.R`. This chapter uses `outputs/checkpoints/farm-split.rds` from Chapter 6. In your script, run the named blocks in order.

## 7.1 Make one prediction before seeing the results

Run {span .script-block}`BLOCK · load-split` to restore the training and test tables. If the checkpoint is missing, complete Chapter 6’s save step first.

{{r:load-split}}

Average log10 MSC across the **420 training records** to get your baseline. Run {span .script-block}`BLOCK · baseline`:

{{r:baseline}}

Write down **0.7450 on the log10 scale**. That is the prediction for every test record. The line with `rep()` repeats the same number once per row of `test`. The training results set this number. The test results will tell you how far it misses.

```{admonition} Study data — express the prediction in CFU/mL
:class: note dropdown

The training table already has one log10 value per record. The baseline averages those log10 values. Raising 10 to that average gives the same prediction in the original units.

| Calculation | Result |
|---|---:|
| Average the 420 log10 concentrations | 0.7450 on the log10 scale |
| Convert the prediction back with $10^{0.7450}$ | 5.56 CFU/mL |
| Average the 420 original concentrations directly | 16.78 CFU/mL |

The first two rows give the same prediction in two units. The third row averages on the original scale. When you score a prediction, keep the observed and predicted values on the same scale.
```

## 7.2 Check one prediction by hand

**Study data.** Run {span .script-block}`BLOCK · first-test-record` to see the first test record’s lab result beside its prediction. Both values are on the log10 scale.

{{r:first-test-record}}

Subtract **observed minus predicted** on paper. Before opening the answer, decide whether the prediction was too high or too low.

```{admonition} Check your hand calculation
:class: tip dropdown

$$
e_1 \approx 0.8129 - 0.7450 = 0.0679.
$$

The residual is positive because the lab result was higher than the prediction. The displayed inputs are rounded to four decimal places. R uses their full precision when it scores all the records.
```

## 7.3 Score all 105 predictions

**Study data.** Run {span .script-block}`BLOCK · metrics`. The first line repeats your subtraction for every row in `test`. The next two lines summarize those 105 residuals using the [MAE and RMSE calculations from Chapter 4](04-small-farm-example.ipynb#id-4-4-turn-predictions-into-errors).

{{r:metrics}}

| In the result table | What to say |
|---|---|
| **105 test records** | All 105 records from the 21 held-out farms contribute to the score. |
| **MAE ≈ 0.409** | The average size of a miss is about 0.409 on the log10 scale, regardless of direction. |
| **RMSE ≈ 0.529** | Squaring the residuals gives larger misses more influence. Taking the square root brings the score back to the log10 scale. |

Use these scores as the reference when Chapter 10 compares predictions on the same held-out records. You can also run {span .script-block}`BLOCK · cross-check-error-metrics` to recompute both scores by dividing each sum by the record count. This check is silent when the values agree.

{{r:cross-check-error-metrics}}

```{admonition} Invented data — what a log10 residual means
:class: note dropdown

Compare the difference in CFU/mL with the ratio in these two made-up cases.

| Predicted CFU/mL | Observed CFU/mL | Difference in CFU/mL | Observed / predicted | log10 residual |
|---:|---:|---:|---:|---:|
| 10 | 20 | 10 | 2 | about 0.301 |
| 100 | 200 | 100 | 2 | about 0.301 |

The observations are both twice their predictions. Their log10 residuals are therefore the same. For an observed concentration $a$ and a predicted concentration $p$:

$$
\log_{10}(a)-\log_{10}(p)=\log_{10}\!\left(\frac{a}{p}\right).
$$
```

```{admonition} Invented data — why counting records and counting farms differ
:class: note dropdown

Suppose farm A has one record of 10 CFU/mL and farm B has three records of 30 CFU/mL. Averaging the four records gives 25 CFU/mL. Averaging the two farm means, 10 and 30, gives 20 CFU/mL.
```

**Back to the study data.** Each record contributes equally to the score, so a farm with more records contributes more. The RMSE of 0.529 is an error on the log10 scale, with each residual calculated separately before summarizing.

## 7.4 Save the evidence and write two sentences

In RStudio, select and run the supplied blocks from {span .script-block}`BLOCK · score-quantified-records` through {span .script-block}`BLOCK · audit-save`. The first block checks how the same predictions score on records with quantified MSC. Run it even if you leave its details folded. The export uses its result.

{{r:score-quantified-records}}

{span .script-block}`BLOCK · save-baseline-results`

{{r:save-baseline-results}}

{span .script-block}`BLOCK · plot-training-counts`

{{r:plot-training-counts}}

{span .script-block}`BLOCK · audit-save`

{{r:audit-save}}

Open the files below from **Files → outputs → baseline**.

| File | What you can check |
|---|---|
| `scores.csv` | The fitted mean, test counts, MAE and the two RMSE columns described below |
| `test-predictions.csv` | The observed value, prediction and residual for each test record |
| `farm-split.csv` | Which farms went into training and which went into testing |
| `training-distribution.png` | Where the prediction falls in the training distribution. Open the saved image directly. |

In `scores.csv`, **`RMSE_log10_CFU_ml` is about 0.529** for all **105** test records. **`quantified_test_RMSE` is about 0.506** for the **104** records with quantified MSC. The second calculation leaves out the one test record whose value was stored as a below-limit substitute. Chapter 10 compares both models on all **105** records.

```{admonition} Preview the saved plot
:class: note dropdown

![Training log10 MSC distribution with the training mean marked by a vertical line.](../outputs/baseline/training-distribution.png)
```

**Write two sentences in English.** First, report what you predicted, which records you tested on and the scores with their scale. Then say what limits the interpretation. Think about the study setting or the below-detection values described in Chapter 5.

```{admonition} Reference write-up — open after you try
:class: tip dropdown

A baseline that predicted the training mean achieved RMSE of about 0.529 and MAE of about 0.409 on the log10 CFU/mL scale across 105 records from 21 held-out farms. These scores describe prediction of recorded MSC in this study, including the stored substitutes for below-detection results.
```

**Finish.** Find the first record’s residual in `test-predictions.csv` and the two scores in `scores.csv`. You are ready to move on when you can explain how one became part of the other.

## 7.5 Optional AI check

Ask AI for code to verify your RMSE using the full table in your R session. Keep the supplied blocks intact. In your my- script, use {span .script-block}`BLOCK · baseline-live-workspace`, the comment-only block at the end.

{{r:baseline-live-workspace}}

```text
I am using base R. My object test contains 105 held-out records.
Observed log10 values are in test$log10_msc and fixed predictions
are in test$prediction_log10. Write code to print the row count and
calculate RMSE over all 105 rows. Use the existing table and
predictions as they are. I will run the code locally.
```

Read the reply before running it. Find the line that counts the rows and the line that calculates RMSE. Both columns in that calculation should come from the complete `test` table. Add the code below **My AI RMSE check** and run only your added lines. Look for **105** and an RMSE of about **0.529**.

```{admonition} Reference code for self-study
:class: tip dropdown

~~~r
nrow(test)
sqrt(mean((test$log10_msc - test$prediction_log10)^2))
~~~

If you use this route, record it as code inspection in your AI-use log. If you use live chat, record your actual prompt, reply and check.
```

**Next.** [Could group averages make a useful tree?](08-first-tree.ipynb)
