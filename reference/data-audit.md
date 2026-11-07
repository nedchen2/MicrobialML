# The milk data at a glance

Use this sheet to check the scientific choices behind Chapters 5–10.

## What are we using?

**Source:** [Qian and colleagues' organic milk study (2025)](https://doi.org/10.1016/j.jfp.2025.100477), with data in the [authors' repository](https://github.com/FSL-MQIP/OREI_ML_Inference).

A selected row is one **MSC result from one farm and sampling round**. MSC means mesophilic spore count, in CFU/mL. Farms contribute repeated records.

## Which records enter this exercise?

| Decision | Result |
|---|---|
| Read the original multi-assay table | 2,736 records |
| Select MSC | 562 records |
| Require no note and a positive, finite count | 525 records from 102 farms |
| Keep the authors' below-detection encoding and flag it | 30 records at 0.125 CFU/mL |
| Predict log10 MSC | Errors are on the transformed scale |
| Hold out whole farms | 81 training farms / 21 test farms; no overlap |

The authors stored 0.125 CFU/mL, one quarter of the 0.5 CFU/mL detection limit, for records with unknown concentrations below that limit. Our teaching subset excludes 34 records with laboratory errors, two TNTC results and one unresolved note.

## What does the tree add?

The original farm survey supplies **current pasture hours/day** and **number of milking cows that day**. We join by farm and round, preserving all 525 outcomes and the same split. There are 29 unmatched records and two additional unknown training cow counts. Missing predictor values use medians learned from the fitting records only, separately within each validation fold.

Five batches of training farms compare maximum tree depths 1, 2 and 3; the lowest pooled out-of-fold RMSE chooses depth. The final test farms do not choose it. The supplied depth-1 tree has test RMSE about 0.545 versus 0.529 for the baseline, so extra complexity did not improve this comparison.

## Tree settings

This is optional reference for the supplied `fixed_tree_settings` object. Copying it and changing `$maxdepth` keeps the rest of this teaching comparison fixed.

| Setting | Supplied value and role |
|---|---|
| `maxdepth` | Initially 1; compare 1, 2 and 3 within training farms |
| `minsplit`, `minbucket` | 20 records needed to consider splitting; at least 10 records in a leaf |
| `cp` | 0; no additional complexity penalty threshold in this comparison |
| `xval` | 0; turn off rpart's internal validation because our lesson explicitly validates whole farms |
| `maxcompete`, `maxsurrogate`, `usesurrogate` | 0; use the primary learned rules and our explicit missing-input preparation |

We hold these settings fixed while comparing depths. The four invented records in Chapter 8 are for practising the arithmetic. The fitted tree uses at least 20 records to consider a split. In rpart, `method = "anova"` tells the software to fit a regression tree for a numeric outcome.

## What can the result support?

The scores compare predictions on 105 records from 21 held-out farms in this study. Some farms contributed repeated samples. Chapter 7 scores the baseline on these same test records before the tree lessons. The comparison uses the authors' below-limit values and assumes the survey inputs are available before the MSC result. The tree uses training medians to fill missing survey values.

To assess performance in another region, we would need test records from that region. Estimating the effect of changing a farm practice would require a study designed around that question. Product safety requires evidence about the specific hazards of concern.

## How do I get the data?

Run the supplied download blocks in Chapters 5 and 8. They retrieve fixed author-file versions and check them; complete raw datasets are not inside the student ZIP. First access needs internet. If it fails, follow the [download recovery steps](troubleshooting.md#download-the-source-files-yourself).

For citation, version identifiers, checksums and detailed reuse notes, maintainers can consult the [full provenance record](https://github.com/nedchen2/MicrobialML/blob/main/DATA_NOTES.md).
