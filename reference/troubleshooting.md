# When something goes wrong

First save your script. Identify the smallest line that fails. Keep the full error message and the task you expected that line to perform.

| What you see | First check | A useful next step |
|---|---|---|
| `object 'x' not found` | Was `x` created in this R session? Is the spelling identical? | Run the preceding assignment; check capitalization |
| `cannot open file` | Are you in the extracted project? Does the path exist? | Open `microbial-ml.Rproj`; run `getwd()` and `file.exists("data/practice_counts.csv")` |
| Console shows `+` | Is a quote or parenthesis unfinished? | Press Esc, then run one complete line |
| A mean returns `NA` | Are any entries missing? | Use `is.na()` and explain a missing-data treatment before changing it |
| A column returns `NULL` | Is the column name present? | Run `names(your_table)` and select the actual name |
| A calculation says data are not numeric | What type is the column? | Run `str(your_table)`; inspect values before conversion |
| Download or connection fails | Can your computer reach the pinned source URL? | Check your connection and try the [manual source download](#download-the-source-files-yourself) below |
| Checksum mismatch | Is the file partial, edited or from another version? | Remove only the cached source file and retry; keep your scripts |
| A checkpoint file is missing | Did the preceding chapter finish? | Run Chapter 5 to create msc-prepared.rds, or Chapter 6 to create farm-split.rds; do not create an empty substitute |
| A tree checkpoint is missing | Did Chapters 8 and 9 finish? | Chapter 8 creates tree-input.rds; Chapter 9 creates tree-fit.rds. Keep the original order |
| `there is no package called` rpart | Is the package installed for this R? | Run `install.packages("rpart")` once in the Console, then retry `library(rpart)`; repeat the load after each R restart |
| The changed-copy exercise shows FALSE | Is this the labeled old-rule check? | FALSE is expected for the old one-missing rule after changing the fourth practice count to 40 |
| Source shows fewer results than the website | Was the file sourced rather than run block by block? | Run the object name or use print(); the main lesson route selects a block and clicks Run |
| An AI login or quota blocks the exercise | Can another listed chat open? | Use [AI access](../chapters/01-first-run.ipynb#id-1-5-ai-access), or complete the supplied code-inspection route and log it honestly |
| The AI cannot find my data | Did you provide the column names and relevant approved rows or output? | Opening a file in RStudio alone does not send it to chat |
| An assertion fails | Which assumption is false? | Inspect the relevant value; do not delete the check just to continue |
| Correct code gives a different score | Same input checksum, eligibility rules, R sampling algorithm and seed? | Compare saved fold assignments and full-precision outputs |

## Download the source files yourself

If R's download fails, first check your internet connection. You can also save the **same fixed author files** with your browser:

| Original file | Save inside the extracted project as |
|---|---|
| [Milk assay CSV](https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Raw%20Milk%20Micro%20Data.csv) | `data/raw/Raw_Milk_Micro_Data.csv` |
| [Farm survey CSV](https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Farm%20Survey%20Data.csv) | `data/raw/Farm_Survey_Data.csv` |

1. In the project's `data` folder, create a folder called `raw` if it does not exist.
2. Open a link above. Use the browser's save/download option, keeping the original CSV bytes. Rename the downloaded file to the exact filename in the table; avoid a second `.csv` or an `.html` extension. Do not open and resave it in a spreadsheet editor.
3. Place it in `data/raw`, restart R, and rerun the chapter from the top. The supplied helper checks the existing file and uses it without downloading again.

If you see **checksum mismatch**, remove only that cached file and download it again from the fixed link. Keep your my- scripts and results; do not change the expected checksum. If the source website is also unreachable in your browser, restore network access before continuing the real-data route. The invented-data lessons in Chapters 1–4 can still run.

## Recover without changing the analysis

1. Save your my- script and read the full error text. Match it to the table above.
2. Restart R, reopen the project, and run the supplied reference script for that chapter from the top. If a checkpoint is missing, finish the named preceding chapter; an empty replacement will not work.
3. If the reference works but your changed copy does not, compare the smallest differing block. Use the error report below when asking AI for a local repair. Run and check the returned code yourself.
4. Compare the relevant output with the chapter's displayed values and reference explanation. Small display-rounding differences are expected; a different result needs investigation, not deletion of the check.

## A small error report

Use this as a note to yourself or paste it into your chosen AI chat. For a small repair, include the invented practice rows or the relevant output rather than unrelated files.

```text
Goal:
Exact code that fails:
Full error text:
Expected result:
Actual result:
Relevant object/column names:
What I already checked:
R version:
```

Only include data approved for sharing. A text copy of the code and error lets someone reproduce the problem more reliably than a cropped screenshot alone.

## Restore a known starting point

Use **Session → Restart R**, then open the correct project and run the lesson from the top. Do not rely on objects left in memory from an earlier experiment. Installation is persistent; ordinary in-memory objects are not.

If a repair requires a new assumption, record it. For example, converting text counts to numbers can create missing values; replacing an absent result with zero changes the scientific data.

```{admonition} Only when asking for setup help: report your R version
:class: note dropdown
Run `R.version.string` in the Console and copy the output with your error report. You do not need to match the exact version text printed in the book.
```
