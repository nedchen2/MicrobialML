# 4. Six records you can check by hand

**Open:** restart R and save the supplied script as `scripts/my-04-small-farm-example.R`.

This is a worked example with **invented counts**, on the original CFU/mL scale. We can inspect every record before using a larger real dataset.

## 4.1 Read the experiment

Run {span .script-block}`BLOCK · load-toy-farm-data` to display the farm and round labels. Leave farm C's concentrations out of the calculation until you have written your prediction:

{{r:load-toy-farm-data}}

A row is one farm sampled at one round. A/1 and A/2 share a biological source, even though they occupy different rows. We have six records from three farms.

**Decide before calculating:** hold out farm C. Both its records must stay together. Farms A and B supply the training data.

## 4.2 Make the split match the question

`==` means equal to; `!=` means not equal to. Run {span .script-block}`BLOCK · toy-split`:

{{r:toy-split}}

`intersect()` lists shared farm labels:

{span .script-block}`BLOCK · check-toy-farm-overlap`

{{r:check-toy-farm-overlap}}

**Read `character(0)` as “no shared farm labels.”** Point to the two test records in the input table. Their outcomes will not contribute to the training mean.

## 4.3 Work one prediction by hand

A **baseline** is a simple prediction rule that gives later models something to beat. Compare their errors on the same held-out samples using the same error measure. If a later model has a smaller error, it predicts better on that test.

**Our rule.** Take the mean of the four training measurements from farms A and B. Give that same prediction to both samples from farm C. We call this a **constant baseline** because it gives every test sample the same value.

**Why use the mean?** The training measurements are **10, 10, 30 and 30 CFU/mL**. Let $g$ be one possible prediction for all four. Subtract $g$ from each measured value, square each difference, and add the results to get the total squared error $S(g)$.

$$
S(g) = (10-g)^2 + (10-g)^2 + (30-g)^2 + (30-g)^2.
$$

For a guess of 20, the differences are $-10$, $-10$, $10$ and $10$. Each contributes 100 after squaring, so $S(20) = 400$.

Run the supplied {span .script-block}`BLOCK · compare-baseline-guesses` block:

{{r:compare-baseline-guesses}}

The guesses **10, 20 and 30** give totals of **800, 400 and 800**, respectively. To see why 20 also works best among all constant guesses for these training records, rewrite the same sum.

$$
S(g) = 2(10-g)^2 + 2(30-g)^2 = 400 + 4(g-20)^2.
$$

The smallest possible value of the squared term is zero, which occurs at $g=20$. This is the training mean.

$$
\text{Training mean} = \frac{10 + 10 + 30 + 30}{4} = 20\ \text{CFU/mL}.
$$

Run {span .script-block}`BLOCK · toy-predict`. `rep()` repeats the prediction once per test row:

{{r:toy-predict}}

**Write down 20 for both samples from farm C before opening their test results.** In the next section, you will use those results to measure the baseline's test error.

## 4.4 Turn predictions into errors

Farm C's observed concentrations are **30 and 50 CFU/mL**. For test record $i$, let $y_i$ be its observed value and $\hat y_i$ be its predicted value. The **residual** $e_i$ is the observed value minus the prediction.

$$
e_i = y_i-\hat y_i, \qquad e_1=30-20=10, \qquad e_2=50-20=30.
$$

Both residuals are positive. The predictions were too low by 10 and 30 CFU/mL.

Run the supplied {span .script-block}`BLOCK · toy-errors` block to build the two-row calculation table. Expand its code if you want to inspect how the columns are assembled:

{{r:toy-errors}}

The residuals are 10 and 30, and their squares are 100 and 900. Match the arithmetic to R's notation:

| R expression | Meaning | Result |
|---|---|---:|
| `abs(-10)` | Absolute value: distance from zero | 10 |
| `10^2` | Square 10 | 100 |
| `sqrt(100)` | Square root of 100 | 10 |

**Mean absolute error (MAE)** averages the distances between observations and predictions.

$$
\mathrm{MAE} = \frac{|10|+|30|}{2}=20\ \mathrm{CFU/mL}.
$$

**Root mean squared error (RMSE)** averages the squared residuals, then takes the square root. Squaring gives larger errors more influence.

$$
\mathrm{RMSE} = \sqrt{\frac{10^2+30^2}{2}}\approx22.36\ \mathrm{CFU/mL}.
$$

{span .script-block}`BLOCK · toy-metrics`

{{r:toy-metrics}}

Both final metrics have units of **CFU/mL** here; neither is an accuracy percentage. The squared-error column has squared units, which the square root removes in RMSE.

```{admonition} A zero average residual can hide mistakes
:class: tip
In a separate invented pair, predict 20 for observations 10 and 30. The residuals are −10 and 10. Their signed average is zero, but both predictions are wrong by 10. A negative residual means the prediction was too high, not that the microbial concentration was negative. MAE and RMSE prevent those opposite errors from cancelling.
```

## 4.5 Challenge an answer that looks better

**Predict first:** what happens if someone averages all six concentrations, including C's answers?

Run the deliberately wrong {span .script-block}`BLOCK · toy-leakage` example. Its separate objects leave the correct predictions unchanged:

{{r:toy-leakage}}

The all-record mean is **26.67**, and its apparent test RMSE falls from **22.36 to 16.67**. That looks better only after using answers that should have been held out. It is not evidence of better prediction for unseen samples. This is **data leakage**. It need not change the score in every dataset, so also inspect where the fitted value came from.

There is another way a procedure can answer the wrong question. Consider this alternative split:

| Training rows | Test rows |
|---|---|
| A/1, B/1, C/1 | A/2, B/2, C/2 |

**Your prediction:** which farm labels will occur in both sets?

Run the supplied {span .script-block}`BLOCK · toy-wrong-split` counterexample. Its separate objects leave the correct split unchanged:

{{r:toy-wrong-split}}

The shared labels are A, B and C. This tests new records from already represented farms, not the stated task of predicting an unseen farm.

## 4.6 Keep the evidence

Run the supplied {span .script-block}`BLOCK · toy-save` block:

{{r:toy-save}}

Find **outputs/toy/error-table.csv**. The other two CSVs save the training-guess and leakage comparisons. Explain why C has two test records, why its answers must not choose the prediction, and why MAE and RMSE differ here.

**Next:** [the real milk data](05-meet-real-data.ipynb). Its target will use a log10 scale, so its errors cannot be compared numerically with these original-scale toy errors.
