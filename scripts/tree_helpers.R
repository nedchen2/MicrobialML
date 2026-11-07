# Supplied support for Chapters 8-10. Expand when needed; decisions are in the book.
tree_features <- c("pasture_hours", "milking_cows")

read_survey_features <- function(path) {
  survey <- read.csv(path, fileEncoding = "UTF-8-BOM", check.names = FALSE,
                     stringsAsFactors = FALSE, na.strings = c("", "NA", "??"))
  names(survey) <- trimws(names(survey))
  dictionary <- read.csv("data/predictor-dictionary.csv", stringsAsFactors = FALSE)
  stopifnot(identical(dictionary$variable, tree_features))
  stopifnot(all(c("FarmID", "Sampling", dictionary$source_column) %in% names(survey)))
  out <- survey[c("FarmID", "Sampling", dictionary$source_column)]
  names(out) <- c("FarmID", "Sampling", tree_features)
  out$FarmID <- trimws(out$FarmID)
  out$Sampling <- trimws(out$Sampling)
  for (variable in tree_features) out[[variable]] <- as.numeric(out[[variable]])
  stopifnot(nrow(out) == 540, length(unique(out$FarmID)) == 101)
  stopifnot(!anyDuplicated(out[c("FarmID", "Sampling")]))
  stopifnot(all(is.na(out$pasture_hours) | (out$pasture_hours >= 0 & out$pasture_hours <= 24)))
  stopifnot(all(is.na(out$milking_cows) | out$milking_cows > 0))
  out
}

attach_survey <- function(target, survey) {
  target_key <- paste(target$FarmID, target$Sampling, sep = "\r")
  survey_key <- paste(survey$FarmID, survey$Sampling, sep = "\r")
  index <- match(target_key, survey_key)
  out <- target
  out$survey_matched <- !is.na(index)
  for (variable in tree_features) out[[variable]] <- survey[[variable]][index]
  out
}

learn_medians <- function(data) {
  values <- vapply(tree_features, function(variable) median(data[[variable]], na.rm = TRUE), numeric(1))
  stopifnot(all(is.finite(values)))
  values
}

fill_predictors <- function(data, medians) {
  out <- data
  for (variable in tree_features) {
    out[[variable]][is.na(out[[variable]])] <- medians[[variable]]
    stopifnot(all(is.finite(out[[variable]])))
  }
  out
}

# Supplied fixed settings. Students change maxdepth explicitly in the lessons.
fixed_tree_settings <- rpart::rpart.control(maxdepth = 1, minsplit = 20, minbucket = 10,
  cp = 0, xval = 0, maxcompete = 0, maxsurrogate = 0, usesurrogate = 0)

tree_control <- function(depth) {
  settings <- fixed_tree_settings
  settings$maxdepth <- depth
  settings
}

extract_tree_nodes <- function(fit) {
  frame <- fit$frame
  out <- data.frame(node = as.integer(row.names(frame)), feature = as.character(frame$var),
                    records = frame$n, mean_log10 = frame$yval,
                    cut = NA_real_, less_goes_left = NA)
  branches <- out$feature != "<leaf>"
  if (any(branches)) {
    # No competitors or surrogates were stored: one split row per branch.
    stopifnot(nrow(fit$splits) == sum(branches))
    out$cut[branches] <- fit$splits[, "index"]
    out$less_goes_left[branches] <- fit$splits[, "ncat"] == -1
  }
  out
}

trace_tree <- function(row, nodes) {
  node <- 1L
  path <- character()
  repeat {
    branch <- nodes[match(node, nodes$node), ]
    stopifnot(nrow(branch) == 1, !is.na(branch$node))
    if (branch$feature == "<leaf>") break
    less <- row[[branch$feature]] < branch$cut
    left <- if (branch$less_goes_left) less else !less
    path <- c(path, paste(branch$feature, if (less) "<" else ">=", format(branch$cut, digits = 10)))
    node <- if (left) 2L * node else 2L * node + 1L
  }
  list(leaf = node, prediction = branch$mean_log10, path = path)
}

draw_teaching_tree <- function(fit, nodes) {
  if (nrow(nodes) == 3 && nodes$feature[1] != "<leaf>") {
    root <- nodes[1, ]
    condition <- paste(if (root$feature == "milking_cows") "Milking cows" else "Pasture hours",
                       if (root$less_goes_left) "<" else ">=", format(root$cut, digits = 6), "?")
    plot.new()
    plot.window(xlim = c(0, 1), ylim = c(0, 1))
    segments(c(0.5, 0.5), c(0.70, 0.70), c(0.25, 0.75), c(0.37, 0.37), col = "#427b70", lwd = 2)
    rect(0.24, 0.70, 0.76, 0.89, col = "#e5f2ed", border = "#427b70", lwd = 2)
    text(0.5, 0.80, paste(condition, paste(root$records, "training records"), sep = "\n"), cex = 1.1)
    text(c(0.32, 0.68), c(0.54, 0.54), c("Yes", "No"), col = "#295d53", cex = 1.1)
    for (j in 1:2) {
      leaf <- nodes[nodes$node == j + 1, ]
      x <- c(0.25, 0.75)[j]
      rect(x - 0.21, 0.14, x + 0.21, 0.37, col = "#f3f7f5", border = "#8faea5", lwd = 2)
      text(x, 0.255, paste(paste("Leaf", leaf$node),
           paste("Predict", format(round(leaf$mean_log10, 4), nsmall = 4)),
           paste(leaf$records, "training records"), sep = "\n"), cex = 1.1)
    }
    text(0.5, 0.035, "Predictions are log10 MSC; counts are records, not independent farms.", cex = 0.85)
  } else if (nrow(nodes) > 1) {
    plot(fit, uniform = TRUE, branch = 0.6, margin = 0.15)
    text(fit, use.n = TRUE, all = FALSE, fancy = TRUE, digits = 4, cex = 0.85)
  } else {
    plot.new()
    text(0.5, 0.5, paste("No split: training mean =", round(nodes$mean_log10, 4)))
  }
  title("A tree made of training means")
}

write_tree_mermaid <- function(nodes, path) {
  lines <- c("flowchart TB", "    accTitle: Fitted Training Mean Tree",
    "    accDescr: Fitted branches route a sample to a leaf that predicts its mean training log10 MSC.")
  for (i in seq_len(nrow(nodes))) {
    node <- nodes[i, ]
    if (node$feature == "<leaf>") {
      label <- paste("Predict", format(node$mean_log10, digits = 8), "log10 MSC; n =", node$records)
      lines <- c(lines, paste0("    node_", node$node, '["', label, '"]'))
    } else {
      label <- paste(node$feature, if (node$less_goes_left) "<" else ">=", format(node$cut, digits = 8), "?")
      lines <- c(lines, paste0("    node_", node$node, '{"', label, '"}'),
                 paste0("    node_", node$node, " -->|Yes| node_", 2 * node$node),
                 paste0("    node_", node$node, " -->|No| node_", 2 * node$node + 1))
    }
  }
  writeLines(lines, path)
}
