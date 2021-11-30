#'Converts the RBT array output by calculate_relative_motion( ) to 2D matrix
#'
#'\code{export_rbt} converts the transformation array output by
#'\code{calculate_relative_motion} into a 2D matrix w/ dimensions nFrames x 16
#'suitable for export to .csv that can be read into Maya.
#'
#' @param rbt a 3D transformation matrix
#' @param filename an optional filepath to write out a csv
#'
#' @return a 2D matrix of dimensions n_frames x 16
#' @author Kara Feilich
#' @export
#' @examples
#' \dontrun{
#'  }
export_rbt <- function(rbt, filename = NULL){
  n_rows <- dim(rbt)[3]
  output <- matrix(NaN, nrow = n_rows, ncol = 16)

  for (i in c(1:n_rows)){
    output[i,1] <- rbt[1,1,i]
    output[i,2] <- rbt[2,1,i]
    output[i,3] <- rbt[3,1,i]
    output[i,4] <- rbt[4,1,i]
    output[i,5] <- rbt[1,2,i]
    output[i,6] <- rbt[2,2,i]
    output[i,7] <- rbt[3,2,i]
    output[i,8] <- rbt[4,2,i]
    output[i,9] <- rbt[1,3,i]
    output[i,10] <- rbt[2,3,i]
    output[i,11] <- rbt[3,3,i]
    output[i,12] <- rbt[4,3,i]
    output[i,13] <- rbt[1,4,i]
    output[i,14] <- rbt[2,4,i]
    output[i,15] <- rbt[3,4,i]
    output[i,16] <- rbt[4,4,i]
  }

  if(!is.null(filename)){
    write.csv(output, filename)
  }
  output
}


#'Converts the points array output by calculate_relative_motion( ) to 2D matrix
#'
#'\code{export_xyz_points} converts the transformation array output by
#'\code{calculate_relative_motion} into a 2D matrix w/ dimensions nFrames x (3 x
#'nLandmarks) suitable for export to .csv that can be read into Maya.
#'
#' @param xyz_points a 3D array
#'
#' @return a 2D matrix of size nFrames x (3 x nLandmarks)
#' @author Kara Feilich
#' @export
#' @examples
#' \dontrun{
#'  }
export_xyz_points <- function(xyz_points){
  n_rows <- dim(xyz_points)[3]
  n_cols <- dim(xyz_points)[1] * 3
  output <- matrix(NaN, nrow = n_rows, ncol = n_cols)

  for (i in c(1:n_rows)){
    output[i,] <- as.vector(t(xyz_points[,,i]))
  }
  output
}
