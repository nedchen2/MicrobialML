# 1. Your first successful run

**Time:** 30-45 minutes, with installation taking longer on some computers. **You need:** the student project and permission to install software, or an institution-managed computer with R and RStudio already installed.

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

Open `scripts/01-first-run.R` through **File → Open File**. It appears in the Source editor. Comments beginning with `#` explain the steps; R ignores the comment text.

## 1.4 Run one line

**Where: RStudio Source editor.** Put the cursor on `1 + 1`, then click **Run**, or press **Ctrl + Enter** on Windows / **Cmd + Enter** on macOS.

{{r:arithmetic}}

The output should show `2`. R may print `[1]` before the value; that is an output index, not part of the answer. Do not type the console prompt `>` or the printed `[1]` yourself.

If the console shows `+` instead of `>`, R is waiting for the rest of an unfinished expression. Press **Esc**, then run just the complete line again.

**Make a script of your own:** choose **File → New File → R Script**. Type `1 + 1` in the blank Source tab. Use **File → Save As** and save it as `my-first-script.R` inside the project's `scripts` folder. Run the line. Then return to the supplied `01-first-run.R` tab. A script is a text file, not an Excel sheet or a screenshot.

## 1.5 Store something in an object

Read `<-` as “store the value on the right under the name on the left.” Quotation marks make `milk` text, rather than the name of another object.

{{r:object}}

An object is a named value in the current R session. Here is a numerical one:

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

## 1.8 Packages: installation versus use

A package adds functions to R. `install.packages("packageName")` downloads and installs one; `library(packageName)` attaches an already installed package in the current session.

The code in this pilot uses packages supplied with R itself. **No additional student R packages are needed.** If AI suggests installing many packages for this first run, ask it to use the supplied base-R workflow.

Record your R version if you ask for help:

{{r:versions}}

Your version does not have to display the same text as this example. The tested version is recorded in the instructor's build notes.

## 1.9 Ask AI a small question

**Where: AI chat.**

> I am new to R. I ran `count <- 20` and then `count * 2`. Explain what is stored in `count`, what the second line prints, and how I can check whether `count` changed. Do not add packages or an analysis pipeline.

**Check it yourself:** type `count` in your script and run that line. Compare R's output with the explanation.

## 1.10 Restart and recover

Save the script. Use **Session → Restart R**. The Environment should no longer contain your earlier objects. Reopen the script if necessary and run it from its first line to its last line. You should recreate the object and the file without retyping the analysis.

```{admonition} Checkpoint 1
:class: tip
Show the TA your saved script, the `TRUE` project-folder check, and `outputs/practice/first-run.txt`. Explain the difference between a file on disk and an object in memory.
```

**If it fails:** use the [troubleshooting page](../reference/troubleshooting.md). Report the exact line and full error text. A screenshot can help with the interface; code and error text should also be copied as text.

**Try a change:** save a second text file with a different message and filename. Check that both files exist.

[Download this chapter's R script](../scripts/01-first-run.R). **Next:** [the R you need today](02-minimum-r.ipynb).
