AI-ASSISTED MICROBIAL ML: STUDENT PILOT

1. Extract this ZIP into a folder on your computer. Do not work inside a ZIP preview.
2. Install R and RStudio Desktop using their official sites if necessary.
3. Open microbial-ml.Rproj in RStudio.
4. Open scripts/01-first-run.R and run short blocks with Ctrl+Enter (Windows)
   or Cmd+Enter (macOS). Continue with scripts/02-minimum-r.R and
   scripts/03-working-with-ai.R alongside the textbook.
5. Restart R before the complete worked example. Open and run
   scripts/worked-example.R from the top. It calls scripts/course_setup.R,
   downloads one pinned original author CSV if needed, checks its checksum,
   and writes results to outputs/baseline.

Core lessons use base R only. No extra student R packages or API keys are needed.
The first real-data download requires internet. Subsequent runs use the cached file.
Keep the folder structure together. The .Rproj file establishes the working folder.

data/practice_counts.csv is an explicitly invented four-row exercise.
Real data: Qian et al. (2025), DOI 10.1016/j.jfp.2025.100477.
Original authors: FSL-MQIP/OREI_ML_Inference on GitHub.
The helper pins the source version; the complete raw dataset is not redistributed
in this ZIP. Read the online data audit before reusing the data.

Expected baseline in the supplied split: 420 training records from 81 farms;
105 test records from 21 different farms; no farm overlap; RMSE about 0.529
and MAE about 0.409 log10 CFU/mL.

These are microbial quality results, not a milk-safety decision.
