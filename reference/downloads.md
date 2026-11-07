# Your student project

**[Download the complete student ZIP](../downloads/microbial-ml-student.zip)**

1. Extract the ZIP to a folder you can find. On Windows, use **Extract All**.
2. Open `microbial-ml.Rproj` inside the extracted folder.
3. Start with [Chapter 1](../chapters/01-first-run.ipynb). Work in a `my-` copy of each script.

For computer setup, see the [R and RStudio installation instructions](../chapters/00-start-here.md#set-up-your-computer). Chapter 8 introduces the R package `rpart`.

## What is in the folder?

| Folder | What you use it for |
|---|---|
| `scripts/` | Chapter scripts and the complete workflows |
| `data/` | Invented practice CSVs and data dictionaries |
| `templates/` | An AI-use log and an optional completion card |
| `outputs/` | Your results and checkpoints, created when you run the scripts |

Chapters 5 and 8 download the study CSVs from a fixed version of the authors' repository on first use. For a manual download, see [source-file recovery](troubleshooting.md#download-the-source-files-yourself).

## Replace a chapter script

Save the file in the **`scripts/` folder inside your extracted project**, using the filename shown in the table. If the browser displays the script as text, use its **Save As** option and keep the `.R` ending. Open the file in RStudio and use **File → Save As** to make a working copy. For example, save `07-baseline.R` as `my-07-baseline.R`. If your existing my- copy contains edits, give the new copy a different name.

| Chapters | Reference scripts |
|---|---|
| 1–3 | [01-first-run.R](../scripts/01-first-run.R) · [02-minimum-r.R](../scripts/02-minimum-r.R) · [03-working-with-ai.R](../scripts/03-working-with-ai.R) |
| 4–7 | [04-small-farm-example.R](../scripts/04-small-farm-example.R) · [05-meet-real-data.R](../scripts/05-meet-real-data.R) · [06-split-farms.R](../scripts/06-split-farms.R) · [07-baseline.R](../scripts/07-baseline.R) |
| 8–10 | [08-first-tree.R](../scripts/08-first-tree.R) · [09-choose-tree.R](../scripts/09-choose-tree.R) · [10-test-tree.R](../scripts/10-test-tree.R) |

```{admonition} Complete workflows and support scripts
:class: note dropdown

Use the [baseline workflow](../scripts/worked-example.R) to recreate the baseline, or the [run-all script](../scripts/full-analysis.R) to recreate both study analyses. The ZIP also supplies the [tree workflow](../scripts/tree-workflow.R), [tree support](../scripts/tree_helpers.R) and [download helper](../scripts/course_setup.R). Run these workflows from the extracted project so R can find their supporting files.
```

## Find practice data and templates

| What you need | Files |
|---|---|
| Invented practice data | [Four milk samples](../data/practice_counts.csv) · [Six farm records](../data/practice_farms.csv) |
| Meanings and units of study columns | [Milk data dictionary](../data/data-dictionary.csv) · [Survey predictor dictionary](../data/predictor-dictionary.csv) |
| Study records and progress | [AI-use log template](../templates/ai-use-log.txt) · [Optional completion card](../templates/completion-card.txt) |
| Setup and chapter order | [Student project README](../STUDENT_README.txt) |

## Compare with reference results

The files in the middle column contain the textbook's results. Use the last column to find **your results** in RStudio's Files pane after you run the matching chapter.

| What you want to check | Textbook reference | Your file inside the project |
|---|---|---|
| Chapter 7 baseline scores | [Baseline scores](../downloads/baseline-scores.csv) | `outputs/baseline/scores.csv` |
| Chapter 7 data selection and split counts | [Selection counts](../downloads/data-audit.csv) | `outputs/baseline/data-audit.csv` |
| Chapter 8 survey matching | [Survey matching audit](../downloads/predictor-audit.csv) | `outputs/tree/predictor-audit.csv` |
| Chapter 9 depth comparison | [Validation scores](../downloads/tree-validation.csv) | `outputs/tree/validation-scores.csv` |
| Chapter 10 baseline and tree comparison | [Test scores](../downloads/tree-scores.csv) | `outputs/tree/test-scores.csv` |

Use the ZIP at the top with the current online book. To reproduce an older edition, pair its ZIP with the corresponding book version. [Older releases](https://github.com/nedchen2/MicrobialML/releases)
