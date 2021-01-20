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
  if (any(types_issues$years > 2007, na.rm = TRUE) &&
      any(types_issues$types == "journal-article", na.rm = TRUE)) {
    # data transformation
    out <- map_df(req$items, parse_works) %>%
      # only journal articles
      filter(type == "journal-article") %>%
      # null strings to na
      mutate_at(vars(one_of(c("license", "author", "link"))),
                function(x) na_if(x, "NULL")) %>%
      # only relevant fields
      select(one_of(cr_md_fields)) %>%
      # date parsing
      mutate_at(vars(one_of(
        c("created", "issued", "published.print", "published.online")
      )), .funs = list(
        parsed = function (x) lubridate::parse_date_time(x, c("y", "ymd", "ym")))) %>%
      mutate(issued_year = lubridate::year(issued_parsed)) %>%
      filter(issued_year > 2007) %>%
      # remove "." from colnames and nested colnames
      rename_at(vars(contains(".")), function(x) gsub("\\.", "_", x)) %>%
      mutate_at(vars(one_of(c("license", "link"))), function(x) map(x, rename_nested_columns)) %>%
      mutate(file_name = in_file)
    if (!nrow(out) == 0) {
      out_file <- gsub("data", out_dir, in_file)
      jsonlite::stream_out(out, file(gsub(".gz", "", out_file)))
      message(paste0("Successfully parsed: ", in_file))
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
                  "created", # date the doi was created
                  "page", # page numbers
                  "published.print", # print publication date as reported by the publisher
                  "published.online", # online publication date as reported by the publisher
                  "container.title", # journal title
                  "publisher", # publisher
                  "member", # crossref member,helpful 4 disambiguating publishers
                  "issn", # issn
                  "license", # license metadata
                  "link", # tdm links
                  "indexed", # most recent indexing
                  "reference.count", # number of references to crossref articles
                  "is.referenced.by.count", # number of crossref articles linking to this article
                  "language" #language the article is written in
)

cr_test <- function(req) {
  years <- lubridate::year(lubridate::parse_date_time(sapply(sapply(
    req[["items"]], "[[", "issued"
  ), make_date), c("y", "ymd", "ym")))
  types <- sapply(req[["items"]], "[[", "type")
  list(years = years, types = types)
}

rename_nested_columns <- function(x) {
  if(!is.na(x)){
    x <- as.data.frame(x) %>% rename_at(vars(contains(".")),
                                        function(y) gsub("\\.", "_", y))
  }
  return(x)
}
