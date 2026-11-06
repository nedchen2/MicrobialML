# 6. Keep farms together

**Open:** restart R and save the supplied script as `scripts/my-06-split-farms.R`.

**Input:** `outputs/checkpoints/msc-prepared.rds` from Chapter 5.

## 6.1 Choose the unit to hold out

Our question is prediction for a **farm not used to learn the rule**. All records from a selected farm must therefore stay together. The six-row example shows the idea:

![Training keeps both rounds from farms A and B; testing keeps both rounds from farm C.](../assets/farm-groups.svg)

*Illustration from the invented example. The real split below contains 102 farms.*

A row-wise split can put records from the same farm on both sides. It then answers a different prediction question.

**Check:** seeing a second sample from farm A is not the same as seeing a farm for the first time. Which situation matches our question?

## 6.2 Load and make the real split

Run the supplied `load-prepared` block to reload the saved table. If the file is missing, complete Chapter 5 first:

{{r:load-prepared}}

**The decision:** hold out 20% of the 102 farms, rounding up to 21. Use the supplied seed, 2026, to repeat this selection. Keep these choices fixed while learning the procedure.

The seed lets us reproduce this random choice; the number 2026 does not make the split scientifically better than another seed.

Run the supplied `split` block unchanged. Expand its code if you want to inspect the random selection and row assignment:

{{r:split}}

## 6.3 Read the checks as evidence

| Check | Supplied split |
|---|---:|
| Training farms | 81 |
| Test farms | 21 |
| Training records | 420 |
| Test records | 105 |

Record counts need not divide into exactly 80% and 20%, because farms contribute different numbers of records.

Run `overlap` to inspect the actual shared labels:

{{r:overlap}}

**Expected:** `character(0)`, an empty list of farm labels. If you see any label, repair the split before fitting a model. This addresses farm overlap; it does not establish independence of every record or performance in a new region.

## 6.4 Save a starting point for evaluation

Run the supplied `save-split` block:

{{r:save-split}}

**Find:** `outputs/checkpoints/farm-split.rds`. You can now restart R; Chapter 7 reloads the saved split.

**Explain before moving on:** why both samples from the same farm share a role, and why an empty farm intersection is a better check than row counts alone.

**Next:** [learn and evaluate a baseline](07-baseline.ipynb).
