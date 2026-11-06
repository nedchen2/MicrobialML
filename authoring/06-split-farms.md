# 6. Keep farms together

**Estimated session:** 20–35 minutes.

| Before running | Your task |
|---|---|
| Input | `outputs/checkpoints/msc-prepared.rds` from Chapter 5 |
| Working file | Open `scripts/06-split-farms.R`; Save As `scripts/my-06-split-farms.R` |
| Starting state | Restart R; the first block reloads the prepared table |
| Stop after | The `save-split` block |
| Finish with | `outputs/checkpoints/farm-split.rds` and an empty farm intersection |

## 6.1 Reload a file, not an earlier session

{{r:load-prepared}}

`readRDS()` loads the saved named container. `prepared$data` extracts its data table into `usable`. The project-relative filename is the connection between the two chapters. If it is absent, run Chapter 5; do not create an empty replacement or remove the check.

## 6.2 Hold out whole farms


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


## 6.3 Save the split for a fresh session

{{r:save-split}}

This supplied save block preserves train, test, farm identifiers and audit counts. These are named entries in the saved container; Chapter 7 will extract them using `$`. The names identify input roles, not new predictor variables.

Locate **outputs → checkpoints → farm-split.rds**. It should exist even if you restart R now. The saved assignments let you compare later runs without relying on memory.

**Checkpoint 6:** show 81 training and 21 test farms, 420 training and 105 test records, and `character(0)` for the shared farm labels. Explain why a different number of rows per farm means the test-row fraction need not equal exactly 20%.

```{admonition} Open after you try: explain the empty output
:class: tip dropdown
character(0) is the R representation of an empty character vector, not an error. No farm labels occur in both groups. This addresses farm overlap; it does not prove all observations are independent or guarantee prediction in a new region. Do not change seeds to search for a better test score.
```

**Ask AI:** give it the task, the actual group counts and empty intersection. Ask for an explanation of which prediction setting this split evaluates. Compare its answer with the six-row example before accepting it.

**Next:** restart R, then [learn and evaluate a baseline](07-baseline.ipynb).
