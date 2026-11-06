# 1. Your first successful run

**Estimated session:** 30–60 minutes plus installation or access support. These times have not been measured with beginners.

| Before running | Your task |
|---|---|
| Input | [Student ZIP](../downloads/microbial-ml-student.zip), extracted on your computer |
| Working file | Open `scripts/01-first-run.R`; File → Save As `scripts/my-01-first-run.R` |
| Run method | Cursor on a complete line → Run; for several lines, select the whole block → Run |
| Stop after | Section 1.10, after restarting and recreating the output |
| Finish with | Your my- script and `outputs/practice/first-run.txt` |

You need permission to install R and RStudio, or a prepared lab computer. The reference script already contains the code below. Work in your saved my- copy and run its matching lines; avoid pasting duplicate copies from the website.

The goal is small: run one line, save a script, create a file, and find it again. Follow the steps in order even if AI offers to write a full analysis immediately.

## 1.1 Install two different things

**R** is the language and calculation engine. **RStudio Desktop** is the interface we use to write and execute R instructions.

1. Open [CRAN, the official R download site](https://cran.r-project.org/).
2. Choose the link for your operating system.
   - **Windows:** choose the base installation and run the official installer.
   - **macOS:** choose the installer for your processor: Apple silicon or Intel. Follow the compatibility notes on the download page.
3. Finish installing R before installing RStudio.
4. Download the free **RStudio Desktop** edition through [Posit's official download guide](https://docs.posit.co/ide/user/download.html). Install and open it.

If your computer is managed by your institution or the installer does not support your operating system, use the course's lab setup or ask the TA. You do not need a terminal, Conda or Jupyter Book to follow these lessons.

## 1.2 Open the project, not just a code file

1. [Download the student project](../downloads/microbial-ml-student.zip).
2. Extract the ZIP into a folder you can find again, such as Documents. On Windows, use **Extract All** before opening files; do not work inside the ZIP preview.
3. Locate `microbial-ml.Rproj` in the extracted folder.
4. Double-click it. Alternatively, use **File → Open Project** inside RStudio and select that file.
5. Check the **Files** pane: you should see `scripts` and `data`.

A project gives R a starting folder. A relative path such as `data/practice_counts.csv` means “start in this project folder, open data, then open the CSV.” It does not mean your browser's Downloads folder.

## 1.3 Find the parts of RStudio

![An illustrated map of the RStudio Source, Console, Environment and Files panes.](../assets/rstudio-map.svg)

This is an illustration, not a screenshot. The arrangement can vary. The important names are **Source**, **Console**, **Environment** and **Files**. The [official pane guide](https://docs.posit.co/ide/user/ide/guide/ui/ui-panes.html) has further interface guidance.

Open `scripts/01-first-run.R` through **File → Open File**. It appears in the Source editor. Immediately choose **File → Save As** and save `my-01-first-run.R` in the same `scripts` folder. Check the tab name before editing. Comments beginning with `#` explain the steps; R ignores them. A marker such as `# %% arithmetic` identifies a supplied block.

## 1.4 Run one line

**Where: RStudio Source editor.** Put the cursor on `1 + 1`, then click **Run**, or press **Ctrl + Enter** on Windows / **Cmd + Enter** on macOS.

{{r:arithmetic}}

The output should show `2`. R may print `[1]` before the value; that is an output index, not part of the answer. Do not type the console prompt `>` or the printed `[1]` yourself.

If the console shows `+` instead of `>`, R is waiting for the rest of an unfinished expression. Press **Esc**, then run just the complete line again.

**For a block:** drag over all its code lines in the Source editor, then click **Run** once. Keep your browser, script and Console visible as you compare results. Read output in the Console, below the script; the Environment lists created objects.

**Run versus Source:** the main route uses Run so you see each result. Source executes an entire saved file and normally does not print every bare expression. A missing printed value after Source does not itself mean failure. To display one, run its object name or use `print()`.

Your my- file is already a script of your own. For a future blank script, use **File → New File → R Script**, then Save As a `.R` filename. You do not need a second blank file for this lesson.

## 1.5 Store something in an object

Read `<-` as “store the value on the right under the name on the left.” Quotation marks make `milk` text, rather than the name of another object.

{{r:object}}

An assignment such as `sample_name <- "milk"` normally prints nothing. Run the next line, `sample_name`, to display its value; you can also find it in Environment. An object is a named value in the current R session. Here is a numerical one:

{{r:count}}

**Predict before running:** what will `count + 5` produce? Try it. Changing the displayed calculation does not change `count` unless you assign a new value to it.

## 1.6 Check where R is working

`getwd()` asks for the working directory. In this example we display only its final folder name. Yours can have a different name. The second check must return `TRUE`.

{{r:folder}}

If it returns `FALSE`, reopen `microbial-ml.Rproj`. Do not start adding absolute paths copied from someone else's computer.

## 1.7 Save a file and find it

`dir.create()` makes a folder. `writeLines()` writes text. In a function call, named arguments such as `recursive = TRUE` control the behavior. Here, an existing folder is acceptable, so rerunning the lesson is safe.

{{r:save}}

In RStudio's Files pane, open **outputs → practice** and find `first-run.txt`. You can also verify its contents in R:

{{r:inspect}}

Saving a script with **File → Save** or **Ctrl/Cmd + S** saves your instructions. Running a line such as `writeLines()` creates the output file. These are different actions.

## 1.8 Optional reference: packages

A package adds functions to R. `install.packages("packageName")` downloads and installs one; `library(packageName)` attaches an already installed package in the current session.

The code in this pilot uses packages supplied with R itself. **No additional student R packages are needed.** If AI suggests installing many packages for this first run, ask it to use the supplied base-R workflow.

Record your R version if you ask for help:

{{r:versions}}

Your version does not have to display the same text as this example. The tested version is recorded in the instructor's build notes.

## 1.9 Ask AI a small question

**Where: the course-approved AI chat.** Obtain the course access link from your TA. If access is unavailable, finish the R steps and mark this live-chat task pending; Chapter 3 also offers an offline inspection route.

1. Open the approved chat and start a new conversation.
2. Paste the filled-in prompt below into its message box and send it.
3. Read the reply. The assistant does not automatically see your RStudio session.
4. If it returns code, copy only the R instructions, leaving out triple backticks and explanatory prose.
5. In your **my-01** script, add `# My AI check` at the end, paste or type the proposed small check below it, save, and select that new block → Run.
6. Compare the Console output with the actual `count` object. If they disagree, send the exact code and output back.

> I am new to R. I ran `count <- 20` and then `count * 2`. Explain what is stored in `count`, what the second line prints, and how I can check whether `count` changed. Do not add packages or an analysis pipeline.

**Check it yourself:** type `count` in your script and run that line. Compare R's output with the explanation.

## 1.10 Restart and recover

Save the script. Use **Session → Restart R**. The Environment should no longer contain your earlier objects. Reopen the script if necessary and run it from its first line to its last line. You should recreate the object and the file without retyping the analysis.

```{admonition} Checkpoint 1
:class: tip
Record your my- script filename, show the `TRUE` project-folder check, find `outputs/practice/first-run.txt`, and explain how you recreated it after restarting. Record whether the live AI step is completed or pending in your completion card.
```

**If it fails:** use the [troubleshooting page](../reference/troubleshooting.md). Report the exact line and full error text. A screenshot can help with the interface; code and error text should also be copied as text.

```{admonition} Open after you try: expected evidence
:class: tip dropdown
The arithmetic returns 2; `count * 2` returns 40 and `count` remains 20. The project check is TRUE. After a restart, rerunning your saved script recreates the objects and writes the text file again. Saving the script preserves instructions; running writeLines creates the result file.
```

**Try a change:** in your my- copy, change the message and filename in the `writeLines()` line to save a second text file with a different message and filename. Check that both files exist.

[Download this chapter's R script](../scripts/01-first-run.R). **Next:** [the R you need today](02-minimum-r.ipynb).
