# 3. Work with AI in small steps

**Time:** about 25 minutes. **You need:** an AI chat interface approved for your course, RStudio, and the student project. Open `scripts/03-working-with-ai.R` in a fresh R session.

The aim is to make AI assistance reviewable. You should be able to explain what you requested, what code you accepted, what R produced, and what convinced you that the step was correct.

## Before your first prompt

1. Open your course-approved AI chat interface. Ask the TA about access if you do not have an approved account; this lesson does not require an API key or a coding-agent subscription.
2. Start a new conversation. Paste the task below into the message box and send it.
3. Wait for the response. Read its assumptions before copying code.
4. Copy only the R instructions from a code block, leaving out the surrounding triple backticks, language label and ordinary explanation.
5. Paste those instructions into an RStudio **script**, save, and run a small block. Do not paste the whole conversation into the R console.
6. Compare the actual output with the expected result. Send the relevant code and exact output back to the assistant if you need a repair.

The assistant may produce a different answer on another run. The same input/output checks still apply.

## 3.1 Begin with a task, not a model name

Compare these requests:

> Do my microbial machine-learning analysis.

> First inspect this table. Tell me what a row represents, identify the outcome and identifiers, and report missing values. Give only the code for this inspection and say what output I should check. Do not fit a model yet.

The second request defines a small job with a stopping point. It also gives you something you can check before an error spreads through the analysis.

## 3.2 Supply five pieces of context

| Context | Example for our project |
|---|---|
| Scientific task | Predict log10 MSC for a sample from a held-out farm |
| Actual input | The relevant column names and a data dictionary |
| Constraints | Base R; keep records from the same farm together |
| Expected output | A row count, a small table, a saved CSV |
| Verification | Check no training/test farm overlap; reconstruct the mean |

Do not ask AI to invent what an abbreviation or concentration unit means. Give the dictionary or ask it to identify the missing information.

## 3.3 A prompt you can adapt

**Where: AI chat.**

> You are helping me learn R, and I have no coding background. I am working in an RStudio project. My current goal is [one task]. My input is [file/object and exact columns]. One row represents [unit]. Please propose a short plan, list assumptions, and give only the first small code block. Explain where I should run it, what output to expect, and one independent check. Use base R and do not change unrelated files. If information is missing, say what you cannot determine.

Replace the square-bracketed descriptions with real information. A template is a reminder of context; it is not a magic phrase.

## 3.4 Check a number without relying on AI's confidence

Suppose AI claims that the mean of 10, 20 and 30 is 30. You can test the claim directly:

{{r:verify-mean}}

The result is 20, and the assertion passes. “I ran the code” and “I checked the calculation another way” are different pieces of evidence.

**Ask a follow-up:** “Your result was 30, but R and my arithmetic both give 20. Identify the incorrect step and revise only that step.” Verify the revision yourself.

## 3.5 Give AI useful information when code fails

Prepare a tiny object with a known result:

{{r:correct-object}}

Now consider the line `mean(milkData$count)`. The code below catches its error so that this lesson can show the message without stopping:

{{r:error-demo}}

The lesson defined `milk_data`, not `milkData`. The names are different. Your ordinary code does not need `tryCatch()` just to calculate a mean; it is used here to display an intentional error safely.

Here is a useful error report to paste into AI chat:

```text
Goal: calculate the mean of the count column in base R.
I ran:
milk_data <- data.frame(count = c(10, 20, 30))
mean(milkData$count)

R says: object 'milkData' not found
Expected result: 20.
names(milk_data) returns: "count"
Please explain the error and fix only the failing line.
```

Run the localized repair:

{{r:repair}}

Saving the last working script gives you a place to recover from if a later repair breaks something else.

## 3.6 Three different kinds of failure

| Type | Example | Evidence to inspect |
|---|---|---|
| Execution | File or object not found | Working folder, actual filenames and object names |
| Analysis | The same farm occurs in training and test | The overlap of group identifiers |
| Interpretation | AI says gloves cause lower counts from observational data | Study design and the distinction between prediction and causation |

A script may run perfectly while making the second or third type of error. “No error message” is not a scientific validation.

## 3.7 Keep a short AI-use log

Use a text or Markdown file. One entry can be four lines:

```text
Task: repair an object-name error in a mean calculation.
Accepted change: milkData -> milk_data in one line.
Evidence: R returns 20; hand calculation also returns 20.
Remaining question: none for this calculation.
```

Keep the prompts or responses needed to explain important decisions. You do not need to submit a giant conversation dump. Follow your course's AI-use and disclosure policy.

## 3.8 Review an answer before running it

Ask yourself:

1. Does this code solve the task I stated?
2. Does it use the actual objects and columns?
3. Does it change data, files or assumptions I did not ask it to change?
4. What result can I check independently?
5. What uncertainty is still unresolved?

Use public practice material or information approved by your institution. Do not paste private participant, farm, patient or unpublished research information into an external assistant without appropriate authorization.

```{admonition} Checkpoint 3
:class: tip
Show one task specification, one localized error report, a corrected run and a verification. Explain why rerunning the same code twice is not an independent calculation check.
```

**Exercise:** an assistant proposes replacing every missing count with zero and then reporting a mean. Write a follow-up that asks it to explain the assumption, report the missingness, and separate the known data from an imputation decision. Use Chapter 2 to check the answer.

[Download this chapter's R script](../scripts/03-working-with-ai.R). **Next:** [a complete real-data example](worked-example.ipynb).
