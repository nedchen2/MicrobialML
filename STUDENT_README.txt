MICROBIAL ML — BEGINNER LEARNING PATH

Textbook: https://nedchen2.github.io/MicrobialML/

1. Extract this ZIP first. Install R and RStudio Desktop using the textbook guide.
2. Open microbial-ml.Rproj in RStudio. Keep the folders together.
3. For each chapter open its supplied scripts/NN-name.R, then File > Save As
   scripts/my-NN-name.R. Edit your my- copy; keep the reference.
4. The supplied file already contains the page's code. Select a short block in
   Source and click Run (Ctrl+Enter Windows; Cmd+Enter macOS). Inspect the Console
   before continuing. Source executes a full script but may print fewer values.
   Supplied blocks still need to run when instructed, even if their code is
   collapsed on the web page. Expand details only when you need them.
5. Follow 01-first-run, 02-minimum-r, 03-working-with-ai, then
   04-small-farm-example. The first two practice CSVs are explicitly invented.
6. Restart R before 05-meet-real-data.R. Its helper downloads a pinned original
   author CSV and checks the checksum. It saves outputs/checkpoints/msc-prepared.rds.
7. Restart R, run 06-split-farms.R, then find outputs/checkpoints/farm-split.rds.
8. Restart R, run 07-baseline.R, then inspect outputs/baseline for scores and a plot.
9. To rebuild the whole REAL-data analysis, restart R and run a my- copy of
   scripts/worked-example.R from top to bottom. No previous checkpoint is needed.

The optional templates/completion-card.txt helps you record a script, output,
explanation and check. Chapter 3 creates outputs/ch03/ai-use-log.txt; edit and save your actual
route. Its illustrative dialogue is a teaching example, not a real model log.
Use the approved chat when available. No additional R packages, API keys,
Python, Node.js or Jupyter Book are needed for the student analysis.

The changed-copy exercise creates outputs/practice/practice_counts_changed.csv.
Its mean is 25 and it has zero missing counts. The old one-missing rule is FALSE
on purpose. The original data/practice_counts.csv is preserved.

Real data: Qian et al. (2025), DOI 10.1016/j.jfp.2025.100477, author repository
FSL-MQIP/OREI_ML_Inference. The complete source dataset is downloaded from its
fixed author URL, not redistributed in this ZIP. First access requires internet.

Expected real baseline: 420 training records/81 farms; 105 test records/21 other
farms; no farm overlap; RMSE about 0.529 and MAE about 0.409 log10 CFU/mL.
Toy original-scale error values cannot be compared directly with log-scale errors.
These microbial-quality results do not establish causality or product safety.
