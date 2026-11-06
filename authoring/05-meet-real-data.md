# 5. Meet the real milk data

**Estimated session:** 30–45 minutes, with extra time for the first download.

| Before running | Your task |
|---|---|
| Input | The pinned original-author CSV, downloaded by the supplied helper |
| Working file | Open `scripts/05-meet-real-data.R`; Save As `scripts/my-05-meet-real-data.R` |
| Starting state | Open the project and restart R; Chapter 4 supplies the concepts |
| Stop after | The `save-prepared` block |
| Finish with | `outputs/checkpoints/msc-prepared.rds` |

The question is prediction of MSC for milk from a farm not used to learn the rule. First we must understand and select the measurement. These data are from the study, unlike the invented tables in Chapters 2 and 4.

## 5.1 What does one real row mean?


MSC means **mesophilic spore count**, measured here in CFU/mL. One row in our selected data will be one MSC assay result for one farm and sampling round. A farm can have several rows.

We use the original assay table linked by [Qian et al. (2025)](https://doi.org/10.1016/j.jfp.2025.100477). We exclude records carrying a note and require a positive, finite concentration. This produces 525 records, matching the paper's reported MSC sample size. These are explicit rules for this teaching slice, not a claim to reproduce every step in the paper.

The [data audit](../reference/data-audit.md) explains the source version, exclusions and detection limit. The four-row practice table in Chapter 2 was invented; this table contains real published research data.


## 5.2 Download, then look at rows


**Where: RStudio script.** The supplied helper downloads a fixed author-file version, verifies its checksum and caches it. It uses base R; no package installation is needed. Read `scripts/course_setup.R` if you want to inspect the download code. The helper does not fit a model.

{{r:source}}

Read the first three actual records:

{{r:raw-preview}}

For each row, say: “FarmID identifies the farm; Sampling identifies the round; Test tells me which assay; Conc contains its concentration; Notes records qualification of the result.” A repeated FarmID is expected when the same farm contributes multiple assays or rounds. A unique record is not the same as an independent farm.

The expected shape is **2,736 rows and 5 columns**. `na.strings = c("", "NA")` tells R how missing text is encoded in this file. If the shape or names differ, stop and investigate; do not simply change the assertions to make them pass.

| Column | Meaning and role |
|---|---|
| `FarmID` | Farm identifier; used to keep groups together |
| `Sampling` | Sampling-round label; helps identify a farm-round record |
| `Test` | Assay type; different assays must not be mixed into one outcome |
| `Conc` | The assay-specific concentration; units depend on `Test` |
| `Notes` | Laboratory notes affecting eligibility |

Inspect the assay types:

{{r:assays}}

The whole file is not one homogeneous training table. We first select a specific test.


## 5.3 Select one assay using explicit quality rules


{{r:select}}

There are 562 raw MSC records: 525 have no note, 34 are marked laboratory error, two are marked `TNTC` (too numerous to count), and one has another note. A count marked `TNTC` is not an ordinary quantified value. The other note has not been resolved independently, so this pilot excludes it rather than interpreting it silently.

In the next block, `trimws()` removes surrounding spaces from notes and `is.finite()` checks that a numerical value is neither missing nor infinite. `&` means both conditions must hold; `|` means either can hold. The filtering rule is chosen for data quality, before looking at prediction scores.

{{r:quality}}

You should get **525 eligible records from 102 farms**. The checks also confirm that a farm-round occurs only once in this selected assay. Inspect three eligible MSC rows. Now each displayed concentration belongs to the same assay:

{{r:usable-preview}}

Excluding flagged records can affect representativeness; retain an audit of what was excluded and why.


## 5.4 Understand the target scale and encoded limits


The paper reports replacing below-detection MSC values by **25% of a 0.5 CFU/mL detection limit**: 0.125 CFU/mL. We preserve that encoded value and flag it. We do not call it a precise observed concentration.

{{r:target}}

Thirty eligible records have this encoded value. The other 495 are above it. The equality flag identifies this source's published encoding; it is not a general method for discovering detection limits in arbitrary data.

We predict `log10_msc`, the base-10 logarithm of the concentration:

{{r:log-intuition}}

Log10 values 0, 1 and 2 correspond to 1, 10 and 100 CFU/mL. A negative log value can represent a positive concentration below 1 CFU/mL. It is not a negative number of organisms.

Notice that averaging on the log scale and back-transforming gives about 31.62 for 10 and 100, whereas their arithmetic mean is 55. Our model predicts on the log scale; exponentiating its mean does not automatically estimate the mean on the original count scale.


## 5.5 Save the prepared input for the next session

The following supplied block collects the quality counts in a small audit table. You need to explain the rules and totals; you do not need to memorise this reporting code.

{{r:prepare-audit}}

An **RDS** file saves R objects with their column types. It is an input checkpoint for R, not a spreadsheet to edit in Excel. This file contains the prepared table and audit counts in a named container; the next page reads them back explicitly. The original author CSV stays unchanged.

{{r:save-prepared}}

In Files, open **outputs → checkpoints** and locate `msc-prepared.rds`. `file.exists()` should print TRUE. You do not need to open the binary file to read it; Chapter 6 will use `readRDS()`.

**Checkpoint 5:** find the checkpoint, explain one real row and the MSC unit, report 525 eligible records from 102 farms, and explain why the 30 encoded limit values are not precise observed concentrations.

```{admonition} Open after you try: reference checks
:class: tip dropdown
The original table has 2,736 rows across several assays. The teaching MSC selection retains 525 records from 102 farms. Thirty counts encode 0.125 CFU/mL under the source's below-detection substitution. The next page's input is outputs/checkpoints/msc-prepared.rds. A negative log10 value can correspond to a positive concentration below 1 CFU/mL.
```

**Next:** restart R, then [keep farms together](06-split-farms.ipynb).
