# Same as citr (citr.bibliography_path).
# The rest we do not use.
.onLoad <- function(libname, pkgname) { # nocov start
  op <- options()
  op_citr <- list( # default values
    citr.bibliography_path = './references.bib',
    # too hard to sync my own cache with citr so we will just use theirs. (they will update it as necessary...)
    citr.bibliography_cache = NULL,
    # debug  .. ?
    simplecitr.verbose=FALSE,
    simplecitr.check.bib = FALSE # this one's under simplecitr, everything else is under citr...
  )
  toset <- !(names(op_citr) %in% names(op))
  if(any(toset)) options(op_citr[toset])
  RefManageR::BibOptions(check.entries=getOption('simplecitr.check.bib', FALSE))

  invisible()
}
