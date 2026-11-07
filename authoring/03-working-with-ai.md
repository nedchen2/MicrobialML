# 3. Ask, run, inspect and repair

**Open:** the project, restart R, and Save As `scripts/my-03-working-with-ai.R` from the supplied script.

**Your question:** how can you tell whether AI-generated code has completed your task?

Follow one milk-sample summary from an incomplete request to a checked result. Complete Sections 3.1–3.6 in order; they work without a chat account. Section 3.7 adds a short object-name error exercise. Section 3.8 is an optional live-chat attempt. No packages are needed.

## 3.1 Know your task before asking

Run `context` to display the same invented data used in Chapter 2:

{{r:context}}

One row is one milk sample. The recorded counts are 10, 20 and 30 CFU/mL; the fourth result is missing. For this exercise, `NA` means no valid measurement was recorded. It does not mean zero or a result below a detection limit.

Your task is to report the **mean of the recorded counts**, together with the number of recorded and missing results. Leave the original missing value unchanged.

**Before using AI:** write down the recorded count, missing count and mean you expect. Which samples can contribute to that mean?

```{admonition} Open after your hand calculation
:class: tip dropdown
There are 3 recorded counts and 1 missing result. The recorded-count mean is (10 + 20 + 30) / 3 = 20 CFU/mL. This describes three valid measurements, not four complete measurements.
```

You already met `NA` in Chapter 2. Here you will use it to check someone else's code. If needed, revisit [what the missing result means](02-minimum-r.ipynb#id-2-3-decision-what-does-the-missing-result-mean).

## 3.2 Read a request that leaves something out

A chat assistant does not automatically see the objects or table open in RStudio. Read this request; save an actual chat attempt for Section 3.8:

````{admonition} You → AI: an incomplete request
:class: student-turn
```text
I am using base R in RStudio. My data frame practice has 4 rows and 3 columns:
sample_id, count_cfu_ml and storage_hours. Each row is one invented milk sample.
count_cfu_ml is the colony count in CFU/mL.

Calculate the mean of count_cfu_ml, rounded to two decimal places.
Give me R code that I can run.
```
````

**Pause:** what do you know about the data that this message does not tell the assistant? Does it say how to handle a missing measurement?

The next section reproduces a two-line AI reply reported by the course author during a test. Its original object name was `milk`; we changed only that name to `practice` so it runs with this lesson's data. The request above and the follow-up below were written for this lesson; they are not a verbatim transcript of that test. The later fill-zero reply is a deliberately constructed teaching example.

## 3.3 Predict the output, then run

Before running, predict the output of this reply. Will it be 20, 15, `NA`, or an error? Run `first-answer`:

{{r:first-answer}}

`round(value, 2)` rounds a value to two decimal places. The first line stores a result; the second displays it.

The book displays `<NA>` here. In the RStudio Console, expect `[1] NA`: `[1]` marks the first displayed value. Both displays mean the result is missing.

```{admonition} Why did the result become NA?
:class: tip dropdown
The ordinary mean includes an unknown value, so R returns NA. The code follows R's rules and does not raise an execution error. Rounding cannot turn a missing result into a known number. This calculation has not produced the requested mean of the recorded counts.
```

A different reply might ask for clarification or supply `na.rm = TRUE` with an explanation. Check the reply you actually receive.

## 3.4 Continue the conversation with evidence

Read this follow-up. It supplies the actual output, the missing-value meaning and the calculation you want:

````{admonition} You → AI: evidence and a clearer task
:class: student-turn
```text
I ran round(mean(practice$count_cfu_ml), 2) and the displayed result was NA.
My object is practice, with columns sample_id, count_cfu_ml and storage_hours.
The count_cfu_ml values are 10, 20, 30 and NA, in CFU/mL.
NA means no valid measurement was recorded; it is not a zero.

I want the mean of the recorded counts, the recorded count and the missing count.
Keep the original data unchanged and do not fill the missing value.
Use base R. Give one small code block and explain which samples enter the mean.
```
````

Run `repaired-answer` for the supplied reference correction:

{{r:repaired-answer}}

Read the three columns: **1 missing, 3 recorded, mean 20**. `is.na()` flags missing values; `!` means “not”, so `sum(!is.na(...))` counts the recorded values. `data.frame()` puts the three summary values into a table.

`na.rm = TRUE` skips missing entries **for this calculation**. It neither changes the original `practice` table nor recovers the missing measurement. Reporting 20 alone would hide how many samples contributed.

## 3.5 A number can still answer the wrong question

Consider a different response to the same task:

```{admonition} Deliberately wrong teaching reply
:class: assistant-turn
“I will replace the missing count with zero and calculate the mean.”
```

**Predict first:** what number would this produce? Run `faulty-answer`. It changes a separate `working` copy, so the original `practice` table is preserved:

{{r:faulty-answer}}

The output is 15: (10 + 20 + 30 + 0) / 4. The code has introduced a fourth value that was never measured.

Run `inspect-answer` to check the original missing count and compare 15 with your hand calculation:

{{r:inspect-answer}}

The original still has one missing entry. The comparison is FALSE. Getting a number is not sufficient evidence for accepting an analysis.

| Output | What the calculation did | Does it meet this task? |
|---|---|---|
| `NA` | Used an ordinary mean with an unknown value | It has not returned the recorded-count mean |
| `20` | Averaged the three recorded counts | Yes, with the recorded and missing counts reported |
| `15` | Added an assumed zero and averaged four values | No; it changed the data assumption |

If an actual reply fills the missing value, tell the assistant what changed and what to preserve. For example: “Your code returned 15 after replacing NA with zero. I need the mean of 10, 20 and 30, without filling the missing value. Revise only the summary.” Do not describe this constructed example as your own AI interaction.

## 3.6 Check, save and explain your decision

Run the supplied `verify-repair` block. It compares the summary with your hand calculation and checks that the fourth count remains missing. You may expand its code; you do not need to reproduce it from memory:

{{r:verify-repair}}

Accept the summary for the stated task when it reports 1 missing, 3 recorded and mean 20, while preserving the original missing value. These checks do not establish why a real sample's result went missing or whether the recorded samples represent all samples.

Run `save-evidence`, then open **Files → outputs → ch03**:

{{r:save-evidence}}

- **`summary.csv`:** the checked summary, containing 1, 3 and 20.
- **`summary-check.txt`:** the first reply's result, the fill-zero result and the checked mean, plus whether the original fourth count is still missing.
- **`ai-use-log.txt`:** open as text, fill in your actual route and checks, then save. Rerunning preserves an existing log.

```{admonition} Example log for the supplied exercise route
:class: tip dropdown
Route: supplied code-inspection exercises; no live chat used. Task: summarize recorded counts without filling the missing measurement. Initial output: NA. Accepted change: skip missing values for the mean and report missingness separately. Evidence: 1 missing, 3 recorded, mean 20 = 60/3, original NA preserved. Rejected example: filling NA with zero returned 15. Remaining question: why a real measurement might be missing.
```

**Ready to continue?** Explain why the first reply returned NA, why 15 is unsuitable, how you checked 20, and what information belongs in a repair request. Find the saved summary and your completed log. You can finish this main task without the additional exercises below.

## 3.7 Additional practice: repair code that stops

This short exercise covers a different problem: a name in the code does not match a name in your session. Your main summary is already saved; this exercise saves its own record.

An incomplete request such as “I have loaded my milk-count data; calculate its mean, ignoring missing values” leaves out the object name. An assistant might guess `milk_data`, or it might ask for your actual names. The following constructed case gives a missing-name error in a fresh session; it is not another real AI transcript.

**Make R show the error:** restart R and rerun **only `context`** to restore `practice`. In your my- script's `runtime-error` block, select only this line and Run:

```r
mean(milk_data$count_cfu_ml, na.rm = TRUE)
```

R reports `object 'milk_data' not found`. This calculation stopped before it could calculate a mean. Your session still contains `practice`.

Now run the **whole supplied `runtime-error` block** to capture that actual error for the record. Its recording code allows the rest of the script to continue. Run it as supplied:

{{r:runtime-error}}

Keep that block as the failing example. If you already corrected its line, it will report that no error was observed. Restore the block from the reference script to repeat the failure; place your own repair in the live-work area.

````{admonition} You → AI: an object-name repair request
:class: student-turn
```text
Running mean(milk_data$count_cfu_ml, na.rm = TRUE) returned:
object 'milk_data' not found.

My actual object is practice. Its columns are sample_id, count_cfu_ml and
storage_hours. The counts are 10, 20, 30 and NA.
Calculate the mean of the recorded counts using the actual object.
Preserve the original data. Use base R and suggest a hand check.
```
````

Run `runtime-repair` for the reference correction:

{{r:runtime-repair}}

Check the result against 60 / 3 = 20. Run `runtime-save`, then find **outputs → ch03 → runtime-error-and-repair.txt**:

{{r:runtime-save}}

This separate record states whether an R error was observed, its message, the correct object name and the repaired mean. After the restart, rerun Sections 3.1–3.6 only if you want their objects back; their files are still on disk.

## 3.8 Try a live response in its own area

**Optional live activity:** choose a browser chat through [AI access](01-first-run.ipynb#id-1-5-ai-access). If chat is unavailable, the supplied exercises provide a full code-inspection route without TA help.

Restart R, then run **only `context`** before beginning, so your table is available. Find `# %% live-workspace` at the end of your **my-** script. Use these comments as places for your own code:

{{r:live-workspace}}

1. In a new chat, send Section 3.2's incomplete request. If the assistant asks for clarification, answer with the actual data and task. When it returns code, paste only the R lines below **My live AI attempt: first reply**. Check that the code does not replace values or write files. Save, select only your added lines and Run; record the actual output.
2. If needed, adapt Section 3.4's follow-up to what actually happened. Supply the actual column names, invented rows, task and output. Put the new code below **My live AI attempt: revised summary**. Run only those lines.
3. Check 1 missing, 3 recorded and mean 20 against the original data. Display `practice` again to check that its fourth count is still NA. If your first reply was already suitable, verify it and record that no repair was needed.

For optional object-name practice, put the code returned for Section 3.7 below **My live AI attempt: object-name repair** and compare with 20. An assistant may use different code or a different summary layout; judge the task, values and data treatment.

Append your actual prompt, reply, output and check to **outputs/ch03/ai-use-log.txt**. The supplied `save-evidence` block records the lesson's reference results; it cannot record your live chat. If your live code changed `practice`, restart R and rerun `context` to reload the original CSV, then ask for a summary that preserves the data. Use only the invented rows here, and ask the assistant to avoid edits to files.

**Next:** [six farm records you can check by hand](04-small-farm-example.ipynb).
