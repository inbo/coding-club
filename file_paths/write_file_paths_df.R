library(dplyr)
library(fs)
library(tidyr)
library(rprojroot)
library(readr)

x <- dir_ls(regexp = "(src/)|(data/)", recurse = TRUE, type = "file")
file_path_df <- tibble(
  path = x,
  filename = path_file(x),
  dirname = path_dir(x)
) %>%
  separate(dirname, into = c("basedir", "date"), sep = "/")

readr::write_csv(x = file_path_df,
                 file = find_root_file("file_paths/file_path_df.csv",
                                       criterion = is_git_root))
