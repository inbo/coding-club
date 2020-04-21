
#` model first order decay (analytical solution)
first_order_decay_model <- function(decay_rate, initial_concentration, time) {
    return(initial_concentration * exp(-decay_rate*time))
}

#` calculate sum of squared error
sum_squared_error <- function(data, model) {
    return(sum((data - model)^2))
}

#` Create comparison plot model versus data
model_evaluation_plot <- function(df) {
    ggplot(data = df) +
        geom_point(aes(x = time, y = conc_data, color = "data")) +
        geom_line(aes(x = time, y = conc_mod, color = "model")) +
        xlab("time (s)") + ylab("concentration (mg/l)") +
        theme(legend.title = element_blank()) +
        theme(legend.position = "top")
}

#' Run model and plot with data
#'
#' The model uses the time information of the input data to provide model
#' outputs at the same moments in time
#'
#' @param decay float [0-1] decay rate
#' @param init float initial concentration
#' @param data_conc df with a `time` column and a `conc_data` column
#'
#' @return
#'
#' @examples
#' conc_data <- read_csv("../data/20180821_decay_measurements.csv")
#' decay_model(0.2, 10, conc_data)
decay_model <- function(decay, init, data_conc) {
    time <- data_conc$time
    modelled_conc <- first_order_decay_model(decay, init, time)

    # calculate the SSE
    sse <- sum_squared_error(data_conc$conc_data, modelled_conc)
    print(paste("The SSE =", as.character(sse)))

    # add additional column of modelled values
    data_conc <- data_conc %>% mutate(conc_mod = modelled_conc)

    # make comparison plot
    print(model_evaluation_plot(data_conc))

    return(sse)
}

# I have the following concentration measured
conc_data <- readr::read_csv("../data/20180821_decay_measurements_1.csv")

# I want to model this....
decay_model(0.35, 10, conc_data)










