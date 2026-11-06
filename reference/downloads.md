# Downloads and how to use them

## Start with the complete student project

[Download the complete student ZIP](../downloads/microbial-ml-student.zip). **Extract it first**, then open `microbial-ml.Rproj` in RStudio. Each chapter tells you to save a my- working copy of its reference script and run short blocks with Run.

| In order | Reference script | What it creates |
|---|---|---|
| 1. First run | [01-first-run.R](../scripts/01-first-run.R) | A text file |
| 2. Minimum R | [02-minimum-r.R](../scripts/02-minimum-r.R) | A filtered table and a labeled changed copy |
| 3. AI feedback | [03-working-with-ai.R](../scripts/03-working-with-ai.R) | A checked summary and an AI-use log template |
| 4. Six invented records | [04-small-farm-example.R](../scripts/04-small-farm-example.R) | A hand-checkable error table |
| 5. Real data | [05-meet-real-data.R](../scripts/05-meet-real-data.R) | The prepared-data checkpoint |
| 6. Farm split | [06-split-farms.R](../scripts/06-split-farms.R) | The split checkpoint |
| 7. Baseline | [07-baseline.R](../scripts/07-baseline.R) | Scores, predictions, a plot and audit counts |

Restart R between Chapters 5, 6 and 7. Each reloads its saved input explicitly. For a final complete run from scratch, use [worked-example.R](../scripts/worked-example.R). The [download helper](../scripts/course_setup.R) fetches and checks the real source file.

The student route needs R and RStudio, with no additional R packages. It does not require Python, Node, Jupyter Book or a GitHub account. Obtain the course-approved AI access link from the TA; the illustrative dialogue provides a clearly labeled inspection route when live access is unavailable.

## Inputs and evidence templates

- [Practice counts](../data/practice_counts.csv): four invented samples.
- [Practice farms](../data/practice_farms.csv): six invented farm-round records.
- [Real-data dictionary](../data/data-dictionary.csv).
- [Completion card](../templates/completion-card.txt).
- [AI-use log template](../templates/ai-use-log.txt).
- [Plain-language project instructions](../STUDENT_README.txt).
- [Aggregate real baseline scores](../downloads/baseline-scores.csv).
- [Real-data selection and verification counts](../downloads/data-audit.csv).

Individual files do not supply all supporting inputs. Use the complete ZIP for your first run. Your scripts create outputs on your own computer; they are not already present just because the website displays example results.

## Source and versions

The helper downloads the original-author raw CSV from a fixed commit and checks its checksum. The complete raw dataset is not inside the ZIP. First download requires internet; later runs can use the verified cache. Read the [data audit](data-audit.md) before reuse.

For a class using a fixed version, use the student ZIP attached to the [release specified by the TA](https://github.com/nedchen2/MicrobialML/releases). The website and its default download reflect the current edition.

## For maintainers

See the repository's [build guide](https://github.com/nedchen2/MicrobialML/blob/main/BUILDING.md) and [publication guide](https://github.com/nedchen2/MicrobialML/blob/main/PUBLICATION.md). The website displays executed R outputs; live in-page R execution is not configured. A novice RStudio working-session trial remains necessary to measure usability and timing.
