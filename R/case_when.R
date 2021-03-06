#' Case When with data.table
#'
#' Does what \code{dplyr::case_when()} does, with the same syntax, but with
#' \code{data.table::fifelse()} under the hood
#'
#' @param ... statements of the form: \code{condition ~ label}, where the label is applied if the condition is met
#'
#' @return Vector of the same size as the input vector
#'
#' @import data.table
#'
#' @examples
#'
#' x <- rnorm(100)
#' dt_case_when(
#'   x < median(x) ~ "low",
#'   x >= median(x) ~ "high",
#'   is.na(x) ~ "other"
#'   )
#'
#' library(data.table)
#' temp <- data.table(pseudo_id = c(1, 2, 3, 4, 5),
#'                    x = sample(1:5, 5, replace = TRUE))
#' temp[, y := dt_case_when(pseudo_id == 1 ~ x * 1,
#'                          pseudo_id == 2 ~ x * 2,
#'                          pseudo_id == 3 ~ x * 3,
#'                          pseudo_id == 4 ~ x * 4,
#'                          pseudo_id == 5 ~ x * 5)]
#'
#' @export
dt_case_when <- function(...){
  # grab the dots
  dots <- list(...)
  # checking the dots
  .check_dots(dots)

  # extract info from dots
  n <- length(dots)
  conds <- conditions(dots)
  labels <- assigned_label(dots)
  class <- sapply(labels, typeof)
  if (length(unique(class)) > 1 && (! "symbol" %in% unique(class)))
    stop("The labels are of different types: ",
         paste(unique(class), collapse = ", "), call. = FALSE)
  class <- class[[1]]

  # make the right NA based on assigned labels
  na_type <- na_type_fun(class)

  # create fifelse() call
  if (isTRUE(conds[[n]])){
    calls <- labels[[n]]
  } else {
    calls <- call("fifelse", conds[[n]], labels[[n]], eval(na_type))
  }
  for (i in rev(seq_len(n))[-1]){
    calls <- call("fifelse", conds[[i]], labels[[i]], calls)
  }

  eval(calls, envir = parent.frame())
}


#' fifelse from data.table
#'
#' See \code{data.table::\link[data.table:fifelse]{fifelse()}} for details.
#'
#' @name fifelse
#' @keywords internal
#' @export
#' @importFrom data.table fifelse
NULL

# Helpers -----------------

na_type_fun <- function(class){
  switch(class,
         "logical"   = NA,
         "complex"   = NA_complex_,
         "character" = NA_character_,
         "integer"   = NA_integer_,
         NA_real_)
}
conditions <- function(list){
  unlist(lapply(list, function(x) x[[2]]))
}
assigned_label <- function(list){
  unlist(lapply(list, function(x) x[[3]]))
}
is_formula <- function(x){
  is.call(x) && x[[1]] == quote(`~`)
}

# Check functions -------------------

.check_dots <- function(dots){
  forms <- all(unlist(lapply(dots, is_formula)))
  if (!forms)
    stop("Not all arguments are formulas", call. = FALSE)
}
