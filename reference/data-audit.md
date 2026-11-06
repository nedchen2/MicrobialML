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

The 0.125 values represent the authors' substitution of one quarter of a 0.5 CFU/mL detection limit. They are not precise point measurements. The excluded notes comprise 34 laboratory errors, two TNTC results and one unresolved note. This defines a teaching slice, not a reproduction of the paper's full analysis.

## What does the tree add?

The original farm survey supplies **current pasture hours/day** and **number of milking cows that day**. We join by farm and round, preserving all 525 outcomes and the same split. There are 29 unmatched records and two additional unknown training cow counts. Missing predictor values use medians learned from the fitting records only, separately within each validation fold.

Five batches of training farms compare maximum tree depths 1, 2 and 3; the lowest pooled out-of-fold RMSE chooses depth. The final test farms do not choose it. The supplied depth-1 tree has test RMSE about 0.545 versus 0.529 for the baseline, so extra complexity did not improve this comparison.

## What can the result support?

The scores compare fixed procedures on held-out records in this study setting. They do not establish that all records are independent, that a farm practice causes a change, or that a milk product is safe. The limit-value treatment, simple predictor filling, assumed survey availability and single split constrain interpretation. These test farms were already displayed in the baseline lesson; this is a teaching comparison, not a fresh blinded study.

## How do I get the data?

Run the supplied download blocks in Chapters 5 and 8. They retrieve fixed author-file versions and check them; complete raw datasets are not inside the student ZIP. First access needs internet. If it fails, use the [help page](troubleshooting.md) or ask the TA for an approved access route.

For citation, version identifiers, checksums and detailed reuse notes, maintainers can consult the [full provenance record](https://github.com/nedchen2/MicrobialML/blob/main/DATA_NOTES.md).
