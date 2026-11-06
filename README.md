# Microbial ML

**A first R and AI-assisted coding journey for Machine Learning for Food Safety and Toxicology.**

Start with no programming experience. Learn to ask a small scientific question, run R code, inspect the evidence and explain what the result supports.

## Start learning

**[Open the online textbook →](https://nedchen2.github.io/MicrobialML/)**

Read in your browser. Download the **complete student ZIP** from the book's [Downloads page](https://nedchen2.github.io/MicrobialML/downloads/), extract it, and open `microbial-ml.Rproj` in RStudio.

Students need R and RStudio. No GitHub account, Python, Node.js, Jupyter Book, API key or additional R package is required for the supplied analysis. The real-data example needs internet for its first download. Use the course-approved AI chat; a clearly labeled illustrative dialogue is also provided for inspection practice.

## Your learning route

| Part | What you will do |
|---|---|
| [0. Start here](https://nedchen2.github.io/MicrobialML/start-here/) | Understand the task, tools and files you will save |
| [1. First successful run](https://nedchen2.github.io/MicrobialML/first-run/) | Run a line, save a script and find an output |
| [2. Minimum R](https://nedchen2.github.io/MicrobialML/minimum-r/) | Inspect a small table, handle missingness and change a copy |
| [3. Ask, run, inspect and repair](https://nedchen2.github.io/MicrobialML/working-with-ai/) | Check an AI answer against the task and repair an unsuitable assumption |
| [4. Six invented farm records](https://nedchen2.github.io/MicrobialML/small-farm-example/) | Hold out one farm and calculate baseline errors by hand |
| [5–7. Real-data analysis](https://nedchen2.github.io/MicrobialML/worked-example/) | Inspect MSC data, keep farms together, then fit and evaluate a baseline |

Each chapter names a working file, a stopping point, an expected output and a check. Save your edits in a `my-` copy of the supplied reference script. The complete real-data script is included for a final run from the beginning.

## The scientific case

The real example uses organic raw-milk assay data linked by [Qian et al. (2025)](https://doi.org/10.1016/j.jfp.2025.100477). The [data audit](https://nedchen2.github.io/MicrobialML/data-audit/) documents the source, selection and detection-limit treatment. Small practice datasets are explicitly invented. MSC is a microbial-quality endpoint; the baseline does not establish product safety or causality.

This edition covers the beginner-to-baseline route. Predictor-based models are later course material. See [Releases](https://github.com/nedchen2/MicrobialML/releases) for fixed classroom student packages.

## For textbook maintainers

[Build and verify locally](BUILDING.md) · [Publish and update the website](PUBLICATION.md)

The book follows the beginner-oriented approach of [Start Your R Journey](https://nedchen2.github.io/StartYourRJourney/intro.html). R scripts and executed notebooks are checked together before the website is published. A novice classroom trial remains to be completed.
