# 3. Ask, run, inspect and repair

**Open:** the project, restart R, and Save As `scripts/my-03-working-with-ai.R` from the supplied script.

**Task:** report the mean of the **recorded** practice counts without filling the missing result. Save a summary and a short AI-use log.

The dialogue below is a scripted teaching example. Use a course-approved live chat when available and record your actual route; the supplied dialogue can also be used as an inspection exercise.

## 3.1 Give the assistant something it can actually use

Run `context`:

{{r:context}}

A chat assistant does not automatically receive your RStudio object. Copy the column names and four-row output from the Console into chat. These rows are invented teaching data; share only approved information in a real project.

````{admonition} You → AI: the request
:class: student-turn
```text
I am learning base R in RStudio. My object practice contains one row per
invented milk sample, with columns sample_id, count_cfu_ml and storage_hours.
I will paste the column names and table below.

Report the missing count, recorded count and mean of the recorded counts.
Leave missing values unchanged. Give one small R block, explain its output,
and suggest a hand check. Do not install packages or change files.
```
````

For a live response, paste only its R instructions below `# My live AI attempt` at the end of your my- script. Save, select that new block and Run. Keep the reference blocks for comparison.

## 3.2 Inspect a plausible but unsuitable answer

```{admonition} Illustrative AI reply
:class: assistant-turn
“I will replace the missing count with zero and calculate the mean.”
```

Run the labeled `faulty-answer` exercise. It changes a separate `working` copy:

{{r:faulty-answer}}

**Pause: 15 is an actual output, but is it the requested result?** The recorded counts total 60 across three samples, so their mean is 20. The proposed code introduced an extra zero.

{{r:inspect-answer}}

The original has one missing entry. The comparison with your hand calculation is FALSE.

## 3.3 Send useful evidence back

````{admonition} You → AI: the feedback
:class: student-turn
```text
I requested the mean of recorded counts with no imputation.
Your code changed NA to zero and returned 15.
The recorded counts are 10, 20 and 30: 60 / 3 = 20.

Revise only the summary step using practice. Preserve its missing value.
Report missing_n, recorded_n and mean_recorded. Do not edit input files.
```
````

```{admonition} Illustrative AI repair
:class: assistant-turn
“Use na.rm = TRUE to summarize the recorded entries, and report missingness separately. This does not estimate the unrecorded count.”
```

Run `repaired-answer`:

{{r:repaired-answer}}

**Read the result:** 1 missing, 3 recorded, mean 20. It describes the three recorded samples.

## 3.4 Decide whether to accept it

**Supplied block — `verify-repair`.** Run it to compare with the hand calculation and check that the source NA is preserved:

{{r:verify-repair}}

These checks support accepting the summary **for the stated task**. They do not tell us why the fourth count is missing.

| If your live reply… | Your next step |
|---|---|
| Already gives a suitable summary | Verify it; use the faulty reply above as a separate exercise |
| Uses another object or column | Send the actual names and request a localized repair |
| Makes a new data assumption | Ask it to justify the assumption against your task |
| Uses different code but gives 1, 3 and 20 | Check that it also preserves the source and describes the recorded samples |

## 3.5 Keep the result and the evidence

**Supplied block — `save-evidence`.** Run it, then open **Files → outputs → ch03**:

{{r:save-evidence}}

- **`summary.csv`:** find 1, 3 and 20.
- **`ai-use-log.txt`:** open as text, fill in your actual route, accepted change and checks, then save. Rerunning preserves an existing log.

```{admonition} Example log for the supplied dialogue
:class: tip dropdown
Route: supplied illustrative dialogue. Task: summarize recorded counts without imputation. Accepted change: remove the zero substitution. Evidence: mean 20 = 60/3, with the source NA unchanged. Remaining question: why the fourth result is missing. No live tool was used on this route.
```

**Ready to continue?** Explain why 15 answered a different question, show the summary file, and identify the check that convinced you to accept 20. In a live-chat log, record the response you actually received.

**Next:** [six farm records you can check by hand](04-small-farm-example.ipynb).
