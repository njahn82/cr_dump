#' Load and subset Crossref March Public Data File
#'
#' Available at <https://doi.org/10.13003/83b2gp>
library(jsonlite)
library(tidyverse)
source("rcrossref_parser.R")
cr_parse <- function(in_file, out_file) {
  # progress  
  p$tick()$print()
  # read json
  req <- jsonlite::fromJSON(in_file, simplifyVector = FALSE)
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
    con <- file(out_file, "a+")
    jsonlite::stream_out(out, con)
    close(con)
  } else {
    NULL
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
