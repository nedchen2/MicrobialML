# Data provenance and method notes

This record is for maintainers. Students can use the shorter [data sheet](https://nedchen2.github.io/MicrobialML/data-audit/).

This page records the data decisions behind the worked example. The classroom score refers to this fixed teaching slice and split, rather than a reproduction of the publication's machine-learning results.

## Source and version

**Publication:** Qian, C., Lee, R. T., Weachock, R. L., Wiedmann, M., and Martin, N. H. (2025). *A Machine-Learning Approach Reveals That Bacterial Spore Levels in Organic Bulk Tank Milk are Dependent on Farm Characteristics and Meteorological Factors.* Journal of Food Protection, 88, 100477. [DOI](https://doi.org/10.1016/j.jfp.2025.100477).

**Author repository:** [FSL-MQIP/OREI_ML_Inference](https://github.com/FSL-MQIP/OREI_ML_Inference).

**Pinned commit:** `aebcac0888599ad34ab2898f5aa2b704c6e7600c`.

**Input:** [Data/Raw Milk Micro Data.csv at that commit](https://github.com/FSL-MQIP/OREI_ML_Inference/blob/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Raw%20Milk%20Micro%20Data.csv).

The download helper verifies MD5 `66057392dd1c31f6be47ec0c75ee2cb4`. The independently recorded SHA-256 is `36f38d28e750e4354a3646b09fd5c4d624e20fc4dbad76704dabd52ea42bc709`. A checksum identifies the exact bytes used; it does not validate the scientific content.

## What was actually checked?

| Check | Finding |
|---|---|
| Original assay table | 2,736 rows, five columns |
| Assay record counts | APC 563; BAB 513; MSC 562; PSC 536; TSC 562 |
| Selected assay | MSC only |
| Raw MSC notes | 525 missing/blank; 34 laboratory errors; two TNTC; one other note |
| Eligibility | No note; concentration positive and finite |
| Eligible MSC | 525 farm-round records, 102 farms |
| Duplicate eligible farm-round keys | None |
| Missing eligible concentrations | None |
| Encoded detection-limit values | 30 at 0.125 CFU/mL |
| Transformation | log10 concentration in CFU/mL |
| Training / test | 420 / 105 records from 81 / 21 farms |
| Farm overlap | Zero |

The selection is reproducible in `scripts/worked-example.R`, and its counts are written to `outputs/baseline/data-audit.csv` when you run it.

## Why the earlier combined table had 528 MSC rows

The author's combined `FarmData.csv` retains 528 positive MSC records, including the two TNTC records and the record with another note. This pilot starts from the original assay table and applies the explicit eligibility rule above. Its 525 records match the publication's stated MSC sample size, but matching a count alone is not proof of identical preprocessing.

The combined file also contains already processed predictors, including an outcome-derived farm summary and globally imputed values in the accompanying author code. The baseline uses none of those columns. The first tree instead starts from the original survey and the separate audit below.

## Original survey audit for the first tree

The fixed [Farm Survey Data.csv](https://github.com/FSL-MQIP/OREI_ML_Inference/blob/aebcac0888599ad34ab2898f5aa2b704c6e7600c/Data/Farm%20Survey%20Data.csv) contains 540 farm-round rows, 60 columns and 101 farms, with no duplicate keys. Its Git blob is 96760873b9be70217b017e6ab9f5fc092a9da716; MD5 is 948ed520f7564bda2694111b56ccc8cb and SHA-256 is 571ad1d90dc541114f4c58e464bf60d273c376c414899ce9f7678bfd9629e28c.

The two frozen inputs are pasture hours/day and current number of milking cows; exact source questions and units are in data/predictor-dictionary.csv. These are contemporaneous self-reported survey answers. Availability before the assay result is a stated intended-use assumption, not prospectively demonstrated. Their selection used definitions and accessibility, not outcome associations or test model performance. FarmID, sampling labels, other assays, microbial summaries, other survey questions and weather columns are excluded from the formula.

Match FarmID and sampling round after trimming whitespace, without changing row order or dropping unmatched targets. Of the unchanged 525 eligible MSC rows, 496 have a matching survey: 402 training and 94 test. The 29 unmatched rows remain, as do two matched training cow counts encoded as ??. Thus pasture hours are missing for 18/11 training/test records, and cow counts for 20/11. The raw survey has no missing pasture hours; ?? denotes two unknown cow counts. It is not a biological zero. Source parsing and these counts are checked at runtime.

Missing predictors receive medians fitted inside each current training partition. Validation-fold medians exclude the hidden farms; final medians use all 420 training records (9 pasture hours, 72 cows). The same medians prepare the 105 test records and later inputs. Source values stay unchanged. No outcome filling, global imputation, complete-case filtering or surrogate splitting is used. A missing questionnaire, including an entirely unrepresented farm, consequently receives a coarse reference input; this limitation remains part of the result.

## Fixed tree selection and evaluation

Before any tree scores were examined, the teaching protocol fixed two inputs, maximum depths 1/2/3, five whole-farm training folds and pooled record-weighted OOF RMSE as the criterion. Seed 2027 and the baseline's fixed RNG settings assign the 81 training farms to batches of 17/16/16/16/16 farms. Each training record has one OOF prediction for each depth. The OOF baseline learns a new mean from the same fitting farms in each fold. MAE is secondary; ties within 1e-12 choose shallower.

The rpart numeric regression uses method anova, cp=0, minsplit=20, minbucket=10, xval=0, maxcompete=0, maxsurrogate=0 and usesurrogate=0; only maxdepth varies. These are fixed teaching settings, not claimed optimal. Built-in row-level cross-validation is disabled. See the [official rpart controls](https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.control.html). Additional full-training fits illustrate training versus OOF errors after selection and never change the chosen depth.

The supplied run selects depth 1. Its split is milking_cows <36.5 versus >=36.5, with 66/354 training records and mean log10 MSC 1.0545454/0.6873386. Pasture hours are not used in this tree. The training-fold-mean baseline has slightly lower OOF RMSE than even the best tree. The final test comparison also favors the baseline (tree RMSE about 0.544897, MAE 0.426426 versus 0.528923 and 0.409148). No variables or controls were revised to improve this visible test result.

The original test split was already public in the baseline lesson. This is a fixed descriptive teaching comparison, not an independent blinded validation or a claim of statistical superiority. No uncertainty interval or significance test is supplied. Training leaf sizes count repeated records, not independent farms. Cut positions and input-profile comparisons do not identify causal interventions or safety limits.

Verification independently reconstructs all 15 validation trees' node means and routes from original fitting records, all fold/final medians, pooled OOF metrics, final tree predictions and scores. A separate test changes only held-out features and outcomes to extreme values and requires the Chapter 9 choice, medians and fitted structure to remain unchanged. The complete reference baseline outputs remain numerically unchanged.

## Detection limits are part of the target definition

The publication describes replacing undetected MSC measurements by one quarter of the 0.5 CFU/mL detection limit. The encoded value is therefore 0.125 CFU/mL. The pilot retains and flags it; it is not a measured point concentration. The main score and the separate quantified-test-subset score are both explicitly labeled.

Changing this treatment changes the target and potentially the result. Excluding flagged rows is not a general remedy, and their unobserved true values are not recovered by using a regression model.

## Prediction setting and interpretation

The target is a held-out sample from a new farm within the represented study setting. Whole-farm separation prevents a farm appearing in both training and test. It is not a prospective study, does not guarantee transport to a new region or production system, and does not establish that all observations are independent.

The score gives each eligible test record equal weight. It is a single-split descriptive evaluation; uncertainty intervals and formal comparisons are not supplied in this pilot. Repeated farm sampling must also be considered when later teaching coefficient inference.

The outcome is a microbial quality measurement. No pathogen-specific abundance, causal effect or food-safety decision follows directly from it.

## Files and redistribution

The author repository is publicly accessible. An explicit redistribution license for the repository's complete raw dataset was not established in this review. The student ZIP therefore contains a pinned original-source downloader and checksum, rather than a repackaged complete raw dataset. The generated local outputs are produced on the student's computer. Public book outputs show limited examples and aggregate checks with attribution.

The first download needs internet access; later runs use the verified local file. If a source becomes unavailable, the TA should supply an institution-approved access route. Do not substitute invented observations while labeling them as real data.

## What is finalized for this pilot?

The original assay and survey versions, MSC target, group split, baseline and first shallow tree are fixed and executed. Further predictors/models, repeated validation, uncertainty estimates, formal comparisons and prospective deployment checks are later work. The candidate supports this **baseline-to-first-tree teaching example** on those terms.

## Details outside the beginner learning goals

The fixed RNGkind settings and radix sort support stable farm assignment across author runtimes. The prepared RDS container carries the eligible data and audit counts; the split container carries train/test tables, identifiers and the completed audit. Students must understand the roles and locate the files, but do not need to implement container serialization or the reporting machinery.

The visible log-intuition example shows that exponentiating a mean log concentration produces a geometric mean, rather than automatically estimating the arithmetic mean on the original concentration scale. Chapter 7 connects this to the fixed real-data prediction with a training-only scale comparison. The current baseline is evaluated on the log scale.
