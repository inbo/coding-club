
library(wateRinfo)
stations <- get_stations("air_pressure") %>%
    filter(stringr::str_detect(station_no, "03"))

air_pressure <- stations %>%
    group_by(ts_id) %>%
    do(get_timeseries_tsid(.$ts_id, period = "P1D",
                           to = lubridate::today())) %>%
    ungroup() %>%
    left_join(stations, by = "ts_id")
air_pressure %>%
    ggplot(aes(x = Timestamp, y = Value)) +
    geom_point() + xlab(format(lubridate::today() - 1, format="%B %d, %Y")) +
    facet_wrap(c("station_name", "stationparameter_name")) +
    scale_x_datetime(date_labels = "%H:%M",
                     date_breaks = "6 hours")
