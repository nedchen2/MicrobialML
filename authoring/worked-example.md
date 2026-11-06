# Worked example: from data to a baseline

**Time:** about 45-60 minutes. **Before you start:** complete Chapters 0-3, open `microbial-ml.Rproj`, and restart R. Open `scripts/worked-example.R`.

**Question:** what error do we get if we predict the log10 mesophilic spore count of each held-out milk sample using only the average from training farms?

This is a complete prediction workflow, even though its model is deliberately simple. It gives later models an honest reference. We have not yet tested whether farm management or weather improves it.

## A. Know the target before touching the data

MSC means **mesophilic spore count**, measured here in CFU/mL. One row in our selected data will be one MSC assay result for one farm and sampling round. A farm can have several rows.

We use the original assay table linked by [Qian et al. (2025)](https://doi.org/10.1016/j.jfp.2025.100477). We exclude records carrying a note and require a positive, finite concentration. This produces 525 records, matching the paper's reported MSC sample size. These are explicit rules for this teaching slice, not a claim to reproduce every step in the paper.

The [data audit](../reference/data-audit.md) explains the source version, exclusions and detection limit. The four-row practice table in Chapter 2 was invented; this table contains real published research data.

## B. Download once and inspect

**Where: RStudio script.** The supplied helper downloads a fixed author-file version, verifies its checksum and caches it. It uses base R; no package installation is needed. Read `scripts/course_setup.R` if you want to inspect the download code. The helper does not fit a model.

{{r:source}}

The expected shape is **2,736 rows and 5 columns**. `na.strings = c("", "NA")` tells R how missing text is encoded in this file. If the shape or names differ, stop and investigate; do not simply change the assertions to make them pass.

| Column | Meaning and role |
|---|---|
| `FarmID` | Farm identifier; used to keep groups together |
| `Sampling` | Sampling-round label; helps identify a farm-round record |
| `Test` | Assay type; different assays must not be mixed into one outcome |
| `Conc` | The assay-specific concentration; units depend on `Test` |
| `Notes` | Laboratory notes affecting eligibility |

Inspect the assay types:

{{r:assays}}

The whole file is not one homogeneous training table. We first select a specific test.

## C. Select one assay and make quality rules explicit

{{r:select}}

There are 562 raw MSC records: 525 have no note, 34 are marked laboratory error, two are marked `TNTC` (too numerous to count), and one has another note. A count marked `TNTC` is not an ordinary quantified value. The other note has not been resolved independently, so this pilot excludes it rather than interpreting it silently.

In the next block, `trimws()` removes surrounding spaces from notes and `is.finite()` checks that a numerical value is neither missing nor infinite. `&` means both conditions must hold; `|` means either can hold. The filtering rule is chosen for data quality, before looking at prediction scores.

{{r:quality}}

You should get **525 eligible records from 102 farms**. The checks also confirm that a farm-round occurs only once in this selected assay. Excluding flagged records can affect representativeness; retain an audit of what was excluded and why.

## D. Define the outcome and its limits

The paper reports replacing below-detection MSC values by **25% of a 0.5 CFU/mL detection limit**: 0.125 CFU/mL. We preserve that encoded value and flag it. We do not call it a precise observed concentration.

{{r:target}}

Thirty eligible records have this encoded value. The other 495 are above it. The equality flag identifies this source's published encoding; it is not a general method for discovering detection limits in arbitrary data.

We predict `log10_msc`, the base-10 logarithm of the concentration:

{{r:log-intuition}}

Log10 values 0, 1 and 2 correspond to 1, 10 and 100 CFU/mL. A negative log value can represent a positive concentration below 1 CFU/mL. It is not a negative number of organisms.

Notice that averaging on the log scale and back-transforming gives about 31.62 for 10 and 100, whereas their arithmetic mean is 55. Our model predicts on the log scale; exponentiating its mean does not automatically estimate the mean on the original count scale.

## E. Hold out farms before learning the baseline

We are asking about a sample from a farm not used to learn the predictor. We therefore hold out whole farms. The seed makes the random selection reproducible; sorting provides a stable starting order. `ceiling()` rounds upward, so 20% of 102 farms gives 21 test farms.

`unique()` lists each farm once. `%in%` asks whether a farm belongs to the selected test list, and `!` reverses that answer for the training set. The supplied `RNGkind()` line fixes random-generator settings for reproducibility; you can use it as given without memorizing its arguments.

{{r:split}}

The supplied split has 420 training records from 81 farms and 105 test records from 21 farms. The record fraction does not need to be exactly 20%, because the groups differ in size.

Check the actual groups, not just the row counts:

{{r:overlap}}

`character(0)` means the intersection is empty. If it contains any farm identifier, fix the split before fitting or reporting error.

```{warning} Why not split rows at random?
Rows from one farm are related. Letting the procedure learn from a farm and then testing it on that same farm answers a different question from generalizing to unseen farms. Grouping by farm addresses this particular overlap; it does not eliminate every source of dependence or guarantee future performance.
```

## F. Learn the simplest baseline

Use **only the training outcomes** to calculate a mean. Every test record receives that same prediction. No weather or management predictors are used in this baseline.

{{r:baseline}}

The prediction is about 0.7450 log10 CFU/mL for every held-out record. Do not calculate the baseline from all 525 outcomes: that would use the test outcomes in the model.

## G. Evaluate on held-out records

A residual here is **observed minus predicted**. RMSE is the square root of the average squared residual; MAE is the average absolute residual. Both are reported on the log10 CFU/mL scale, and smaller values mean less error.

{{r:metrics}}

These are record-weighted errors on this one held-out set. They are not confidence intervals and do not establish which later model will perform best. This split is used here for a fixed baseline demonstration; later model tuning must use the training portion rather than repeatedly consulting these test results.

## H. Reconstruct the calculations

{{r:independent}}

Use the first displayed row to subtract predicted from observed yourself. The table is rounded for display; the assertions use full precision. The second expressions for RMSE and MAE check the calculation over every test row.

**Ask AI:**

> I split my milk records by FarmID before calculating the training mean of log10 MSC. Write a short base-R check that no farms occur in both train and test, and reconstruct RMSE from the saved observations and predictions. Do not refit the model or change the split. Explain what this check does not establish.

Compare the proposed check with the actual objects and output above. An assistant must not invent a better score or claim that the split proves independence.

## I. Keep the detection-limit caveat visible

The main score includes the encoded below-detection outcomes. As a descriptive sensitivity check, evaluate the **same fixed predictions** on test rows not carrying that flag:

{{r:sensitivity}}

Only one test record has the flag in this split. The second score describes a different subset. It does not estimate error for all unobserved true concentrations, and it does not fix the censoring problem. A later study would examine more suitable censored-data methods and sensitivity analyses.

## J. Save evidence, not just an AI conversation

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

## K. Write a restrained result

> Using the prespecified farm-level split, a training-mean baseline predicted held-out log10 MSC with RMSE about 0.529 and MAE about 0.409 log10 CFU/mL. The model used 420 training records and was evaluated on 105 records from 21 other farms. It used no management or weather predictors. Its score depends on this split and the treatment of below-detection values. The result does not establish causality or product safety.

The figures above come from executed code. When your input, split or target changes, regenerate the results and update the text. Do not reuse a paragraph containing stale numbers.

```{admonition} Final checkpoint
:class: tip
Restart R and run `scripts/worked-example.R` from top to bottom. Show the zero-overlap result, reconstruct one residual, locate the saved score, and explain why the baseline mean came from training data only.
```

**Transfer exercise:** in a separate copy, use a different seed. Before running, predict which outputs can change and which scientific rules must remain true. Record the original and revised settings; do not pick a seed because it produces a preferred score.

[Download the full R script](../scripts/worked-example.R). The [downloads page](../reference/downloads.md) also contains the complete student project.
