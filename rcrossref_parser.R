#' from ropensci/rcrossref v.1.0
#' R/cr_works.R
parse_works <- function(zzz){
  keys <- c('alternative-id','archive','container-title','created',
            'deposited','published-print','published-online','DOI',
            'funder','indexed','ISBN',
            'ISSN','issue','issued','license', 'link','member','page',
            'prefix','publisher','reference-count', 'score','source',
            'subject','subtitle','title', 'type','update-policy','URL',
            'volume','abstract','is-referenced-by-count','language')
  manip <- function(which="issued", y) {
    res <- switch(
      which,
      `alternative-id` = list(paste0(unlist(y[[which]]),
                                     collapse = ",")),
      `archive` = list(y[[which]]),
      `container-title` = list(paste0(unlist(y[[which]]),
                                      collapse = ",")),
      created = list(make_date(y[[which]]$`date-parts`)),
      deposited = list(make_date(y[[which]]$`date-parts`)),
      `published-print` = list(make_date(y[[which]]$`date-parts`)),
      `published-online` = list(make_date(y[[which]]$`date-parts`)),
      DOI = list(y[[which]]),
      indexed = list(make_date(y[[which]]$`date-parts`)),
      ISBN = list(paste0(unlist(y[[which]]), collapse = ",")),
      ISSN = list(paste0(unlist(y[[which]]), collapse = ",")),
      issue = list(y[[which]]),
      issued = list(
        paste0(
          sprintf("%02d",
                  unlist(y[[which]]$`date-parts`)), collapse = "-")
      ),
      member = list(y[[which]]),
      page = list(y[[which]]),
      prefix = list(y[[which]]),
      publisher = list(y[[which]]),
      `reference-count` = list(y[[which]]),
      score = list(y[[which]]),
      source = list(y[[which]]),
      subject = list(paste0(unlist(y[[which]]), collapse = ",")),
      subtitle = list(y[[which]]),
      title = list(paste0(unlist(y[[which]]), collapse = ",")),
      type = list(y[[which]]),
      `update-policy` = list(y[[which]]),
      URL = list(y[[which]]),
      volume = list(y[[which]]),
      abstract = list(y[[which]]),
      `is-referenced-by-count` = list(y[[which]]),
      language = list(y[[which]])
    )

    res <- if (is.null(res) || length(res) == 0) NA else res
    if (length(res[[1]]) > 1) {
      names(res[[1]]) <- paste(which, names(res[[1]]), sep = "_")
      as.list(unlist(res))
    } else {
      names(res) <- which
      res
    }
  }

  if (is.null(zzz)) {
    NULL
  } else if (all(is.na(zzz))) {
    NULL
  } else {
    tmp <- unlist(lapply(keys, manip, y = zzz))
    out_tmp <- data.frame(
      as.list(Filter(function(x) nchar(x) > 0, tmp)),
      stringsAsFactors = FALSE)
    out_tmp$assertion <- list(parse_todf(zzz$assertion)) %||% NULL
    out_tmp$author <- list(parse_todf(zzz$author)) %||% NULL
    out_tmp$funder <- list(parse_todf(zzz$funder)) %||% NULL
    out_tmp$link <- list(parse_todf(zzz$link)) %||% NULL
    out_tmp$license <- list(tbl_df(bind_rows(lapply(zzz$license, parse_license)))) %||% NULL
    out_tmp$`clinical-trial-number` <- list(parse_todf(zzz$`clinical-trial-number`)) %||% NULL
    out_tmp$reference <- list(parse_todf(zzz$reference)) %||% NULL
    out_tmp <- Filter(function(x) length(unlist(x)) > 0, out_tmp)
    names(out_tmp) <- tolower(names(out_tmp))
    return(out_tmp)
  }
}

parse_awards <- function(x) {
  as.list(stats::setNames(
    vapply(x, function(z) paste0(unlist(z$award), collapse = ","), ""),
    vapply(x, "[[", "", "name")
  ))
}

parse_license <- function(x){
  if (is.null(x)) {
    NULL
  } else {
    date <- make_date(x$start$`date-parts`)
    data.frame(date = date, x[!names(x) == "start"],
               stringsAsFactors = FALSE)
  }
}

parse_ctn <- function(x){
  if (is.null(x)) {
    NULL
  } else {
    stats::setNames(x[[1]], c('number', 'registry'))
  }
}

parse_todf <- function(x){
  if (is.null(x)) {
    NULL
  } else {
    tbl_df(bind_rows(lapply(x, function(w) {
      if ("list" %in% vapply(w, class, "")) {
        w <- unlist(w, recursive = FALSE)
        if ("list" %in% vapply(w, class, "")) {
          w <- unlist(w, recursive = FALSE)
        }
      }
      if (length(w) == 0) return(NULL)
      w[sapply(w, function(b) length(b) == 0)] <- NULL
      data.frame(w, stringsAsFactors = FALSE)
    })))
  }
}

make_date <- function(x) paste0(sprintf("%02d", unlist(x)), collapse = "-")
