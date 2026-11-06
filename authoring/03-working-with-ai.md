# 3. Ask, run, inspect and repair

**Estimated session:** 35–50 minutes, longer if you are arranging AI access. This is a planning estimate, not a measured completion time.

| Before running | Your task |
|---|---|
| Input | The invented `data/practice_counts.csv` from Chapter 2 |
| Working file | Open `scripts/03-working-with-ai.R`; Save As `scripts/my-03-working-with-ai.R` |
| Starting state | Open the project and use Session → Restart R |
| Run method | Select the named block and click Run; inspect its result before proceeding |
| Finish with | `outputs/ch03/summary.csv` and your completed `outputs/ch03/ai-use-log.txt` |

The goal is **the mean of the recorded counts**, with the missing count left missing. This specific goal will help us detect code that runs successfully but answers another question.

## 3.1 Give the assistant something it can actually use

Run the `context` block in your working copy:

{{r:context}}

The chat assistant does not automatically receive this RStudio object. Copy the output of `names(practice)` and the four-row table from the Console into the chat. These four rows are invented teaching data. For a real project, share only information approved for that tool.

Start a new conversation in the course-approved chat. Paste this **filled-in task**, followed by the column names and table you just copied:

> I am a biology student learning base R in RStudio. I loaded data/practice_counts.csv into an object called practice. One row is one invented milk sample. The columns are sample_id, count_cfu_ml and storage_hours; one count is NA. My task is to report the number of missing counts, the number of recorded counts and the mean of the recorded counts. Leave the missing value unchanged. First give a short plan, then one small R block using the existing object. Explain its expected output and one hand check. Do not install packages or change files. I will paste my actual input below.

Read the assumptions before running returned code. Copy only R instructions, excluding triple backticks and surrounding prose. At the end of your **my-** script, add a comment `# My live AI attempt`, paste the block below it, save, and select only that new block to run. Keep the supplied reference blocks for comparison.

If chat access is unavailable, follow the supplied dialogue below and set your log route to **supplied illustrative dialogue**. This practises inspection and repair; it does not count as having used a live tool.

## 3.2 Inspect a plausible but unsuitable answer

**The following is a scripted teaching example, not an actual conversation or a promise of what a model will say.** If your live response is already suitable, record that fact; use this faulty response as a separate inspection exercise.

*Illustrative assistant:* “I will replace the missing count with zero and take the mean.”

Run the labeled `faulty-answer` block. It changes a separate copy called `working`, leaving `practice` available for comparison:

{{r:faulty-answer}}

You should see **15**. Before continuing, calculate `(10 + 20 + 30) / 3` by hand. The mean of the three recorded counts is **20**. The assistant has introduced a fourth value without justification and has changed the requested task.

{{r:inspect-answer}}

The original has one missing count, and the comparison is **FALSE**. A successful run alone has not established that the code answers the task.

## 3.3 Send useful evidence back

*Student follow-up in the illustrative dialogue:*

> I asked for the mean of recorded counts with no imputation. Your code changed NA to zero and returned 15. The recorded counts are 10, 20 and 30; their sum is 60 and there are three of them, so the requested mean is 20. Please revise only the summary step. Use practice, preserve its missing value, report missing_n and recorded_n, and explain what the mean describes. Do not modify input files.

This report includes the requested task, actual behavior, conflicting assumption and an independent check. In a live chat, send the code and output you actually received; do not claim that the supplied faulty answer was your assistant's response.

*Illustrative assistant repair:* “Summarize recorded entries using na.rm = TRUE, and report the missingness separately. This does not estimate the unrecorded count.”

Run the `repaired-answer` block:

{{r:repaired-answer}}

Expect **missing_n = 1, recorded_n = 3, mean_recorded = 20**. `summary_table` is a one-row data frame made from those named results.

## 3.4 Check before accepting

{{r:verify-repair}}

The assertions use the hand calculation and check that the fourth source count remains `NA`. They print nothing when they pass; the following message confirms that execution reached the end of the block.

The mean describes the three recorded counts. These checks do not establish why the fourth is missing, whether the samples are representative, or whether excluding missing outcomes is appropriate in another study.

```{admonition} What if your AI returns different code?
:class: tip
Compare the task, objects, missing-value treatment and actual outputs. Different code can be acceptable when it preserves the input and gives 1, 3 and 20 with a justified interpretation. If it uses an unknown object, renamed column or a package, report the exact mismatch and request a localized repair. Do not edit assumptions simply to imitate the sample response.
```

## 3.5 Save the result and a short, honest log

{{r:save-evidence}}

In Files, open **outputs → ch03**. Open `summary.csv` and confirm its three values. Open `ai-use-log.txt` as text, fill in the bracketed fields, and save with Ctrl/Cmd + S. The script creates the log template only when it is absent, so rerunning will preserve your notes.

A completed log for the **supplied dialogue** could say:

```text
Route: supplied illustrative dialogue
Task: summarize the recorded practice counts without imputation.
Context sent: none to an external tool; I inspected the supplied four-row example.
Accepted change: remove the zero substitution; summarize recorded entries.
Evidence: missing_n 1, recorded_n 3, mean 20; 60 / 3 = 20; source NA unchanged.
Remaining question: why the fourth count is missing is unknown.
Tool and date, if used: no live AI tool used for this route.
```

A live-chat log should identify the actual tool, date, accepted change and checks. You do not need to submit an entire conversation dump.

## 3.6 Optional: repair an execution error too

R is case-sensitive. This supplied wrapper displays an intentional error without stopping the executed book:

{{r:object-name-error}}

The defined object is `practice`, not `Practice`. In your ordinary code, repair the name in the failing line. You do not need to write `tryCatch()` to calculate a mean; here it is a teaching wrapper.

| Failure type | Example | Check |
|---|---|---|
| Execution | An object name does not exist | Actual spelling and whether its creation line ran |
| Analysis | A missing measurement was silently replaced by zero | Task, data and transformation |
| Interpretation | A prediction is described as a causal effect | Study design and scope of the evidence |

## Checkpoint 3

Find your saved my- script, summary CSV and completed log. Explain why 15 was unsuitable for this task, why 20 is the requested result, and which route you used. Keep any live AI attempt separately labeled inside your script.

```{admonition} Open after you try: reference checks
:class: tip dropdown
The requested outputs are 1 missing, 3 recorded and a mean of 20. The faulty response averages 10, 20, 30 and an invented zero, giving 15. Correcting it preserves the source NA. A log records the actual exercise or live tool used; the illustrative dialogue is not represented as a real model response.
```

**Next:** [a six-row farm example](04-small-farm-example.ipynb), then the [real-data route](worked-example.md).
