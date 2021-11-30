#' Takes the RBT file from XMALab and converts it into a 4-D array
#'
#'\code{import_rbt} takes the RBT file output by XMALab, and converts it into an
#'    array of dimensions \[4 x 4 x n_frames x n_rigid_bodies]. The 4x4
#'    component is the transformation matrix. If the RBT file contains only one
#'    RBT (as when "Single Files" is checked during XMALab export,
#'    \code{dim(rbt_array)[4] == 1}.
#'
#' @param filename a character string specifying the filepath
#'
#' @return a 4-D array where the first two dimensions are the rows and
#'         columns of a 4x4 transformation matrix, D3 is frames, and D4
#'         is rigid bodies.
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @export
#' @examples
#' \dontrun{
#' rbt_array <- import_rbt("Trial01_RBT.csv")
#' }

import_rbt <- function(filename){
  # Check input format
  if (class(filename) == "character"){
    x <- utils::read.csv(filename, header = TRUE)
  } else {
    x <- filename
  }

  # Check number of rigid bodies
  n_rigid_bodies <- ncol(x) / 16

  # Pre-allocate a 4D array
  x_array <- array(data = NA, c(4, 4, nrow(x), n_rigid_bodies))
  for (rb in 1:(n_rigid_bodies)){  # for every rigid body
    a <- (rb - 1) * 16 + 1
    # Format: rbt[bone, row, column, frame]
    for (fr in 1:nrow(x)){
      x_array[1, 1, fr, rb] <- as.numeric(x[fr, a])
      x_array[2, 1, fr, rb] <- as.numeric(x[fr, (a + 1)])
      x_array[3, 1, fr, rb] <- as.numeric(x[fr, (a + 2)])
      x_array[4, 1, fr, rb] <- as.numeric(x[fr, (a + 3)])
      x_array[1, 2, fr, rb] <- as.numeric(x[fr, (a + 4)])
      x_array[2, 2, fr, rb] <- as.numeric(x[fr, (a + 5)])
      x_array[3, 2, fr, rb] <- as.numeric(x[fr, (a + 6)])
      x_array[4, 2, fr, rb] <- as.numeric(x[fr, (a + 7)])
      x_array[1, 3, fr, rb] <- as.numeric(x[fr, (a + 8)])
      x_array[2, 3, fr, rb] <- as.numeric(x[fr, (a + 9)])
      x_array[3, 3, fr, rb] <- as.numeric(x[fr, (a + 10)])
      x_array[4, 3, fr, rb] <- as.numeric(x[fr, (a + 11)])
      x_array[1, 4, fr, rb] <- as.numeric(x[fr, (a + 12)])
      x_array[2, 4, fr, rb] <- as.numeric(x[fr, (a + 13)])
      x_array[3, 4, fr, rb] <- as.numeric(x[fr, (a + 14)])
      x_array[4, 4, fr, rb] <- as.numeric(x[fr, (a + 15)])
    }
  }
  return(x_array)
}



#' Import xyz (3D) points
#'
#'\code{import_xyz_points} takes the 3D points file output from XMALab and
#' converts it into a 3-D array of dimensions \[n_points x 3 x n_frames], where
#'  columns are \[x, y, z] positions.
#'
#' @param filename a character string specifying the 3D points filepath from XMALab
#'
#' @return a 3-dimensional array where D1 is points (as in framespec file), D2
#'  is \[X,Y,Z] positions, and D3 is frames
#' @export
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @examples
#' \dontrun{
#' xyz_array <- import_xyz_points("Trial01_3DPoints.csv")}
import_xyz_points <- function(filename){

  # Helper function that extracts all xyz coordinates at all times
  # for a given landmark
  get_all_frames_marker_xyz <- function(pt, xyz_df){
    column_number_x <- (pt - 1) * 3 + 1
        xyz <- array(data=xyz_df[ ,column_number_x:(column_number_x + 2)])
    xyz
  }

  # Import the raw data file
  if (class(filename) == "character"){
    x <- utils::read.csv(filename, header = TRUE)
  } else {
    x <- filename
  }

  # Because each marker has 3 columns. Two unused columns at the end mean we
  # need to round down
  n_points <- floor(ncol(x) / 3)

  # Make a list of each landmark's point matrices
  x_list <- list()
  for (pt in 1:(n_points)){
    x_list[[pt]] <- t(as.matrix(
      get_all_frames_marker_xyz(pt, x)))
  }

  # Bind the list into a 3 dimensional array of dim[nlandmarks, 3, nframes]
  abind::abind(x_list, along = 0)
}


#' Converts the ACS transformation matrix file from XMALab into a 4 x 4 matrix
#'
#'\code{import_acs_rel_bone} takes the ACS transformation matrix output by
#'    XMALab, and converts it into a matrix of dimensions \[4 x 4].
#'
#' @param filename a character string specifying the RBT filepath from Maya
#' following tutorial instructions)
#'
#' @return a 2-D (4x4) transformation matrix that describes the position of the
#' ACS relative to a bone model
#'
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @export
#' @examples
#' \dontrun{
#' import_acs_rel_bone <- import_acs_rel_bone("Craniums_acs_tm.csv")
#' }

import_acs_rel_bone <- function(filename){
  if (class(filename) == "character"){
    x <- utils::read.csv(filename, header = TRUE)
  } else {
    x <- filename
  }

  # If there are multiple frames (rows), use first frame with data
  frame_to_use <- min(which(!is.nan(x[,1])))

  x_matrix <- matrix(data = NA, nrow = 4, ncol = 4)
    x_matrix[1, 1] <- as.numeric(x[frame_to_use, 1])
    x_matrix[2, 1] <- as.numeric(x[frame_to_use, 2])
    x_matrix[3, 1] <- as.numeric(x[frame_to_use, 3])
    x_matrix[4, 1] <- as.numeric(x[frame_to_use, 4])
    x_matrix[1, 2] <- as.numeric(x[frame_to_use, 5])
    x_matrix[2, 2] <- as.numeric(x[frame_to_use, 6])
    x_matrix[3, 2] <- as.numeric(x[frame_to_use, 7])
    x_matrix[4, 2] <- as.numeric(x[frame_to_use, 8])
    x_matrix[1, 3] <- as.numeric(x[frame_to_use, 9])
    x_matrix[2, 3] <- as.numeric(x[frame_to_use, 10])
    x_matrix[3, 3] <- as.numeric(x[frame_to_use, 11])
    x_matrix[4, 3] <- as.numeric(x[frame_to_use, 12])
    x_matrix[1, 4] <- as.numeric(x[frame_to_use, 13])
    x_matrix[2, 4] <- as.numeric(x[frame_to_use, 14])
    x_matrix[3, 4] <- as.numeric(x[frame_to_use, 15])
    x_matrix[4, 4] <- as.numeric(x[frame_to_use, 16])
  return(x_matrix)
}

