library(tidyverse)
library(jsonlite)
library(furrr)
source("cr_dump_parser.R")
source("rcrossref_parser.R")
cr_files <- list.files("data",full.names = TRUE)
plan(multisession)
tt <- furrr::future_map2(cr_files, "data_parsed", .f = cr_parse, .progress = TRUE)
#' after loading the resulting files into bigquery, I realized that 
#' some records are missing (around 1/3), for instance, records from 33108.json.gz
#' also the furr package warns using the progress function when working with 
#' larger datasets.
#' 
#' So. let's apply the parser over files that were not captured, but
#' 
#' use future_apply directly, and without progress
#' catch errors, so that a process will not be terminated. The parser errors parsing
#' 23846.json.gz
#' 
library(tidyverse)
library(jsonlite)
library(future)
library(future.apply)
source("cr_dump_parser.R")
source("rcrossref_parser.R")
parsed_files <- readr::read_csv("results-20200414-193245.csv")
cr_files <- list.files("data", full.names = TRUE)
missing_files <- cr_files[!cr_files %in% parsed_files$file_name]
plan(multisession)
run_my_code <- future.apply::future_lapply(missing_files, 
                                           purrr::safely(function(x) cr_parse(x, out_dir = "data_parsed")))
#' improved parsing script, check for relevant elements before applying the parser,
#' and keep track of files without relevant records
library(tidyverse)
library(jsonlite)
library(future)
library(future.apply)
source("cr_dump_parser.R")
source("rcrossref_parser.R")
parsed_files <- readr::read_csv("results-20200414-193245.csv")
parsed_files_2 <- paste0("data/", list.files("data_parsed/"), ".gz")
parsed_files_3 <- readLines("log_missed.txt")
cr_files <- list.files("data", full.names = TRUE)
missing_files <- cr_files[!cr_files %in% c(parsed_files$file_name, parsed_files_2, parsed_files_3)]
plan(multisession)
run_my_code <- future.apply::future_lapply(missing_files, 
                                           purrr::safely(function(x) cr_parse(x, out_dir = "data_parsed")))
#' re-do with more fields
#' delete files in folder data_parsed 
library(tidyverse)
library(jsonlite)
library(future)
library(future.apply)
source("cr_dump_parser.R")
source("rcrossref_parser.R")
cr_files <- list.files("data", full.names = TRUE)
parsed_files <- paste0("data/", list.files("data_parsed/"), ".gz")
discarded_files <- readLines("log_missed.txt")
missing_files <- cr_files[!cr_files %in% c(discarded_files, parsed_files)]
plan(multisession)
run_my_code <- future.apply::future_lapply(missing_files, 
                                           purrr::safely(function(x) cr_parse(x, out_dir = "data_parsed")))


