# When something goes wrong

Save your working script and find what you see below. Copy the full message from the **Console** so you can check which line or file caused it.

## R shows a message or stops

| What you see | What to try first |
|---|---|
| `object 'x' not found` | Run the earlier block that creates `x` in this R session. Check that the name and capital letters match. |
| `cannot open file` | Open the extracted project's `microbial-ml.Rproj`. Run `getwd()` to see the current folder, then check the filename and path from the error. |
| Console shows `+` | Press **Esc**. Select the complete statement, including its closing quote or parenthesis, and run it again. |
| `there is no package called 'rpart'` | Run `install.packages("rpart")` once in the Console. Run `library(rpart)` in each new R session. |
| A column returns `NULL` | Run `names(your_table)`, using your table's name. Copy the column name exactly. |
| A calculation says the data are not numeric | Run `str(your_table)` and inspect the column before converting its values. |
| A chapter's BLOCK label is missing from your script | Check the chapter number and script name. Open the reference script from the current [student ZIP](downloads.md) and compare its labels with your working copy. |

## A checkpoint file is missing

Check the filename in the message. Open the chapter listed below and run its blocks in order through the named save block. The file will appear in **Files → outputs → checkpoints**. Then restart R and return to the chapter you were working on.

| Missing file | Chapter that creates it | Save block |
|---|---|---|
| `msc-prepared.rds` | [5. Meet the real milk data](../chapters/05-meet-real-data.ipynb) | {span .script-block}`BLOCK · save-prepared` |
| `farm-split.rds` | [6. Split the data by farm](../chapters/06-split-farms.ipynb) | {span .script-block}`BLOCK · save-split` |
| `tree-input.rds` | [8. Can two averages beat one?](../chapters/08-first-tree.ipynb) | {span .script-block}`BLOCK · save-tree-input` |
| `tree-fit.rds` | [9. How deep should the tree grow?](../chapters/09-choose-tree.ipynb) | {span .script-block}`BLOCK · save-tree-fit` |

## The output looks different

| What you see | What to check |
|---|---|
| A mean returns `NA` | Use `is.na()` to find missing values. Check what the task says to do with them. Chapter 3 shows how to report the mean of the recorded values. |
| The changed-copy exercise shows `FALSE` | This is expected for Chapter 2's old one-missing-value check after you fill the fourth count. |
| RStudio shows fewer results after **Source** | Select the named block and click **Run** to inspect that step's output. |
| A check stops or the score differs | Compare the first different result with the chapter. Check record counts and farm assignments before comparing full-precision scores. If the assignments differ, check that you used the supplied scripts and their sampling settings. |

## Download the source files yourself

If a download fails in Chapters 5 or 8, check your internet connection. You can save the same source CSV with your browser.

| Source file | Save inside the extracted project as |
|---|---|
| [Milk assay CSV](https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Raw%20Milk%20Micro%20Data.csv) | `data/raw/Raw_Milk_Micro_Data.csv` |
| [Farm survey CSV](https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Farm%20Survey%20Data.csv) | `data/raw/Farm_Survey_Data.csv` |

1. Inside the project's `data/` folder, create a `raw/` folder if needed.
2. Use your browser's download or save option. Keep the downloaded CSV as it is and give it the exact filename in the table, with a single `.csv` extension.
3. Restart R and rerun the chapter. The helper checks the saved CSV and uses it for the analysis.

If R says **Source checksum mismatch**, the saved CSV differs from the expected source file. Delete only the file named in the error and download it again. If you are offline, you can still run Chapters 1–4 with the files in the ZIP.

## AI chat is unavailable or gives unusable code

- **Login or quota problem.** Try another browser chat or take the chapter's code-inspection route. [AI access](../chapters/01-first-run.ipynb#id-1-5-ai-access)
- **AI uses the wrong table or column.** Give it the exact names from R and the relevant error or output. Share only data you are allowed to share.

## Start again from the reference script

1. Save your `my-` script. Choose **Session → Restart R**. Your files stay on disk while R clears the objects from the session.
2. Open the project and run the supplied reference script for the chapter from the top, using its named blocks. Follow the checkpoint table above if a file is missing.
3. If the reference works, compare the first block where your copy behaves differently. Use the report below to ask about that step and check the repair in R.

## Copy a short error report

```text
What I was trying to do:
The exact R code I ran:
The full message or unexpected output:
```

If it helps, add the chapter and block name, the result you expected, and what you already checked. For an installation or setup issue, run `R.version.string` in the Console and add its output.
