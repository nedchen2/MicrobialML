# 4. Six records you can check by hand

**Open:** restart R and save the supplied script as `scripts/my-04-small-farm-example.R`.

This is a worked example with **invented counts**, on the original CFU/mL scale. We can inspect every record before using a larger real dataset.

## 4.1 Read the experiment

Run `toy-read`:

{{r:toy-read}}

A row is one farm sampled at one round. A/1 and A/2 share a biological source, even though they occupy different rows. We have six records from three farms.

**Decide before calculating:** hold out farm C. Both its records must stay together. Farms A and B supply the training data.

## 4.2 Make the split match the question

`==` means equal to; `!=` means not equal to. Run `toy-split`:

{{r:toy-split}}

`intersect()` lists shared farm labels:

{{r:toy-overlap}}

**Read `character(0)` as “no shared farm labels.”** Point to the two test records in the input table. Their outcomes will not contribute to the training mean.

## 4.3 Work one prediction by hand

Training counts are **10, 10, 30 and 30**.

1. Sum them: 80.
2. Divide by four records: 20 CFU/mL.
3. Give each held-out sample that prediction.

Run `toy-predict`. `rep()` repeats the prediction once per test row:

{{r:toy-predict}}

This is a fitted rule with one learned value. Later models can be compared with this simple reference.

## 4.4 Turn predictions into errors

For the first test result, **observed 10 − predicted 20 = residual −10**. The prediction was above the observed concentration; the microbial count itself is not negative.

Run the supplied `toy-errors` block to build the two-row calculation table. Expand its code if you want to inspect how the columns are assembled:

{{r:toy-errors}}

**MAE** averages the absolute errors: `(10 + 10) / 2 = 10`.

**RMSE** averages the squared errors and takes their square root: `sqrt((100 + 100) / 2) = 10`.

{{r:toy-metrics}}

Both equal **10 CFU/mL** in this symmetric example. They need not be equal in another dataset, and neither is an accuracy percentage.

```{admonition} Try before opening: residuals −10 and 30
:class: tip dropdown
MAE would be 20. RMSE would be sqrt((100 + 900) / 2), about 22.36. Squaring gives a larger error more influence. These alternative numbers are a hand exercise, not replacement results for the saved six-row table.
```

## 4.5 Challenge a split that runs

Consider this alternative:

| Training rows | Test rows |
|---|---|
| A/1, B/1, C/1 | A/2, B/2, C/2 |

**Your prediction:** which farm labels will occur in both sets?

Run the supplied `toy-wrong-split` counterexample. Its separate objects leave the correct split unchanged:

{{r:toy-wrong-split}}

The shared labels are A, B and C. This tests new records from already represented farms, not the stated task of predicting an unseen farm.

## 4.6 Keep the evidence

Run the supplied `toy-save` block:

{{r:toy-save}}

Find **outputs/toy/error-table.csv**. Explain why C has two test records, why the baseline predicts 20, and how one residual becomes an absolute and a squared error.

**Next:** [the real milk data](05-meet-real-data.ipynb). Its target will use a log10 scale, so its errors cannot be compared numerically with these original-scale toy errors.
