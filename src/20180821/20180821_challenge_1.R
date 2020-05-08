library(tidyverse)

files_in_dir <- list.files("../data/20180821", full.names = TRUE)

for (file in files_in_dir) {
    if (stringr::str_detect(file, "decay")) {
        # read the data
        # concentrations <- readr::read_csv(file)
        concentrations <- read.csv(file)
        
        # make and print a plot of the data
        plot_conc <- ggplot(concentrations) +
            # geom_point(aes(pull(concentrations,1), pull(concentrations,2)), size = 2) +
            # xlab("time (s)") + ylab("concentration (mg/l)") +
            # ggtitle(basename(file))
            geom_point(aes(concentrations[,1], concentrations[,2]), size = 2) +
              xlab("time (s)") + ylab("concentration (mg/l)") +
              ggtitle(basename(file))
        print(plot_conc)

    }
}
