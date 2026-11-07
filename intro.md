---
title: Your first microbial ML project
subtitle: Read, ask, run, check.
---

# Your first microbial ML project

**Machine Learning for Food Safety and Toxicology**

*Congjia Chen · Teaching assistant*

Welcome. This guide is for biology students starting with little or no programming experience. You will use R and AI assistance to work through one microbial prediction project, step by step. Follow the chapters at your own pace, using their example outputs and checks to assess your work.

**[Begin with Chapter 0 →](chapters/00-start-here.md)**

## Why I wrote this guide

I wrote this guide because getting code from AI is only one part of doing an analysis. Once a result appears on the screen, questions remain: Which samples were used? What does this number mean? Did the model make a useful prediction?

We take those questions one step at a time. You will begin with a few records you can check by hand, then work through a real milk microbiology dataset in R. Along the way, you will practise asking AI for small pieces of help, checking its suggestions and explaining your results. My aim is to help you build enough understanding to take responsibility for your analysis.

## About the author

I'm Congjia Chen, a teaching assistant for *Machine Learning for Food Safety and Toxicology*. I also wrote [Start Your R Journey](https://nedchen2.github.io/StartYourRJourney/intro.html), an introductory R tutorial for biology students. This guide continues that approach, with a focus on using AI to support small, understandable and reproducible analyses.

## First edition: feedback welcome

This is the first edition of the guide, and some explanations or code may still contain mistakes. If you notice an error or a step that is hard to follow, please email me at [nedchen2@gmail.com](mailto:nedchen2@gmail.com). Include the chapter or section and a short description; for a code problem, add the relevant code and full error message. Your feedback will help me improve the tutorial.

## Choose your next step

| You want to… | Go to… |
|---|---|
| Run and save something for the first time | [1. Your first successful run](chapters/01-first-run.ipynb) |
| Understand a small table and its missing value | [2. The R you need today](chapters/02-minimum-r.ipynb) |
| Ask AI, inspect its code and repair an assumption | [3. Ask, run, inspect and repair](chapters/03-working-with-ai.ipynb) |
| Understand a farm split and calculate errors by hand | [4. Six records](chapters/04-small-farm-example.ipynb) |
| Complete the real-data analysis | [The Chapters 5–7 route](chapters/worked-example.md) |
| Add predictors and check a first model | [8. From one mean to a tree](chapters/08-first-tree.ipynb) |

## Get ready to work

[Download the student project](downloads/microbial-ml-student.zip), extract it, and open `microbial-ml.Rproj` in RStudio. Read the website; run your calculations in RStudio. Chapter 1 explains installation and the first Run step.

**Your final evidence:** a saved script, a result table, a plot and a short AI-use record. Explain one row, one prediction and one independent check. Chapters 8–10 add a shallow regression tree, using the same question and farm split to test whether extra complexity helps.

[AI access in Hong Kong](chapters/01-first-run.ipynb#id-1-5-ai-access) · [Need a file again?](reference/downloads.md) · [Something went wrong?](reference/troubleshooting.md) · [Data source and decisions](reference/data-audit.md)
