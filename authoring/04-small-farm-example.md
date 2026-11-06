# 4. Six records you can check by hand

**Estimated session:** 25–40 minutes; allow time to explain your reasoning aloud.

| Before running | Your task |
|---|---|
| Input | `data/practice_farms.csv`: six explicitly invented records |
| Working file | Open `scripts/04-small-farm-example.R`; Save As `scripts/my-04-small-farm-example.R` |
| Starting state | Open the project and restart R; no previous objects are needed |
| Stop after | The `toy-save` block |
| Finish with | `outputs/toy/error-table.csv` and a hand calculation |

## 4.1 Read one row before running a model

Every number on this page is invented. One row is one assay result from a farm at a sampling round. The unit is CFU/mL. Here we use the original concentration scale so that we can calculate everything by hand.

| Farm | Sampling round | Invented count |
|---|---|---:|
| A | 1 | 10 |
| A | 2 | 10 |
| B | 1 | 30 |
| B | 2 | 30 |
| C | 1 | 10 |
| C | 2 | 30 |

A1 and A2 come from the same farm at different rounds. They are related observations, even though they occupy separate rows. This is familiar from repeatedly measuring the same biological source.

{{r:toy-read}}

`unique()` returns each distinct label once. We have six records and three farms.

## 4.2 Decide which farm is held out

Before calculating error, we choose C as the test farm. Both C records must stay together. A and B supply training data. This manual choice is for illustration; Chapter 6 will use a fixed random selection of whole farms.

`==` asks “equal to”; `!=` asks “not equal to”. Inside `[rows, columns]`, the empty position after the comma retains all columns.

{{r:toy-split}}

`intersect()` lists shared labels. `character(0)` means no shared labels:

{{r:toy-overlap}}

**Pause:** point to the two test rows in the table before proceeding. We will not use their outcomes to compute the training average.

## 4.3 Why start with one average?

Training counts are 10, 10, 30 and 30. Their sum is 80 across four records, so the training mean is **20 CFU/mL**. Without sample-specific information, we can give both new samples this same transparent prediction. This is a fitted rule with one learned value: a baseline.

`rep(value, times)` repeats a value. We need one prediction for each of the two test rows:

{{r:toy-predict}}

A later model may use more information to improve on this starting point. Complexity alone does not establish an improvement.

## 4.4 Calculate an error before reading its formula

The test measurements are 10 and 30. Subtract the prediction, 20, from each one:

| Observed | Predicted | Residual: observed − predicted | Absolute error | Squared error |
|---:|---:|---:|---:|---:|
| 10 | 20 | −10 | 10 | 100 |
| 30 | 20 | 10 | 10 | 100 |

`abs()` removes the sign; `^2` squares a number. A negative residual means the prediction was above the observed value. It does not mean there was a negative microbial count.

{{r:toy-errors}}

- **MAE:** average the absolute errors: `(10 + 10) / 2 = 10`.
- **RMSE:** average the squared errors, then take the square root: `sqrt((100 + 100) / 2) = 10`. `sqrt()` is the square-root function.

{{r:toy-metrics}}

Both are **10 CFU/mL** in this deliberately symmetric example. They need not be equal for other errors. Neither is an accuracy percentage.

```{admonition} Open after you try: what if the two residuals were −10 and 30?
:class: tip dropdown
MAE would be (10 + 30) / 2 = 20. RMSE would be sqrt((100 + 900) / 2), about 22.36. Squaring makes a larger error contribute more strongly. These are hand-calculation alternatives, not replacement results for our saved six-row table.
```

## 4.5 A split that runs but answers a different question

The following counterexample assigns alternate rows to two sets. `c(1, 3, 5)` supplies row positions. It uses separate `bad_` objects, leaving our correct toy split unchanged:

{{r:toy-wrong-split}}

The overlap contains **A, B and C**. Both sets contain records from every farm. This cannot evaluate prediction for an unseen farm. The code ran; the split did not match the stated prediction setting.

**Ask AI:** paste this six-row table and ask it to explain the difference between the two splits. Require it to list the shared farm labels. Verify its list yourself before accepting the explanation.

## 4.6 Save and explain

{{r:toy-save}}

Open **Files → outputs → toy → error-table.csv**. Check the two residuals against the hand table. Record the file in your completion card.

**Checkpoint 4:** explain why C has two test records, why the prediction is 20, and why the error metrics here have CFU/mL units. The real example will use a log10 target, so its numerical errors cannot be directly compared with these original-scale toy errors.

**Next:** [meet the real milk data](05-meet-real-data.ipynb).
