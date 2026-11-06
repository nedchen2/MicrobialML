# Download a pinned public author file. Core lessons use base R only.
course_source <- list(
  commit = "aebcac0888599ad34ab2898f5aa2b704c6e7600c",
  url = paste0("https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/",
               "aebcac0888599ad34ab2898f5aa2b704c6e7600c/",
               "Data/Raw%20Milk%20Micro%20Data.csv"),
  md5 = "66057392dd1c31f6be47ec0c75ee2cb4",
  doi = "10.1016/j.jfp.2025.100477"
)

course_survey_source <- list(
  commit = course_source$commit,
  url = paste0("https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/",
               course_source$commit, "/Data/Farm%20Survey%20Data.csv"),
  md5 = "948ed520f7564bda2694111b56ccc8cb"
)

fetch_course_file <- function(source_info, destination) {
  if (!file.exists("microbial-ml.Rproj")) {
    stop("Open microbial-ml.Rproj first. The working folder must be the project root.")
  }
  dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(destination)) {
    previous <- options(timeout = max(120, getOption("timeout")))
    on.exit(options(previous), add = TRUE)
    download.file(source_info$url, destination, mode = "wb", quiet = TRUE)
  }
  checksum <- unname(tools::md5sum(destination))
  if (is.na(checksum) || checksum != source_info$md5) {
    stop(paste("Source checksum mismatch. Keep your work, remove only", destination,
               "and retry; do not change the expected checksum."))
  }
  destination
}

fetch_course_data <- function() {
  fetch_course_file(course_source, "data/raw/Raw_Milk_Micro_Data.csv")
}

fetch_course_survey <- function() {
  fetch_course_file(course_survey_source, "data/raw/Farm_Survey_Data.csv")
}
