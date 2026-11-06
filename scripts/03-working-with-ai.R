# Chapter 3. Verification examples; no API account is required.
# %% verify-mean
counts <- c(10, 20, 30)
mean(counts)
(10 + 20 + 30) / 3
stopifnot(mean(counts) == 20)
# %% correct-object
milk_data <- data.frame(count = c(10, 20, 30))
names(milk_data)
mean(milk_data$count)
# %% error-demo
# This deliberately catches an error so the lesson can display it safely.
# milkData is not milk_data. A fresh chapter session defines only the latter.
tryCatch(mean(milkData$count), error = function(e) conditionMessage(e))
# %% repair
mean(milk_data$count)
stopifnot(identical(names(milk_data), "count"))
cat("The corrected line runs and the independent check passes.\n")
