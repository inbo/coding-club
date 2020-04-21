library(readr)
library(ggplot2)

decay <- read_csv("../data/20180821_decay_measurements_1.csv")

ggplot(decay, aes(x = time, y = conc_data)) +
    geom_point() +
    geom_smooth() +
    xlab("seconds") + ylab("concentration (mg/l)")




