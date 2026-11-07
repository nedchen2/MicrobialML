MICROBIAL ML — BEGINNER LEARNING PATH

Textbook: https://nedchen2.github.io/MicrobialML/

1. Extract this ZIP first. Install R and RStudio Desktop using the textbook guide.
2. Open microbial-ml.Rproj in RStudio. Keep the folders together.
3. For each chapter open its supplied scripts/NN-name.R, then File > Save As
   scripts/my-NN-name.R. Edit your my- copy; keep the reference.
4. In R, # starts a comment outside quoted text. Our # %% labels mark blocks.
   Run a block by selecting complete code below its label, stopping before the
   next # %% label, then clicking Run. Comments do not calculate anything.
   The supplied file already contains the page's code. Select a short block in
   Source and click Run (Ctrl+Enter Windows; Cmd+Enter macOS). Inspect the Console
   before continuing. The RStudio Source button executes the whole script; the website Source panel only reveals code.
   Supplied blocks still need to run when instructed, even if their code is
   collapsed on the web page. Expand details only when you need them.
5. Follow 01-first-run, 02-minimum-r, 03-working-with-ai, then
   04-small-farm-example. The first two practice CSVs are explicitly invented.
6. Restart R before 05-meet-real-data.R. Its helper downloads a pinned original
   author CSV and checks the checksum. It saves outputs/checkpoints/msc-prepared.rds.
7. Restart R, run 06-split-farms.R, then find outputs/checkpoints/farm-split.rds.
8. Restart R, run 07-baseline.R, then inspect outputs/baseline for scores and a plot.
9. To rebuild the real-data BASELINE, restart R and run a my- copy of
   scripts/worked-example.R from top to bottom. No previous checkpoint is needed.
10. Continue with 08-first-tree.R, 09-choose-tree.R, then 10-test-tree.R.
    Restart R before each chapter. Chapter 8 shows install.packages("rpart") once
    if needed, and library(rpart) in each session; it also downloads the original
    survey. First fit and inspect a tree, then choose depth in Chapter 9.
11. After the tree route, scripts/full-analysis.R recreates BOTH real workflows
    from the beginning. Keep optional changed-input results under another filename;
    this script recreates the supplied reference results.

The optional templates/completion-card.txt helps you record a script, output,
explanation and check. Chapter 3 creates outputs/ch03/ai-use-log.txt; edit and save your actual
route. Its illustrative dialogue is a teaching example, not a real model log.
Chapter 3 also produces a real R object-name error; follow the page's one-line
Run step, then its supplied block to record the error and continue.
AI access: start at https://genai.hku.hk/ with your HKU Portal account, or use
Gemini, Microsoft Copilot or Poe as linked in Chapter 1, section 1.5.
No TA link, API setup or paid subscription is needed for these exercises.
If live chat is unavailable, use the supplied dialogue/code-inspection route
and record it honestly. Follow the website's recovery steps for errors or source
downloads; the optional completion card now covers Chapters 1-10. Chapters 1-7 need only base R; Chapters 8-10
use rpart. Students do not need API keys, Python, Node.js or Jupyter Book.

The changed-copy exercise creates outputs/practice/practice_counts_changed.csv.
Its mean is 25 and it has zero missing counts. The old one-missing rule is FALSE
on purpose. The original data/practice_counts.csv is preserved.

Real data: Qian et al. (2025), DOI 10.1016/j.jfp.2025.100477, author repository
FSL-MQIP/OREI_ML_Inference. The complete source dataset is downloaded from its
fixed author URL, not redistributed in this ZIP. First access requires internet.

Expected real baseline: 420 training records/81 farms; 105 test records/21 other
farms; no farm overlap; RMSE about 0.529 and MAE about 0.409 log10 CFU/mL.
Expected tree: training-only five-fold farm validation selects depth 1; test RMSE
about 0.545 and MAE about 0.426 log10 CFU/mL. It does not beat the baseline here.
Toy original-scale error values cannot be compared directly with log-scale errors.
These microbial-quality results do not establish causality or product safety.

Live AI work: Chapter 3 has a separate live-workspace at the end. Keep the
intentional error examples and paste repairs in that work area. Chapter 7's
three-row preview checks residuals; its full RMSE exercise uses all 105 rows
of the local test object. The optional AI RMSE work area is after the exports.
Files: .R is code, .csv is a table, .png is a figure, .rds is read by R, and
.txt is a plain-text note. Restarting R clears objects but keeps these files.
The full-analysis runner sources the supplied reference workflows; a my-
runner does not automatically use your changed my- chapter scripts.
