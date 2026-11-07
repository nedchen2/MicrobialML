# Your student project

**[Download the complete student ZIP](../downloads/microbial-ml-student.zip)**

1. Extract it first.
2. Open `microbial-ml.Rproj` in RStudio.
3. Start with Chapter 1. Save your edits in my- copies of the reference scripts.

The supplied analysis uses R and RStudio. Chapters 1–7 use base R; Chapter 8 shows how to install rpart once and load it with `library(rpart)` in each new session. Ask the TA for the course-approved AI chat link; Chapter 3 also includes a labeled inspection dialogue.

## What is in the folder?

| Folder | What you use it for |
|---|---|
| `scripts` | The chapter scripts and complete real-data workflow |
| `data` | Two invented practice tables and the real-data dictionary |
| `templates` | An AI-use log and an optional completion card |
| `outputs` | Created when you run the lessons; your own results go here |

Chapters 5–10 save and reload their inputs. `scripts/worked-example.R` recreates the baseline. After the tree lessons, `scripts/full-analysis.R` recreates both real-data workflows from the beginning.

## Need a single file again?

```{admonition} Reference scripts
:class: note dropdown
[1. First run](../scripts/01-first-run.R) · [2. Minimum R](../scripts/02-minimum-r.R) · [3. AI exchange](../scripts/03-working-with-ai.R) · [4. Six records](../scripts/04-small-farm-example.R) · [5. Real data](../scripts/05-meet-real-data.R) · [6. Split farms](../scripts/06-split-farms.R) · [7. Baseline](../scripts/07-baseline.R) · [8. First tree](../scripts/08-first-tree.R) · [9. Choose depth](../scripts/09-choose-tree.R) · [10. Test tree](../scripts/10-test-tree.R).

The [baseline workflow](../scripts/worked-example.R), [tree workflow](../scripts/tree-workflow.R), [run-all script](../scripts/full-analysis.R), [tree support](../scripts/tree_helpers.R) and [download helper](../scripts/course_setup.R) are also in the ZIP. A script alone does not include its supporting inputs.
```

```{admonition} Inputs, templates and example outputs
:class: note dropdown
[Four invented samples](../data/practice_counts.csv) · [Six invented farm records](../data/practice_farms.csv) · [Real-data dictionary](../data/data-dictionary.csv) · [Predictor dictionary](../data/predictor-dictionary.csv).

[AI-use log](../templates/ai-use-log.txt) · [Optional completion card](../templates/completion-card.txt) · [Project instructions](../STUDENT_README.txt).

[Example baseline scores](../downloads/baseline-scores.csv) · [Selection counts](../downloads/data-audit.csv) · [Tree comparison](../downloads/tree-scores.csv) · [Tree validation](../downloads/tree-validation.csv) · [Survey matching audit](../downloads/predictor-audit.csv). Your own scripts generate their results on your computer.
```

The real assay and survey data are downloaded from the fixed author source on first use; they are not redistributed in this ZIP. Read the [data sheet](data-audit.md) before reuse.

If your TA specifies a classroom version, use that [release's student ZIP](https://github.com/nedchen2/MicrobialML/releases). Otherwise use the download at the top of this page.
