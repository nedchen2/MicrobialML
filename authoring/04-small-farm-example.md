# 4. Six records you can check by hand

**Open:** restart R and save the supplied script as `scripts/my-04-small-farm-example.R`.

This is a worked example with **invented counts**, on the original CFU/mL scale. We can inspect every record before using a larger real dataset.

## 4.1 Read the experiment

Run `toy-read` to display the farm and round labels. Leave farm C's concentrations out of the calculation until you have written your prediction:

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

Imagine a new milk sample arrives, but you have no sample-specific information to use yet. You can still make a prediction: give every new sample the same number, learned from earlier samples. This is a **constant baseline**. It is a comparison point, not a safe concentration or a pass/fail threshold.

Training counts are **10, 10, 30 and 30**. Why guess 20 rather than 10 or 30? First compare these guesses using the training results. For each record, square observed minus guessed, then add the four squares.

Run the supplied `toy-guess` block:

{{r:toy-guess}}

The sums are **800, 400 and 800**. The guess 20 does better than the other two. When one constant is used and squared error is the criterion, the training mean minimizes that training error. This does not make it the best possible model.

Calculate that mean:

1. Sum them: 80.
2. Divide by four records: 20 CFU/mL.
3. Give each held-out sample that prediction.

Run `toy-predict`. `rep()` repeats the prediction once per test row:

{{r:toy-predict}}

**Write down 20 before opening the test results.** This is a fitted rule with one learned value; a sample's unknown answer does not help choose its prediction.

## 4.4 Turn predictions into errors

Now reveal farm C: the observed concentrations are **30 and 50 CFU/mL**. For the first result, **observed 30 − predicted 20 = residual 10**: we predicted 10 CFU/mL too low.

Run the supplied `toy-errors` block to build the two-row calculation table. Expand its code if you want to inspect how the columns are assembled:

{{r:toy-errors}}

The residuals are 10 and 30; their squares are 100 and 900. Match the arithmetic to R's notation:

| R expression | Meaning | Result |
|---|---|---:|
| `abs(-10)` | Absolute value: distance from zero | 10 |
| `10^2` | Square 10 | 100 |
| `sqrt(100)` | Square root of 100 | 10 |

**MAE** averages the absolute errors: `(10 + 30) / 2 = 20`.

**RMSE** averages the squared errors and takes their square root: `sqrt((100 + 900) / 2)`, about **22.36**. The larger error contributes more strongly after squaring.

{{r:toy-metrics}}

Both final metrics have units of **CFU/mL** here; neither is an accuracy percentage. The squared-error column has squared units, which the square root removes in RMSE.

```{admonition} A zero average residual can hide mistakes
:class: tip
In a separate invented pair, predict 20 for observations 10 and 30. The residuals are −10 and 10. Their signed average is zero, but both predictions are wrong by 10. A negative residual means the prediction was too high, not that the microbial concentration was negative. MAE and RMSE prevent those opposite errors from cancelling.
```

## 4.5 Challenge an answer that looks better

**Predict first:** what happens if someone averages all six concentrations, including C's answers?

Run the deliberately wrong `toy-leakage` example. Its separate objects leave the correct predictions unchanged:

{{r:toy-leakage}}

The all-record mean is **26.67**, and its apparent test RMSE falls from **22.36 to 16.67**. That looks better only after using answers that should have been held out. It is not evidence of better prediction for unseen samples. This is **data leakage**. It need not change the score in every dataset, so also inspect where the fitted value came from.

There is another way a procedure can answer the wrong question. Consider this alternative split:

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

Find **outputs/toy/error-table.csv**. The other two CSVs save the training-guess and leakage comparisons. Explain why C has two test records, why its answers must not choose the prediction, and why MAE and RMSE differ here.

**Next:** [the real milk data](05-meet-real-data.ipynb). Its target will use a log10 scale, so its errors cannot be compared numerically with these original-scale toy errors.
