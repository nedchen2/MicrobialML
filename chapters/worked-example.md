# Worked example: your route from data to a baseline

This is the complete example, divided into short sessions. Start after Chapters 0–3. Each session names its working file, saves a visible checkpoint, and tells you when it is safe to restart R.

**Biological question:** what error do we get when predicting milk MSC for samples from farms not used to learn the rule? **First rule:** the mean training outcome. We will compare later feature-based models with this reference; this edition does not yet fit those models.

| Read in order | What you do | What you leave with |
|---|---|---|
| [4. Six invented records](04-small-farm-example.ipynb) | Hold out one entire farm; calculate predictions and errors by hand | A six-row story and `outputs/toy/error-table.csv` |
| [5. Meet the real data](05-meet-real-data.ipynb) | Read a row; select MSC; document quality and detection-limit rules | `outputs/checkpoints/msc-prepared.rds` |
| [6. Keep farms together](06-split-farms.ipynb) | Hold out whole farms and check overlap | `outputs/checkpoints/farm-split.rds` |
| [7. Learn and evaluate a baseline](07-baseline.ipynb) | Fit the training mean; evaluate, check, save and explain | Scores, predictions, plot and audit counts |

The six-row table is **invented** for hand calculations. Chapters 5–7 use the pinned author data described in the [data audit](../reference/data-audit.md). Their counts and scales must not be mixed.

## How the saved checkpoints help

An R object disappears after a restart. A checkpoint is a file on disk containing the prepared input needed by the next chapter. You may restart R between Chapters 5, 6 and 7: each page explicitly reads its required file. If a checkpoint is absent, the script asks you to complete the preceding chapter. A checkpoint preserves earlier decisions; it does not validate those decisions by itself.

For every page, open its reference script and **Save As a my- copy** before editing. Run the blocks in order. Record a script, output, explanation and check in your completion card.

## The complete script

After the step-by-step route, [download the complete R script](../scripts/worked-example.R), or use it inside the [student project](../downloads/microbial-ml-student.zip). Restart R, open `scripts/worked-example.R`, Save As `scripts/my-worked-example.R`, select the complete script and click Run. It rebuilds all real-data checkpoints and final outputs from the beginning.

This integrated script and the three chapter scripts are generated from the same computational source. You do not need to combine code blocks manually. Source can also execute a script, but it normally shows fewer intermediate results than selecting and running the lines.

```{admonition} Final evidence to show the TA
:class: tip
Find your saved my- scripts, baseline scores.csv, training-distribution.png and AI-use log. Explain what one real row represents, why no farm occurs in both sets, how one residual was calculated, and why the prediction uses only training outcomes. Record what remains uncertain.
```

**Start:** [six invented farm records](04-small-farm-example.ipynb).
