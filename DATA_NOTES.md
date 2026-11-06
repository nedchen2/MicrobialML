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

The combined file also contains already processed predictors, including an outcome-derived farm summary and globally imputed values in the accompanying author code. A future predictor-based lesson needs a separate leakage and availability audit. The baseline uses none of those columns.

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

The original assay-file version, MSC eligibility rule, unit, encoded-limit treatment, target, group split, baseline and arithmetic checks are fixed and executed. Management/weather feature selection, missingness treatment for those predictors, formal model comparisons and the remaining five-model lessons are later work. The candidate is suitable for the **data-to-baseline pilot** on those terms.

## Details outside the beginner learning goals

The fixed RNGkind settings and radix sort support stable farm assignment across author runtimes. The prepared RDS container carries the eligible data and audit counts; the split container carries train/test tables, identifiers and the completed audit. Students must understand the roles and locate the files, but do not need to implement container serialization or the reporting machinery.

The visible log-intuition example shows that exponentiating a mean log concentration produces a geometric mean, rather than automatically estimating the arithmetic mean on the original concentration scale. Chapter 7 connects this to the fixed real-data prediction with a training-only scale comparison. The current baseline is evaluated on the log scale.
