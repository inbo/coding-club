# Load the packages and install if needed
required_packages <- c(
    "readr",
    "dplyr",
    "tidyr",
    "jsonlite",
    "readxl",
    "googlesheets4",
    "arrow"
)

# Install packages not yet installed
installed_packages <- required_packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  # Install packages not yet installed
  install.packages(required_packages[!installed_packages])
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))


