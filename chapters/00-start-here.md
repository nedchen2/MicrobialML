# 0. Start here

You will turn a small biological question into an analysis you can run, check and explain. Start with no programming experience.

## The project in one question

Imagine you are helping in a milk-testing lab. A sample has arrived from a farm you have never studied. Its mesophilic spore count (**MSC**) result is still unknown, but you have measurements from other farms.

**Why care about MSC?** Some bacterial spores survive pasteurization and can later germinate, allowing bacteria to grow and spoil dairy products. MSC is one laboratory measure of this spore burden. [Dairy research](https://doi.org/10.3168/jds.2015-9406)

Certain spore-forming bacteria, such as *Bacillus cereus*, also cause foodborne illness. But MSC does not identify a species or measure toxins, so its value alone cannot establish whether milk is safe. [FDA explanation](https://www.fda.gov/food/laboratory-methods-food/bam-quantitative-analysis-cereulide-food-products)

**What would you predict before the result comes back—and what would convince you that your prediction is any good?**

Reliable predictions could eventually help prioritize monitoring. First, we need to check whether they work: make a prediction, put it beside the lab result, and find out how far it missed. Practise with invented numbers, then real study data; keep new farms' answers out of learning the rule.

Start with a guess you can make on paper: the average from the farms we already know. This **baseline** gives us something to test before asking a more complicated model to do better.

## Where each part happens

![Read in the textbook, ask in chat, and run and check in RStudio.](../assets/three-places.svg)

- **Here:** read the task and compare example results. The copy button copies text; it does not run R.
- **AI chat:** ask for a small step and provide the context it needs.
- **RStudio:** edit a saved script, run code and inspect your actual results.

Opening a file in RStudio does not automatically share it with a chat assistant. Chapter 3 shows exactly what to send.

## Your route

**Make something run — Chapters 1–2.** Open the project, save your own script and inspect a four-row table.

**Work with AI — Chapter 3.** Run a reply to an incomplete request, explain its missing result, and check a repaired summary against your data. Then try a separate object-name error exercise.

**Understand the analysis — Chapters 4–7.** Hand-check six invented farm records, then prepare real data, hold out whole farms and evaluate a baseline.

**Add a model — Chapters 8–10.** Build the idea of a tree from group averages, choose its depth within training farms, then predict and compare it with the baseline.

## How to study on your own

This route provides the files, prompts, example results and checks you need to work through it independently. Use a computer that runs R and RStudio, with internet for first downloads and live chat. [AI access](01-first-run.ipynb#id-1-5-ai-access) gives HKU login instructions and alternative browser chats.

1. Work through Chapters 1–10 in order. Run each matching script block, including supplied blocks whose code is folded on the page.
2. Try each question before reading its explanation or opening a reference answer. Compare your R output with the displayed result; an AI reply's wording may differ.
3. At the end of each chapter, locate the named output and explain one check. Use the completion card to record your progress.
4. If you get stuck, follow the [recovery guide](../reference/troubleshooting.md): check the error, restart from the reference script, and repair one small step. Direct source-download links are included there.

For a live AI exercise, use an actual reply and check it in R. If no chat is accessible, complete the supplied inspection exercise and label it that way in your log. At the end, the full-analysis script checks that the supplied workflow can run again from the beginning.

## Read comments and find a code block

In an R script, `#` starts a **comment** outside quoted text: R ignores the rest of that line. Comments explain code to people. Read this example now; Chapter 1 will run the matching block:

```r
# %% double-a-number
count <- 20  # Store 20 under the name count.
count * 2
```

The first line labels the block. The second line stores a value in `count`, and the third calculates twice that value. A `#` inside a quoted string is text, such as `"sample #1"`.

When the book says to run {span .script-block}`BLOCK · double-a-number`, find `# %% double-a-number` in your working script. Select the code below it up to the next `# %%` label, then click **Run** in RStudio. Select complete statements, including closing parentheses.

## One working-file rule

1. Open the chapter's supplied script, for example `scripts/02-minimum-r.R`.
2. Use **File → Save As**. Choose the project's `scripts` folder, and enter **my-02-minimum-r.R** as the filename. The resulting path is `scripts/my-02-minimum-r.R`; do not create a second scripts folder.
3. Work in your **my-** copy. Its supplied code already matches the page; run the matching block instead of pasting another copy.

On a page, closed **Source** and **Output** panels reveal code or results for reading. Run that code in RStudio even when its web panel stays closed. Labels tell you how to use each block:

| Label | Your action |
|---|---|
| Run / required supplied block | Run it in order. Supplied implementation can stay unread, but later steps may need its objects. |
| Optional exercise / optional display | You may skip this explicitly marked activity. |
| Reference answer | Try the question first, then open it to check your reasoning. |

Save your edits before restarting R. Each chapter names its input and output.

## Know which kind of file you have

| File | What to do with it |
|---|---|
| `.R` script | Open in RStudio's editor, edit your my- copy, save and run code. |
| `.csv` table | Inspect the result table; `read.csv()` reads it into R. |
| `.png` image | Open to view a saved figure. |
| `.rds` checkpoint or model | Let the lesson's `readRDS()` code restore it; opening it as text is not useful. |
| `.txt` note | Read or edit it as plain text, for example your AI-use log. |

Files are saved on disk. Objects in **Environment** exist in the current R session. Restarting R clears those objects, while the files remain. The next lesson must read a saved input or recreate an object before using it.

## Four words to keep nearby

| Word | Meaning in this project |
|---|---|
| Record | One assay result for one farm and sampling round |
| Target | The measurement to predict |
| Training data | Records used to learn the rule |
| Test data | Held-out records used to evaluate the fixed rule |

At the end, show a saved script, a result file and one check you can explain. The optional `templates/completion-card.txt` helps you keep track. Chapter 3 also saves a short AI-use log.

```{admonition} Before you move on
:class: tip
Point to where code runs, name your working file, and explain why MSC matters to dairy quality without treating it as a safety verdict.
```

**Start:** [your first successful R run](01-first-run.ipynb).
