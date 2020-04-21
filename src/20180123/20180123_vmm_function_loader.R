
library(iterators)
library(dplyr)
library(readr)

#' Get data entry from waterinfo header data file
#'
#' @param inputline character string coming from Waterinfo data file
#'
#' @return char string with the entry
wi_header_split <- function(inputline) {
    trimws(strsplit(inputline, ";")[[1]][[2]])
}

#' Load Waterinfo.be data
#'
#' Coordinate data file can be specified as well
#'
#' @param filename path/filename of the RWS datafile
#' @param n_max int shortcut for testing, loading just a section of the data
#'
#' @return data.frame with the headers location_name, datetime (UTC), value,
#' unit,variable_name, latitude, longitude and source_filename
#'
#' @export
#' @importFrom readr read_delim cols col_character col_datetime col_integer
#' @importFrom dplyr select mutate %>%
#' @importFrom iterators ireadLines nextElem
#'
load_waterinfo_data <- function(filename, n_max = Inf) {
    waterinfo_con <- file(filename, "r", encoding = "UTF-8")
    header_it <- ireadLines(waterinfo_con)
    line <- nextElem(header_it)
    cnt <- 0
    while (startsWith(line, "#")) {
        # extract station coordinate info
        if (grepl("station_name", line)) station_name <- wi_header_split(line)
        if (grepl("station_no", line)) station_no <- wi_header_split(line)
        if (grepl("ts_unitname", line)) variable_unit <- wi_header_split(line)
        if (grepl("parametertype_name", line)) variable_name <- wi_header_split(line)
        if (grepl("Timestamp", line)) header <- line
        line <- nextElem(header_it)
        cnt <- cnt + 1
    }
    close(waterinfo_con)

    # Define mapping for waterinfo supported values
    variable_mapping <- list("N" = "precipitation",
                             "Pa" = "air_pressure")
    variable_name_mapped <- variable_mapping[[variable_name]]
    if (is.null(variable_name_mapped)) {
        variable_name_mapped <- variable_name
        print(sprintf("Variable name is not mapped, using %s as variable name",
                      variable_name_mapped))
    }

    # Read the data.frame

    # Remark, the data column has a ',' as decimal symbol, but in the time column
    # the . is used. hence, we can not generalize the locale. Instead, we read
    # the data as character and do the coercing to floats separatly
    col_types <- cols(
        `#Timestamp` = col_datetime(format = ""),
        Value = col_character(),
        `Quality Code` = col_integer(),
        `Absolute Value` = col_character(),
        `AV Quality Code` = col_character()
    )

    waterinfo_data <- read_delim(filename, delim = ";", skip = cnt - 1,
                                 n_max = n_max, col_names = TRUE,
                                 col_types = col_types)

    waterinfo_data <- waterinfo_data %>%
        select(datetime = `#Timestamp`, value = Value,
               quality_code = `Quality Code`) %>%
        mutate(value = gsub(",", ".", value)) %>%
        mutate(value = as.numeric(value)) %>%
        mutate(location_name = station_name) %>%
        mutate(variable_name = variable_name_mapped) %>%
        mutate(station_no = station_no) %>%
        mutate(unit = variable_unit) %>%
        mutate(source_filename = basename(filename))

    waterinfo_data %>%
        select(-station_no)
}
