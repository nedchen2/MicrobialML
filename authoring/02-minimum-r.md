# 2. The R you need today

**Open:** the project, restart R, then Save As `scripts/my-02-minimum-r.R` from the supplied chapter script.

**Find at the end:** `outputs/practice/known-counts.csv`. The last section is a separate changed-copy exercise.

## 2.1 Warm up: a name, a function and a check

`c()` combines values into a vector. These practice counts are invented:

{{r:vector}}

`mean(counts)` passes that vector to the `mean()` function. Parentheses hold its inputs, also called arguments.

{{r:function}}

**Check by hand:** sum 10, 20 and 30, then divide by three. Both expressions should give 20. R is case-sensitive: `counts` and `Counts` are different names.

## 2.2 Lab task: inspect four samples

A CSV is a table stored as text. Run `import` to read the included practice file:

{{r:import}}

One row is one invented sample; one column is one variable. The R object `practice` is a **data frame**, a table whose columns can hold different types of values. `count_cfu_ml` is the practice concentration in CFU/mL.

Run `structure`, then decode its output:

{{r:structure}}

| Output | What to check |
|---|---|
| `dim()` | Four rows and three columns, in that order |
| `names()` | The actual column names you must use |
| `str()` | Types: `int`/`num` are numbers; `chr` is text |

Now take one column. `$` means “this named column from this table”:

{{r:column}}

**Your turn:** display `practice$storage_hours`. Predict its four values before running. A sample ID labels a record; it is not automatically useful information for predicting its count.

## 2.3 Decision: what does the missing result mean?

The fourth count is `NA`: no recorded result. Run `missing`:

{{r:missing}}

`is.na()` produces TRUE/FALSE flags. `sum()` counts each TRUE as 1, giving one missing entry. The ordinary mean is NA because a count is unknown.

**Question:** can we report a mean of the recorded counts while leaving that unknown measurement unchanged?

{{r:explicit-missing}}

Yes: `na.rm = TRUE` omits missing entries **for this calculation**. The result is 20 for three recorded counts. It does not recover the fourth measurement. Replacing NA with zero would make a different assumption.

To keep only the known rows in a new object, run `subset`:

{{r:subset}}

Unpack the condition before reading the whole expression:

| Piece | For the four practice rows |
|---|---|
| `is.na(practice$count_cfu_ml)` | FALSE, FALSE, FALSE, TRUE: which counts are missing? |
| `!is.na(practice$count_cfu_ml)` | TRUE, TRUE, TRUE, FALSE: which counts are known? |
| `practice[!is.na(practice$count_cfu_ml), ]` | Keep rows where that condition is TRUE, and keep every column. |

Read `[rows, columns]` as row and column selection. `!` means “not”; leaving the column position empty keeps all columns. The original `practice` remains available.

## 2.4 Evidence: save, reopen and check

**Supplied block — `export`.** Run it unchanged. It writes `known_counts` to a CSV, reads that file back, and checks that the values agree. You can expand the code for details.

{{r:export}}

Find **Files → outputs → practice → known-counts.csv**. The read-back check should be TRUE. You need to explain this check's purpose, not reproduce its nested arguments from memory.

Before continuing, run the short `assertion` block:

{{r:assertion}}

`stopifnot()` stops if a required condition is false. Passing conditions print nothing; the completion message shows that execution reached the end. `==` compares values, `<-` stores one, and `name = value` supplies a function setting.

```{admonition} Explain your result
:class: tip
Which three samples contribute to the mean of 20? Find the saved CSV and explain why the fourth count is not automatically zero.
```

**Get ready for Chapter 3:** keep your hand check of the three recorded values. You will use it to judge an AI reply and improve a request that leaves out the missing-value information.

## 2.5 Extension worksheet: change a copy

**Predict first:** replace the fourth count with 40 in a labeled practice copy. What will happen to the mean and missing count?

**Supplied block — `exercise-copy`.** It creates the changed copy below; the original input stays intact. Run the block unchanged:

{{r:exercise-copy}}

The next line explicitly reads the **new filename**. Another CSV on disk does not redirect an earlier import:

{{r:exercise-read}}

Now test the old statement, “one count is missing”:

{{r:exercise-old-rule}}

**FALSE is expected.** If you pass this false condition to `stopifnot()`, it raises an error. In this exercise the input was intentionally changed, so the old expectation should fail.

Run `exercise-check` to test the new expectations and verify that the original file still has its missing count:

{{r:exercise-check}}

```{admonition} Open after you predict
:class: tip dropdown
The changed file is outputs/practice/practice_counts_changed.csv. It has no missing count and its mean is (10 + 20 + 30 + 40) / 4 = 25. The original data/practice_counts.csv still has its fourth count missing. In real data, investigate an unexplained failure before changing a check.
```

**Next:** [ask, run, inspect and repair](03-working-with-ai.ipynb). [Help with errors](../reference/troubleshooting.md).
