# Download a pinned public author file. Core lessons use base R only.
course_source <- list(
  commit = "aebcac0888599ad34ab2898f5aa2b704c6e7600c",
  url = paste0("https://raw.githubusercontent.com/FSL-MQIP/OREI_ML_Inference/",
               "aebcac0888599ad34ab2898f5aa2b704c6e7600c/",
               "Data/Raw%20Milk%20Micro%20Data.csv"),
  md5 = "66057392dd1c31f6be47ec0c75ee2cb4",
  doi = "10.1016/j.jfp.2025.100477"
)

fetch_course_data <- function() {
  if (!file.exists("microbial-ml.Rproj")) {
    stop("Open microbial-ml.Rproj first. The working folder must be the project root.")
  }
  dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
  destination <- "data/raw/Raw_Milk_Micro_Data.csv"
  if (!file.exists(destination)) {
    previous <- options(timeout = max(120, getOption("timeout")))
    on.exit(options(previous), add = TRUE)
    download.file(course_source$url, destination, mode = "wb", quiet = TRUE)
  }
  checksum <- unname(tools::md5sum(destination))
  if (is.na(checksum) || checksum != course_source$md5) {
    stop("Source checksum mismatch. Keep your work, remove only data/raw/Raw_Milk_Micro_Data.csv and retry; do not change the expected checksum.")
  }
  destination
}
