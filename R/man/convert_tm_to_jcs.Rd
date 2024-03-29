% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transform_functions.R
\name{convert_tm_to_jcs}
\alias{convert_tm_to_jcs}
\title{Convert transformation matrix to JCS format}
\usage{
convert_tm_to_jcs(x)
}
\arguments{
\item{R}{rotation matrix (3x3)}

\item{Order:}{Order of anger angles to return, any of: {"XYZ", "XZY", "YXZ", "YZX", "ZYX", "ZXY"}, case insensitive}
}
\value{


angles (degrees) in specified order
}
\description{
This function converts a 3-D transformation matrix (4 x 4 x n_frames)
into standard JCS format, n_frames x 6, where columns are
\link{tx, ty, tz, rx. ry, rz}
}
\examples{
\dontrun{}
Calculates extrinsic Tait-Bryan angles from rotation matrix

}
