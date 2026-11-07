# Reference: File > Save As scripts/my-01-first-run.R before editing.
# Chapter 1. Open microbial-ml.Rproj before running this script.
# Text after # is a comment for people. A # %% line labels the next block.
# %% arithmetic
1 + 1
# %% store-sample-name
sample_name <- "milk"
sample_name
# %% double-a-number
count <- 20  # Store 20 under the name count.
count * 2
# %% check-project-folder
project_folder <- getwd()  # Store the path of R's current working folder.
basename(project_folder)  # Show only the last folder name in the path.
file.exists("microbial-ml.Rproj")  # TRUE if this file is in that folder.
# %% save-first-result
dir.create("outputs/practice", recursive = TRUE, showWarnings = FALSE)
writeLines("My first successful R run.", "outputs/practice/first-run.txt")
file.exists("outputs/practice/first-run.txt")
# %% read-first-result
readLines("outputs/practice/first-run.txt")
