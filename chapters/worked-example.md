# Baseline roadmap · Chapters 4–7

After Chapter 3, [start with Chapter 4](04-small-farm-example.ipynb). Use six practice records to see how a baseline works. Then follow Chapters 5–7 to check how well a simple prediction works on milk samples from farms held out of training.

## What you do in each chapter

| Chapter | What you do | What you take forward |
|---|---|---|
| [4. Six records you can check by hand](04-small-farm-example.ipynb) | Predict using the mean from the training farms, then compare the prediction with the held-out farm's measurements. | The method you will later use with real data. |
| [5. Meet the real milk data](05-meet-real-data.ipynb) | Start with the original measurements, select MSC records and prepare the prediction target. | `outputs/checkpoints/msc-prepared.rds`, which Chapter 6 reads. |
| [6. Split the data by farm](06-split-farms.ipynb) | Assign each whole farm to training or testing and check that the groups share no farms. | `outputs/checkpoints/farm-split.rds`, which Chapter 7 reads. |
| [7. Learn and evaluate a baseline](07-baseline.ipynb) | Predict the test records with the training mean, then measure and explain the errors. | `outputs/baseline/scores.csv` and one prediction error you can explain by hand. |

Restart R before Chapters 6 and 7. Each reads the file saved by the preceding chapter. If you see a missing-file error, return to the previous chapter and complete its save step.

## After Chapter 7 · Reproduce the baseline

Open `scripts/worked-example.R` in your student project and save a my- copy. Restart R, select the whole script and click **Run**. Check that it recreates `outputs/baseline/scores.csv`.

**Next.** [Chapter 8 · From one mean to a tree](08-first-tree.ipynb).
