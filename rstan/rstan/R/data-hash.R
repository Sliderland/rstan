# Hashing helpers for the data recorded in stanfit objects.

.hash_stan_data <- function(data) {
  if (!is.list(data))
    stop("data must be a list of preprocessed Stan data", call. = FALSE)
  data <- data[order(names(data))]
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  writeBin(serialize(data, connection = NULL, version = 2), tmp)
  unname(as.character(tools::md5sum(tmp)))
}

.prepare_stan_data_for_hash <- function(data, model) {
  if (is(model, "stanfit")) model <- get_stanmodel(model)
  if (!is(model, "stanmodel"))
    stop("model must be a stanmodel or stanfit object", call. = FALSE)
  if (!is.list(data) || is.data.frame(data))
    stop("data must be a named list", call. = FALSE)
  if (is.null(names(data)))
    stop("data must be a named list", call. = FALSE)

  # Select declared variables without dynamic lookup: parse_data() uses
  # dynGet() for fitting, which does not work from this helper's call frame.
  data_names <- .parse_data_names(get_cppcode(model))
  data <- data[intersect(data_names, names(data))]
  data_preprocess(data)
}

#' Compute the hash of data for a Stan model
#'
#' Hashes the preprocessed values for variables declared in the model's data
#' block. Additional elements in `data` are ignored.
#'
#' @param object A `stanmodel` or `stanfit` object defining the data block.
#' @param newdata A named list of candidate data supplied to Stan.
#' @return A 32-character MD5 hash.
#' @export
data_hash <- function(object, newdata) {
  .hash_stan_data(.prepare_stan_data_for_hash(newdata, object))
}

#' Compare data with the data used to create a stanfit
#'
#' @param object A `stanfit` object.
#' @param newdata A named list of candidate data.
#' @return `TRUE` if the candidate data hash matches, `FALSE` if it differs,
#'   or `NA` if the fit has no recorded data hash.
#' @export
match_data_hash <- function(object, newdata) {
  if (!is(object, "stanfit"))
    stop("object must be a stanfit object", call. = FALSE)
  if (length(object@data_hash) != 1L || is.na(object@data_hash))
    return(NA)
  identical(object@data_hash, data_hash(object, newdata))
}
