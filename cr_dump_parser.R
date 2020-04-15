#' Load and subset Crossref March Public Data File
#'
#' Available at <https://doi.org/10.13003/83b2gp>
library(jsonlite)
library(tidyverse)
source("rcrossref_parser.R")
cr_parse <- function(in_file, out_dir) {
  # read json
  req <- jsonlite::fromJSON(in_file, simplifyVector = FALSE)
  # test
  types_issues <- cr_test(req)
  if(any(types_issues$years > 2007, na.rm = TRUE) && any(types_issues$types == "journal-article", na.rm = TRUE)) {
  # data transformation
  out <- map_df(req$items, parse_works) %>%
    # only journal articles
    filter(type == "journal-article") %>%
    # only relevant fields
    select(one_of(cr_md_fields)) %>%
    mutate(issued = lubridate::parse_date_time(issued, c('y', 'ymd', 'ym'))) %>%
    mutate(issued_year = lubridate::year(issued)) %>%
    filter(issued_year > 2007) %>%
    mutate(file_name = in_file)
  if(!nrow(out) == 0) {
    out_file <- gsub("", out_dir, in_file)
    jsonlite::stream_out(out, file(gsub(".gz", "", out_file)))
  } else {
    write(in_file, "log_missed.txt", append = TRUE)
    }
  } else {
    write(in_file, "log_missed.txt", append = TRUE)
  }
}

cr_md_fields <- c("doi", # doi
                  "title", # title,
                  "issued", # earliest pub date
                  "container.title", # journal title
                  "publisher", # publisher
                  "member", # crossref member,helpful 4 disambiguating publishers
                  "issn", # issn
                  "license", # license metadata
                  "link", # tdm links
                  "indexed" # most recent indexing
)

cr_test <- function(req) {
  years <- lubridate::year(lubridate::ymd(sapply(sapply(req[["items"]], "[[", "issued"), make_date))) 
  types <- sapply(req[["items"]], "[[", "type")
  list(years = years, types = types)
}
