# Generated from worked-example.R for Chapter 06; edit that canonical source as author.
# Students: save a working copy as my-06-split-farms.R; follow the matching page.
# %% load-prepared
if (!file.exists("outputs/checkpoints/msc-prepared.rds")) stop("Run Chapter 5 first to create msc-prepared.rds.")
prepared <- readRDS("outputs/checkpoints/msc-prepared.rds")
usable <- prepared$data
stopifnot(nrow(usable) == 525)
# %% split-by-farm
# kind sets how R generates random numbers. sample.kind sets how sample() draws.
# normal.kind applies to draws from a normal distribution.
RNGkind(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
set.seed(2026)  # Set the starting point so sample() can repeat the draw.
farm_ids <- sort(unique(usable$FarmID), method = "radix")  # Sort one ID per farm.
test_farms <- sample(farm_ids, size = ceiling(0.20 * length(farm_ids)))
# %in% checks if a farm is on the test list. ! reverses that check for training.
train <- usable[!usable$FarmID %in% test_farms, ]
test <- usable[usable$FarmID %in% test_farms, ]
c(train_rows = nrow(train), test_rows = nrow(test),
  train_farms = length(unique(train$FarmID)),
  test_farms = length(unique(test$FarmID)))
# %% check-farm-overlap
overlap <- intersect(unique(train$FarmID), unique(test$FarmID))
overlap
stopifnot(length(overlap) == 0)
stopifnot(nrow(train) + nrow(test) == nrow(usable))
# %% save-split
split_audit <- rbind(prepared$audit,
  data.frame(check = "train/test farm overlap", value = length(overlap)))
saveRDS(list(train = train, test = test, farm_ids = farm_ids,
             test_farms = test_farms, audit = split_audit), "outputs/checkpoints/farm-split.rds")
file.exists("outputs/checkpoints/farm-split.rds")
