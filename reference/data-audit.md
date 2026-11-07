# The milk data at a glance

## Study data card

| Question | Answer |
|---|---|
| What is one record? | One MSC result for one farm and sampling round. A farm can contribute records from several rounds. |
| What do we predict? | Mesophilic spore count (MSC) is recorded in CFU/mL. The model predicts its base-10 logarithm, `log10_msc`. |
| Which records are used? | **525 MSC records from 102 farms** after applying the assay and eligibility filters below. |
| How are farms split? | **81 training farms with 420 records** and **21 test farms with 105 records**. All records from one farm stay together. |

The assay and survey files come from an organic milk study. [Qian and colleagues (2025)](https://doi.org/10.1016/j.jfp.2025.100477) · [Authors' repository](https://github.com/FSL-MQIP/OREI_ML_Inference)

## How we get to 525 records

| Step | Records |
|---|---:|
| Read the original table containing several milk assays | 2,736 |
| Select the MSC assay | 562 |
| Keep records with no recorded note and a positive, finite concentration | 525 |

The 37 excluded records have laboratory notes: 34 laboratory errors, two TNTC results (too numerous to count), and one unresolved note.

**The 525 records include 30 below-limit results.** The assay's detection limit was **0.5 CFU/mL**. The authors used **0.125 CFU/mL** to represent results below that limit, whose exact concentrations are unknown. We keep the stored value and flag those rows with `left_censored`. [Chapter 5’s data preparation](../chapters/05-meet-real-data.ipynb)

## Which survey inputs does the tree use?

The two candidate inputs are **pasture hours per day** and **number of milking cows that day**. We match survey and lab rows by farm and sampling round. There are **29 lab records without a matching survey row** and **two additional matched training records with missing cow counts**. The model uses medians learned from the fitting records to fill missing inputs in a separate copy. [Milk data dictionary](../data/data-dictionary.csv) · [Survey predictor dictionary](../data/predictor-dictionary.csv)

## Tree settings

```{admonition} View the fixed rpart settings
:class: note dropdown

We copy `fixed_tree_settings` and vary `maxdepth` for the training-farm comparison. The other settings stay fixed.

| Setting | Supplied value and role |
|---|---|
| `maxdepth` | Compare 1, 2 and 3 within the training farms |
| `minsplit`, `minbucket` | At least 20 records to consider a split and at least 10 in each leaf |
| `cp` | 0, so this comparison uses no additional complexity penalty threshold |
| `xval` | 0 because the lesson handles validation in whole-farm groups |
| `maxcompete`, `maxsurrogate`, `usesurrogate` | 0, with inputs prepared using the lesson's median rule |

In rpart, `method = "anova"` selects a regression tree for a numeric outcome.
```

## How do I get the data?

Chapters 5 and 8 download the two study CSVs from fixed versions of the authors' files. You can also save those same CSVs with your browser. [Source-file recovery](troubleshooting.md#download-the-source-files-yourself)

File versions, checksums and reuse details are in the [full provenance record](https://github.com/nedchen2/MicrobialML/blob/main/DATA_NOTES.md).

## How to interpret the results

The comparison uses one split from this study. Some farms contributed repeated samples. Chapters 7 and 10 score predictions on the same 105 test records. The scores include the authors' stored values for below-limit results.

The exercise assumes the survey inputs are available before the lab result. The tree uses training medians where survey inputs are missing. Test records from another region would be needed to assess prediction there. A study of a farm practice's effect or a product's safety would need evidence suited to that question. [Final comparison in Chapter 10](../chapters/10-test-tree.ipynb)
