# Chapter 1. Open microbial-ml.Rproj before running this script.
# %% arithmetic
1 + 1
# %% object
sample_name <- "milk"
sample_name
# %% count
count <- 20
count * 2
# %% folder
project_folder <- getwd()
basename(project_folder)
file.exists("microbial-ml.Rproj")
# %% save
dir.create("outputs/practice", recursive = TRUE, showWarnings = FALSE)
writeLines("My first successful R run.", "outputs/practice/first-run.txt")
file.exists("outputs/practice/first-run.txt")
# %% inspect
readLines("outputs/practice/first-run.txt")
# %% versions
R.version.string
