# Generated from worked-example.R for Chapter 05; edit that canonical source as author.
# Students: save a working copy as my-05-meet-real-data.R; follow the matching page.
# %% source
source("scripts/course_setup.R")
source_file <- fetch_course_data()
milk <- read.csv(source_file, stringsAsFactors = FALSE, na.strings = c("", "NA"))
dim(milk)
names(milk)
stopifnot(identical(names(milk), c("FarmID", "Sampling", "Test", "Conc", "Notes")))
stopifnot(nrow(milk) == 2736)
# %% raw-preview
head(milk, 3)
# %% assays
table(milk$Test)
# %% select
msc <- milk[milk$Test == "MSC", ]
nrow(msc)
table(msc$Notes, useNA = "ifany")
# %% quality
blank_note <- is.na(msc$Notes) | trimws(msc$Notes) == ""
positive_count <- is.finite(msc$Conc) & msc$Conc > 0
usable <- msc[blank_note & positive_count, ]
rownames(usable) <- NULL
nrow(usable)
length(unique(usable$FarmID))
stopifnot(nrow(usable) == 525)
stopifnot(length(unique(usable$FarmID)) == 102)
stopifnot(anyDuplicated(usable[c("FarmID", "Sampling")]) == 0)
# %% usable-preview
head(usable[c("FarmID", "Sampling", "Conc")], 3)
# %% target
usable$left_censored <- usable$Conc == 0.125
usable$log10_msc <- log10(usable$Conc)
table(usable$left_censored)
stopifnot(sum(usable$left_censored) == 30)
stopifnot(all(is.finite(usable$log10_msc)))
# %% log-intuition
log10(c(1, 10, 100))
10^mean(log10(c(10, 100)))
mean(c(10, 100))
# %% prepare-audit
audit <- data.frame(check = c("source rows", "raw MSC rows", "excluded lab-error rows",
  "excluded TNTC rows", "excluded other-note rows", "eligible MSC rows",
  "farms", "left-censored encoded rows", "missing eligible counts",
  "duplicate eligible farm-round keys"),
  value = c(nrow(milk), nrow(msc), sum(msc$Notes == "lab error", na.rm = TRUE),
  sum(msc$Notes == "TNTC", na.rm = TRUE), sum(msc$Notes == "other 8-E was 160", na.rm = TRUE),
  nrow(usable), length(unique(usable$FarmID)), sum(usable$left_censored), sum(is.na(usable$Conc)),
  anyDuplicated(usable[c("FarmID", "Sampling")])))
# %% save-prepared
dir.create("outputs/checkpoints", recursive = TRUE, showWarnings = FALSE)
saveRDS(list(data = usable, audit = audit), "outputs/checkpoints/msc-prepared.rds")
file.exists("outputs/checkpoints/msc-prepared.rds")
