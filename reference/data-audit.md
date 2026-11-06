# The milk data at a glance

Use this sheet to check the scientific choices behind Chapters 5–7.

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

## What can the result support?

The score evaluates a fixed baseline on held-out records in this study setting. It does not establish that all records are independent, that a farm practice causes a change, or that a milk product is safe. The limit-value treatment and single split constrain interpretation.

## How do I get the data?

Run the supplied download block in Chapter 5. It retrieves a fixed author-file version and checks it; the complete raw dataset is not inside the student ZIP. First access needs internet. If it fails, use the [help page](troubleshooting.md) or ask the TA for an approved access route.

For citation, version identifiers, checksums and detailed reuse notes, maintainers can consult the [full provenance record](https://github.com/nedchen2/MicrobialML/blob/main/DATA_NOTES.md).
