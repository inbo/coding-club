library(readr)

decay_1 <- read_csv("./data/20180821_decay_measurements_1.csv")

# Get summary stats about concentration decay
min_decay_1 <- min(decay_1$conc_data, na.rm = TRUE) # min
max_decay_1 <- max(decay_1$conc_data, na.rm = TRUE)
t_min_decay_1 <- decay_1$time[which.min(decay_1$conc_data)] # time to min
# d-50
d_50_decay_1 <- decay_1$time[which.min(abs(max(decay_1$conc_data)/2 - decay_1$conc_data))]

# summarize these info in data frame (output)
info_decay_1 <- data.frame(min_decay = min_decay_1,
                           t_min_decay = t_min_decay_1,
                           max_decay = max_decay_1,
                           d_50_time = d_50_decay_1,
                           stringsAsFactors = FALSE)
