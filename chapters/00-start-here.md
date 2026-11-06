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

**Work with AI — Chapter 3.** Ask, run, repair a real R error, then spot an unsuitable assumption in code that runs. Keep evidence for both repairs.

**Understand the analysis — Chapters 4–7.** Hand-check six invented farm records, then prepare real data, hold out whole farms and evaluate a baseline.

## One working-file rule

1. Open the chapter's supplied script, for example `scripts/02-minimum-r.R`.
2. Use **File → Save As** to create `scripts/my-02-minimum-r.R`.
3. Work in your **my-** copy. Its supplied code already matches the page; run the matching block instead of pasting another copy.

A marker such as `# %% import` labels a block. On a page, closed **Source** and **Output** panels reveal code or results for reading; run the code in RStudio when instructed. Save your edits before restarting R. Each chapter tells you which input to open and which output to find.

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
