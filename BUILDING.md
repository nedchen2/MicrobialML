# Building and checking the textbook

This guide is for textbook maintainers. Students use the [online book](https://nedchen2.github.io/MicrobialML/) and its student ZIP.

## View the book

The complete pilot bundle includes the built website in `_build/html/`. On macOS,
double-click `preview.command`, keep the terminal open, and visit the printed URL.
Alternatively, from this project directory run:

```sh
python3 tools/preview_book.py
```

This serves the book on this computer only. Use `--port 8766` if the default port
is occupied. Press Ctrl+C in that terminal to stop.

Serve the site over HTTP, rather than expecting
modern Jupyter Book pages to work by double-clicking their HTML files:

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory _build/html
```

Open http://127.0.0.1:8765 in a browser. Press Ctrl+C in that terminal to stop.
Python is needed for this simple instructor preview command, not for students
following the R lessons. The same HTML can later be hosted on GitHub Pages.

## Run the student analysis

Open `microbial-ml.Rproj` in RStudio. Start at `scripts/01-first-run.R`, then
work through the other lessons with the book. To run the complete example:

```r
source("scripts/worked-example.R")
```

Or, from a terminal in this project directory:

```sh
Rscript --vanilla scripts/worked-example.R
```

The real-data helper downloads a pinned original-author CSV once, checks its MD5,
and caches it in `data/raw/`. The first download needs internet. The student ZIP
contains the helper, scripts, practice data, dictionary and project file, not a
repackaged complete source dataset.

Expected supplied split: 525 eligible MSC records from 102 farms; 420 training
records from 81 farms and 105 test records from 21 other farms; zero group overlap.
Baseline RMSE is about 0.528923 and MAE about 0.409148 log10 CFU/mL. These are
microbial-quality results on one fixed split, not a food-safety decision.

## Author/build environment

Tested with Jupyter Book 2.1.7, Python 3.12.14, R 4.6.1 and IRkernel 1.3.2 on macOS
arm64. Chapters 1–7 use base R; tree lessons require rpart (locally tested at 4.1.27). IRkernel
and Python packages are needed only to execute/build the author notebooks.

Create an isolated author environment and install build dependencies:

```sh
python3 -m venv .build-venv
source .build-venv/bin/activate
python -m pip install -r requirements-build.txt
```

Install IRkernel in a project-local library using R (or use an existing author
environment with IRkernel installed):

```r
dir.create(".R-library", showWarnings = FALSE)
install.packages(c("IRkernel", "rpart"), lib = ".R-library", repos = "https://cloud.r-project.org")
```

Build steps, from the project root:

```sh
python tools/execute_book.py
python tools/package_student.py
jupyter-book build --html --strict
```

A supported Node.js runtime and npm must be on the author PATH for Jupyter Book 2.
The tested author runtime used Node.js 24.22.1 and npm 12.2.2. These are build
tools, not student prerequisites. The complete author dependency snapshot is
recorded in `validation/author-environment.json`; `requirements-build.txt`
contains the direct Python dependencies.
The executor uses project-local Jupyter configuration, registers the R kernel
under the active Python prefix, starts a separate fresh kernel for every notebook,
and saves executed notebooks. The HTML build renders those real outputs; it does
not need to recompute them a second time.

To check an extracted student ZIP and the built site's local links:

```sh
python tools/verify_pilot.py --cold-download
python tools/verify_html.py
```

The first command runs all ten chapter scripts in separate R sessions,
downloads the pinned source from an empty cache, repeats the baseline, and
independently reconstructs the mean and error metrics in Python. The second
checks the pages listed in myst.yml and their local link/asset targets. Browser navigation,
search, download and visual checks are recorded separately in `validation/`.

Computational sources are canonical `scripts/*.R` files divided by named `# %%`
cell markers. Prose lives in `authoring/*.md` and refers to those names. The
assembler checks that every R cell appears exactly once in its lesson before
writing `.ipynb` files. Update prose and the canonical script, then rerun the
executor; do not independently edit generated computational cells.


## Shared computational source for Chapters 5–7

Edit `scripts/worked-example.R` and the three matching `authoring/05-*.md`, `06-*.md`, `07-*.md` files. The assembler partitions named cells and generates both the chapter scripts and notebooks. Do not hand-edit generated stage scripts. Each stage runs in a fresh session using a saved RDS checkpoint from its predecessor. The integrated script rebuilds all stages from scratch.

Chapters 8–10 similarly share canonical scripts/tree-workflow.R and three authoring pages. scripts/tree_helpers.R provides parsing, training-only median filling, fixed tree controls and numeric branch tracing. scripts/full-analysis.R orchestrates the baseline and tree workflows from an empty cache. The tree stages preserve the original baseline split and scores.

tools/verify_tree.py independently reconstructs all 15 fold/candidate trees' node means and OOF routes, per-fold and final medians, selected depth, final leaf means, prediction routes and metrics. The pilot verifier also changes only held-out values and checks that selection, preprocessing and fitted structure cannot change. Public downloads include aggregate comparisons; row-level predictions and full raw source files stay outside published files.

The extracted-student-project check also verifies the changed-copy exercise, the repaired AI summary, preservation of a completed AI-use log, toy error calculations, actionable missing-checkpoint errors, and agreement with the v0.1 baseline results. The actual CI environment is saved as an Actions artifact.

Chapter 3 includes an intentional object-name failure. Students first run its one failing line; the supplied runtime-error block then captures the real R condition so the complete script and notebook can continue. This guard is operational reference, not a prerequisite concept. The verifier separately runs the unguarded line in a fresh Rscript process and requires a nonzero exit and the missing object name; it also checks the saved error record and repaired mean. Expected failure is not treated as an unhandled notebook error.

For subpath checks use `python tools/verify_html.py --base-url /MicrobialML` after a build with the same BASE_URL. The local link checker derives its page count from the table of contents.

## Student reading layers

The prose distinguishes scientific decisions, small learning blocks, supplied operational blocks and maintenance reference. Cell tags are assigned in tools/assemble_notebooks.py: hide-input collapses implementation while retaining its output; hide-output also collapses the result of an extra calculation. These tags do not skip execution. The verifier checks every cell's tags, executed state and agreement with its R source. Keep the selection, target-limit treatment, train-only rule and metric interpretation visible in prose.

Full data provenance, exact source identifiers and reuse decisions are maintained in [DATA_NOTES.md](DATA_NOTES.md), outside the student reading sequence.

The v0.7 tree route first fits a provisional depth-one tree using training data only in Chapter 8. Its diagram and invented-input predictions teach fitting versus prediction before selection. Chapter 9 demonstrates one actual training-validation round, then repeats the identical fixed protocol across all folds and depths. These extra demonstrations do not change selection, fill references or test evaluation. Package installation is a one-time student instruction; executable cells load rpart directly. The optional live AI exercise is student work, not an automatically executed or fabricated AI conversation.
