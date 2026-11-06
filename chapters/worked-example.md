# Worked example: your route from data to a baseline

**Question:** what error do we get when predicting milk MSC for samples from farms not used to learn the rule?

Start after Chapters 0–3. First learn the decisions with six invented records; then apply them to real measurements.

## Follow the analysis

**[4. Work it out by hand](04-small-farm-example.ipynb)**

Hold out one farm, predict a mean and calculate two errors. Save `outputs/toy/error-table.csv`.

**[5. Understand the real measurements](05-meet-real-data.ipynb)**

Read a row, select MSC and make the target-limit treatment explicit. Save `outputs/checkpoints/msc-prepared.rds`.

**[6. Keep farms together](06-split-farms.ipynb)**

Split whole farms and check their shared labels. Save `outputs/checkpoints/farm-split.rds`.

**[7. Evaluate and explain](07-baseline.ipynb)**

Fit the training mean, inspect errors and save the result table and plot.

## Continue after restarting R

Each real-data chapter reloads the file saved by its predecessor. Restart R before Chapters 6 and 7; no earlier in-memory object is needed. A missing file means you should complete the preceding chapter.

Run blocks labeled **supplied** unchanged. Their code is collapsed on the page when its implementation is not a learning goal; you can expand it to inspect it. A collapsed block still needs to run when the lesson instructs you to use it.

## Recreate the complete result

After the guided route, open `scripts/worked-example.R` from the [student project](../downloads/microbial-ml-student.zip). Save a my- copy, restart R, select the complete script and Run. It recreates all real-data inputs and final outputs.

**Your evidence:** a saved script, `scores.csv`, `training-distribution.png`, a short AI-use log, and a hand reconstruction of one residual. Explain the new-farm setting and the training-only mean. Use the [data sheet](../reference/data-audit.md) to check source and measurement decisions.
