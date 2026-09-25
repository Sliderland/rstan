\name{data_hash}
\alias{data_hash}
\alias{match_data_hash}
\title{Hash Stan model data}
\description{
Compute a compact hash of preprocessed data used by a Stan model, or compare
candidate data with the hash recorded in a \code{stanfit} object.
}
\usage{
data_hash(data, model)
match_data_hash(object, newdata)
}
\arguments{
  \item{data}{A named list of data supplied to Stan.}
  \item{model}{A \code{stanmodel} or \code{stanfit} object defining the data block.}
  \item{object}{A \code{stanfit} object.}
  \item{newdata}{A named list of candidate data.}
}
\details{
Only variables declared in the model's data block are included; additional
list elements are ignored. Values are preprocessed as by RStan, sorted by
variable name, serialized using serialization version 2, and hashed with
\code{tools::md5sum}. The returned hash fingerprints the prepared R data
representation and is not a cryptographic proof of provenance.

Fits read from CSV files and older fits may not have a data hash. In that
case \code{match_data_hash} returns \code{NA}. Merged fits retain a hash only
when every component fit has the same recorded hash.
}
\value{
\code{data_hash} returns a 32-character hash. \code{match_data_hash} returns
\code{TRUE}, \code{FALSE}, or \code{NA} if the fit has no recorded hash.
}
\seealso{\code{stan}, \code{sampling}, \code{sflist2stanfit}}
