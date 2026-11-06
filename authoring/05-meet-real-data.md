# 5. Meet the real milk data

**Open:** restart R and save the supplied script as `scripts/my-05-meet-real-data.R`.

**Question:** what does one row measure, and which records can we use for the MSC task?

## 5.1 Look at the measurements

The source is the organic milk study by [Qian and colleagues (2025)](https://doi.org/10.1016/j.jfp.2025.100477). The supplied helper retrieves the fixed source file and checks that it is the expected version. First use needs internet.

Run `source`, then `raw-preview`:

{{r:source}}

{{r:raw-preview}}

| Field | Read a row this way |
|---|---|
| `FarmID` | Which farm supplied the sample? |
| `Sampling` | At which sampling round? |
| `Test` | Which assay was performed? |
| `Conc` | What concentration was recorded for that assay? |
| `Notes` | Was the result qualified by a laboratory note? |

One farm can appear in several assays and rounds. Check `Test` before assigning meaning to `Conc`; different assays must not be pooled into one outcome.

**Optional inventory — `assays`.** Expand to see all assay record counts. This display does not create an input needed later:

{{r:assays}}

## 5.2 Follow the selection rule

We choose **MSC: mesophilic spore count**, measured here in **CFU/mL**.

{{r:select}}

| Selection | Records |
|---|---:|
| Start with MSC | 562 |
| Exclude records carrying a note | 37 |
| Retain no-note records with a positive, finite concentration | 525 |

The notes comprise 34 laboratory errors, two TNTC results (too numerous to count), and one unresolved note. This is an explicit teaching eligibility rule; exclusion can affect which samples are represented.

Run `quality`. `&` requires both conditions; `|` allows either. The supplied checks stop if the expected counts or unique farm-round keys differ:

{{r:quality}}

You should have **525 records from 102 farms**. Inspect three selected rows:

{{r:usable-preview}}

Now every displayed concentration belongs to the same assay. Do not delete a failed check simply to reach this total; investigate the input and rule.

## 5.3 Define the target honestly

```{admonition} A recorded value can represent a limit
:class: important
Thirty eligible values are encoded as 0.125 CFU/mL: the authors' substitution of one quarter of the 0.5 CFU/mL detection limit. They are not precise measured concentrations. We retain and flag them so the target limitation stays visible.
```

{{r:target}}

We predict **log10 MSC**, not the original concentration. Keep this small conversion table nearby:

| CFU/mL | log10 value |
|---:|---:|
| 1 | 0 |
| 10 | 1 |
| 100 | 2 |

A negative log10 value can represent a positive concentration below 1 CFU/mL. It does not mean a negative microbial count.

**Optional arithmetic — `log-intuition`.** Expand to inspect the conversion and the difference between averaging before and after a logarithm:

{{r:log-intuition}}

## 5.4 Save the prepared input

Select the supplied blocks from `prepare-audit` through `save-prepared`, then Run. They record the selection counts and write a checkpoint for the next session.

{{r:prepare-audit}}

{{r:save-prepared}}

**Find:** `outputs/checkpoints/msc-prepared.rds`. The existence check should be TRUE. Chapter 6 will read this file after a restart.

**Explain before moving on:** one real row, the MSC unit, the 525-record selection, and what the thirty encoded limit values mean. The [data sheet](../reference/data-audit.md) collects these decisions for reference.

**Next:** [keep farms together](06-split-farms.ipynb).
