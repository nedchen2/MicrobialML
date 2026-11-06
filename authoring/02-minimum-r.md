# 2. The R you need today

**Estimated session:** 35–50 minutes, plus the extension exercise; not yet measured in a beginner trial.

| Before running | Your task |
|---|---|
| Input | `data/practice_counts.csv`: four invented samples |
| Working file | Open `scripts/02-minimum-r.R`; Save As `scripts/my-02-minimum-r.R` |
| Starting state | Open the project, then Session → Restart R |
| Stop after | The core checks; then attempt the clearly labeled changed-copy exercise |
| Finish with | `outputs/practice/known-counts.csv`; extension: a changed-copy CSV |

Select and Run each matching block in your my- file. The supplied code is already there. For an AI attempt, add it under a new `# My AI attempt` comment at the end and run only that block.

You will learn enough R to read and question an AI-generated analysis: objects, functions, vectors, tables, missing values and checks. You do not need loops or to memorize every function.

## 2.1 A vector holds several values

`c()` combines values. This vector contains three **invented practice counts**, not results from a new experiment.

{{r:vector}}

An object name refers to its stored value. R is case-sensitive: `counts` and `Counts` would be different names.

## 2.2 A function does a named job

`mean(counts)` passes the vector `counts` to the function `mean()`. Parentheses hold the inputs, also called arguments.

{{r:function}}

Both calculations should give 20. The second uses a different expression for the same calculation. This is a simple independent check, rather than asking AI twice whether its answer is correct.

## 2.3 Read a tiny CSV

**Where: RStudio script.** A CSV is a table stored as text, usually with commas separating columns. Our four-row practice file is included in the project. Its numbers are invented so that you can check them by hand.

{{r:import}}

`practice` is a **data frame**: a table whose columns can contain different kinds of values. `stringsAsFactors = FALSE` keeps text as text when reading. The second part is a named argument, not another dataset.

The column name `count_cfu_ml` means a practice count in CFU/mL. The label is part of this exercise; always verify actual measurement units in a real data dictionary.

## 2.4 Check the shape before calculating

{{r:structure}}

Read the output as follows:

- `dim()` returns the number of rows, then columns: 4 and 3.
- `names()` returns the column names.
- `str()` gives a compact description. `int` means integers, `num` means numbers, `chr` means text, and `logi` means TRUE/FALSE values. These are type labels, not assay names. Your display may include quotation marks or output indices that differ from the web table.

One row is one practice sample. One column is one variable. A table can be read successfully and still have the wrong structure, so check both.

## 2.5 Select a column

The `$` means “take this named column from this data frame.”

{{r:column}}

The counts are numerical. The sample identifiers are text labels. An identifier can distinguish rows without being a scientifically meaningful predictor.

**Try a change:** select `practice$storage_hours`. What values do you expect? Check the spelling against `names(practice)`.

## 2.6 Missing is different from zero

The fourth sample has no recorded count. R represents it as `NA`. `is.na()` tests for missingness; `TRUE` means yes, and `FALSE` means no.

{{r:missing}}

`sum()` counts TRUE values as 1 and FALSE values as 0; summing the missingness flags therefore counts missing entries. There is one missing value. The ordinary mean is `NA`, because R does not know the unrecorded count. Replacing that observation with zero would assert a measurement we do not have.

To calculate a mean of only the known practice counts, request that explicitly:

{{r:explicit-missing}}

`na.rm = TRUE` means “remove missing entries for this calculation.” It does not repair the dataset or prove that missingness is harmless. In real analysis, state how many observations are missing and why the treatment is appropriate.

## 2.7 Filter rows with a logical condition

`!` means “not.” Inside square brackets, a data frame uses `[rows, columns]`. Leaving the position after the comma empty means all columns.

{{r:subset}}

Read this as: take all columns from rows whose count is **not missing**. `known_counts` is a new object; the original `practice` remains available.

We use complete cases here only to demonstrate filtering. The real worked example uses a prespecified quality rule, not a general rule that every incomplete record should be discarded.

## 2.8 Optional reference: categories

{{r:factor}}

This section is optional for the current numerical baseline. A **factor** represents categories. Its levels are category labels. They are not distances: a future farm variable with values `Yes` and `No` is not a continuous measurement merely because software can encode it with numbers.

## 2.9 Save and read back a table

{{r:export}}

`row.names = FALSE` stops R from writing an extra index column. The nested `all.equal()` check is supplied verification code; explain its purpose without memorizing every argument. It should return `TRUE`, confirming that the exported table can be read back with the same values. Numeric printing can differ; the stored values matter.

Look in **Files → outputs → practice** to locate `known-counts.csv`. RStudio and spreadsheet programs can both open it.

## 2.10 Ask AI, then verify

**Where: AI chat.**

> I am using base R. My data frame `practice` has columns `sample_id`, `count_cfu_ml` and `storage_hours`. One count is missing. Show one short step to report the number of missing counts and compute the mean of the recorded counts. Explain what your choice assumes. Do not replace the missing count with zero. Give a calculation I can verify by hand.

The recorded values are 10, 20 and 30. Check any proposed answer against those three values and the table you actually loaded.

## 2.11 Make a check fail visibly when an assumption changes

`stopifnot()` normally prints nothing when its conditions pass. The final `cat()` line prints a completion message. It stops execution when a condition is not true. It is useful for assumptions that the next step depends on.

{{r:assertion}}

R uses `==` to compare values. It uses `<-` to store a value. In a function call, `name = value` supplies a named argument. These uses look similar but do different jobs.

```{admonition} Checkpoint 2
:class: tip
Identify the outcome column, explain `NA`, show the missing-count result, and find the exported CSV. Explain why a missing count is not automatically zero.
```

## 2.12 Extension: change a copy and follow the consequences

**Predict first:** if the missing fourth count becomes 40, how many counts are missing, and what is the mean? Keep your original input intact. Work in your my- script.

Run `exercise-copy`. The `[4]` selects the fourth entry of this column. This writes a **new** file under outputs; it does not edit the original CSV:

{{r:exercise-copy}}

The next import line explicitly reads the changed filename. Merely creating another CSV does not redirect an earlier `read.csv()` call:

{{r:exercise-read}}

Now inspect the old rule, “there is exactly one missing count”:

{{r:exercise-old-rule}}

**FALSE is the expected result here.** If you manually run `stopifnot(old_rule_holds)` in the Console, R will raise an error. That would be an expected exercise failure, not a broken R installation. In the supplied script we display the false condition without interrupting the remaining lesson.

For this deliberately changed copy, test the new expectations and check that the original remains missing:

{{r:exercise-check}}

```{admonition} Open after you predict: expected extension results
:class: tip dropdown
The changed file is outputs/practice/practice_counts_changed.csv. Its missing count is 0 and its mean is (10 + 20 + 30 + 40) / 4 = 25. The old one-missing rule is FALSE. The original data/practice_counts.csv still has a missing fourth count. Updating an expected value is justified here because we intentionally changed this labeled practice input; an unexplained failure in real data needs investigation.
```

Record the two filenames and explain which table each mean describes.

**If it fails:** first inspect `getwd()`, `names(practice)` and `str(practice)`. A typo and a wrong column type need different repairs.

[Download this chapter's R script](../scripts/02-minimum-r.R). **Next:** [work with AI in small steps](03-working-with-ai.ipynb).
