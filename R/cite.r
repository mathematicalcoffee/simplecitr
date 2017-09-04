# What is used as the search key?
# 1. if anything is selected, that only.
# 2. Otherwise, the word under the cursor, IF it starts with @
#    (if we are at the end of the word search back to the start)
# 3. Otherwise, nothing
#' Load the bibliography
#' @export
get.bib <- function (bibfile=getOption('citr.bibliography_path'), cache=TRUE, reload=FALSE) {
  bib <- getOption('citr.bibliography_cache', NULL)
  if (is.null(bib) || reload || !cache) {
    if (!file.exists(bibfile))
      stop(sprintf("simplecitr: bibfile `%s` does not exist. Set the bibliography path with `options(citr.bibliography_path=)`.", bibfile))
    bib <- sort(RefManageR::ReadBib(bibfile))
  }
  if (cache)
    options(citr.bibliography_cache=bib)
  bib
}

#' Reload the bibliography
#' @export
reload.bib <- function(bibfile=getOption('citr.bibliography_path')) {
  invisible(get.bib(bibfile, reload=T))
}
#' Set the bibfile path
#'
#' Can use `options(...)` but this is laziness because I have tricksy names for
#' some of the options.
#' @export
set.bibfile <- function (bibfile) {
  options(citr.bibliography_path=bibfile)
}
#' @export
#' @describeIn set.bibfile set whether bib files are validated on load and query
set.check.bib <- function (check) {
  options(simplecitr.check.bib = FALSE)
  RefManageR::BibOptions(check.entries=check)
}

is.inword <- function (x, start) !grepl(ifelse(start, '[@\\s]', '\\s'), x, perl=T)
charAt <- function (x, i) substring(x, i, i)

# this version strips the beginning @ before searching
get.ref.under.cursor <- function () {
  con <- rstudioapi::getSourceEditorContext()
  sel <- rstudioapi::primary_selection(con)
  # grab the word under the cursor, *if* it starts with @
  # want to start at the cursor position and expand before and after
  # out until a space.
  # regex can't operate on cursor position, can it. :/
  # if you select multiple lines it'll probably balk and it's not my fault haha.
  # we'll only look at the first line.
  row <- sel$range$start[['row']]
  ln <- con$contents[row]
  start <- sel$range$start[['column']]
  end <- ifelse(sel$range$end[['row']] != row, nchar(ln), sel$range$end[['column']])

  # end of word possibly, search back
  if (grepl('\\s', charAt(ln, start)) || start == nchar(ln)) start <- end <- start - 1

  # note substring(ln, start, start) gets character just *after*
  #  cursor.
  while (start > 1 &&
         is.inword(charAt(ln, start), start=T)) {
    start <- start - 1
  }
  while (end < nchar(ln) &&
         is.inword(charAt(ln, end + 1), start=F)) {
    end <- end + 1
  }
  search <- substring(ln, start, end)
  # message(search)
  if (charAt(search, 1) != '@') {
    search <- ''
  } else {
    search <- sub('^@', '', search)
  }
  if (getOption('simplecitr.verbose', FALSE))
    message("Search string: ", search)
  list(id=con$id,
       range=rstudioapi::document_range(start=rstudioapi::document_position(row, start), end=rstudioapi::document_position(row, end)),
       search=search)
}

# At the moment, ONLY does
# 1) a key match
# 2) if that fails, an author match
search.bibkey <- function(x, bib=NULL) {
  if (is.null(bib)) bib = get.bib()

  if (x == '')
    return(list())

  # first, try a key match...
  x <- sub('^@', '', x)
  res <- bib[key=x]
  # key match! (you should be so lucky)
  if (length(res) > 0) {
    if (getOption('simplecitr.verbose', FALSE))
      message(length(res), "key matche(s) against ", x)
    return(res)
  }

  # o'wise search titles, authors. Probably authors more than titles.
  res <- bib[author=x]
  if (getOption('simplecitr.verbose', FALSE))
    message(length(res), "author matche(s) against ", x)
  res
}

autocomplete.citation <- function () {
  o <- get.ref.under.cursor()
  res <- search.bibkey(o$search)
  if (length(res) == 0) {
    ref <- shiny.ui(get.bib()) # show all options?
  } else if (length(res) == 1) { # replace match with citation.
    ref <- names(res)
  } else {
    ref <- shiny.ui(res)
  }
  if (!is.null(ref) && ref != '')
    rstudioapi::modifyRange(o$range, paste0('@', ref), id=o$id)
}

shiny.ui <- function (bib.results) {
  # name = displayed, value = key
  opts <- as.list(names(bib.results))
  # what do we want?
  # "McLachlan1996 {title}"? or just TextCite(..)?
  names(opts) <- paste(opts, bib.results$title)
  opts <- c(`Press tab and select`='', Cancel='!!CANCEL!!', opts)
  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
        shiny::selectInput(
          "selected_key", label=NULL,
          choices=opts, width="100%",
          selectize=T
        )
    )
  )

  server <- function (input, output, session) {
    # observeEvent input$selected_key -- when something selected close dialog
    shiny::observe({
      if (input$selected_key != '') {
        ret <- input$selected_key
        if (ret == '!!CANCEL!!') ret <- NULL
        shiny::stopApp(ret)
      }
    })
    # observeEvent keypress esc (I didn't use gadgetTitle which has the `done` thingy)
    shiny::observeEvent(input$done, {
      shiny::stopApp(input$selected_key)
    })
  }

  # @TODO how to make it smaller in height and font size
  viewer <- shiny::dialogViewer("Autocomplete citation", width = 700, height = 100)
  shiny::runGadget(ui, server, viewer = viewer)
}
