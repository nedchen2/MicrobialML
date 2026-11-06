# 0. Start here

**Time:** about 15 minutes. **Before you start:** a browser; no installed software is needed for this chapter.

By the end, you should know what you are trying to predict, where code runs, and what evidence you will save.

## 0.1 What are we making?

Imagine that you are helping a dairy researcher. They have measurements from several farms. You want to predict a microbial measurement from a **new farm**, not simply describe records already available to you.

Our first model makes the same prediction for every new sample: the average outcome in the training data. This is a *baseline*. Later models must justify their extra complexity by improving on a sensible reference.

For now, keep four words in mind:

| Word | Plain meaning in this project |
|---|---|
| Record | One microbial test result from one farm and sampling round |
| Outcome / target | The value we want to predict |
| Training data | Records the procedure may learn from |
| Test data | Held-out records used to evaluate a fixed procedure |

We will explain logarithms, groups and error metrics when we need them. You do not need to memorize a list of algorithms first.

## 0.2 Three places, three jobs

![The textbook, AI chat and RStudio have different roles.](../assets/three-places.svg)

1. **Read this book** to understand the current task and see an example.
2. **Ask an AI assistant** for a small plan or a short piece of code. An institution-approved chat interface is enough; no API key is needed.
3. **Run the code in RStudio.** R executes it. Look at the output and check it before moving on.

When a step says **R script**, put the code in a saved `.R` file. When it says **AI chat**, paste the prompt into your assistant. Do not paste an AI prompt into the R console.

## 0.3 What does “vibe coding” mean here?

You describe a task in ordinary language and use AI to help create or repair code. You remain responsible for choosing the task, protecting the test set, checking the calculation and explaining the result.

Use this loop:

> State one task → request a small step → run it → inspect the evidence → accept or repair → save.

If you cannot explain a step, ask for an explanation or a smaller example. Do not add five more steps on top of an unclear first one.

## 0.4 Your evidence folder

The student project keeps inputs, code and outputs together:

```text
microbial-ml/
  microbial-ml.Rproj
  scripts/
  data/
  outputs/               created when you run a lesson
```

- `.Rproj` opens the project in RStudio.
- `.R` files contain instructions for R.
- `.csv` files contain tables.
- `outputs/` holds the files your analysis produces.

The project folder is a real folder on your computer. The *Environment* pane is a view of objects currently in memory. Saving a script does not automatically save every object in memory; we will rebuild objects by rerunning the script.

## 0.5 The scientific boundary

This project studies a microbial quality measurement. It does not establish whether a particular milk product is safe to drink. A good prediction also does not prove that changing a farm practice causes a change in counts.

Only public or institution-approved information should be given to an external AI tool. The practice data in this book are explicitly invented. The real data have their own authors and provenance.

```{admonition} Checkpoint 0
:class: tip
Before continuing, explain these three things to a partner: where code runs, what the outcome is, and why a baseline is useful. Name the file type you will save your R instructions in.
```

**Try a change:** write one sentence about a different microbial outcome you might predict. State whether it is a number or a category. This pilot uses a numerical outcome; a category requires a different task and evaluation.

**Next:** [make your first successful R run](01-first-run.ipynb).
