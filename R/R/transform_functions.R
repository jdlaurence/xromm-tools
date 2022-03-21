#' Calculate relative motion of two bodies
#'
#'This function, similar to oRel in Maya, calculates the relative morion of
#'either 'mobile' 3D point/s or rigid body relative to 'proximal'/reference
#'rigid body. The function is written to handle multiple frames/timepoints of
#'data (see arguments for format), and will automatically detect which frames have
#'data and pad the output with NaNs accordingly.
#'
#'The math underlying the calculation ultimately boils down to multiplying
#' the inverse of the reference transformation matrix by the mobile element's
#' position (XYZ or transformation matrix).
#'
#' @param reference_element_xform an array of reference/proximal rigid body
#' transformation (transformation matrix)
#' @param mobile_element_xform an array of either 3D point/s position or mobile
#' element's rigid body transformation (transformation matrix). In the case of
#' 3D points, format is D1 = points, D2 = \[x, y, z] positions, and D3 is frames;
#' in the case of a transformation matrix, D1 and D2 are 4x4 TMs, and D3 is frames.
#'
#' @return array of relative motion of same dimensions as mobile_element_xform
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @export
#'
#' @examples
#' \dontrun{
#'
#' }
calculate_relative_motion <- function(reference_element_xform,
                                      mobile_element_xform) {
  check_data_format <- function(X){
    # Are they 3D points or a xform matrix?
    if(dim(X)[1] == 4 & dim(X)[2] == 4){  # if it's a 4x4 matrix
      isTM <- TRUE
    } else if(dim(X)[2] == 3){  # if it has 3 columns, i.e. XYZ point/s
      isTM <- FALSE
    } else{
      stop("Hmmm. Check your input formats...")
    }

    # Is it dynamic or static (multiple frames vs one frame)
    if(is.na(dim(X)[3])){
      isStatic <- TRUE
    } else if (dim(X)[3] > 1){
      isStatic <- FALSE
    } else {
      isStatic <- TRUE
    }

    # A quick error check
    if (length(dim(X)) > 3){
      stop("Hmmm. Your input data matrix should only have 2 or 3 dimensions")
    }
    list("isTM" = isTM, "isStatic" = isStatic)
  }

  detect_frames_with_data <- function(X, isTM){
    new_isnan <- function(x) any(!is.nan(x))
    if (isTM) {
      frameIdx <- apply(X, MARGIN = c(3), FUN = new_isnan)
    } else {
      frameIdx <- apply(X, MARGIN = c(3,1), FUN = new_isnan)
    }
    frameIdx
  }

  # Are they 3D points and are there multiple time points?
  ref_conditions <- check_data_format(reference_element_xform)
  mob_conditions <- check_data_format(mobile_element_xform)

  if (!ref_conditions$isTM){
    stop("Uh oh. Reference input needs to be a 4x4 transformation matrix")
  }

  # If both are dynamic, make sure they have the same number of frames
  if(!ref_conditions$isStatic & !mob_conditions$isStatic){
    if(dim(reference_element_xform)[3] != dim(mobile_element_xform)[3]){
      stop("Uh oh... inputs have unequal number of frames")
    }
  }

  # How many frames?
  if(is.na(dim(reference_element_xform)[3])){
    n_frames_ref <- 1
  } else {
    n_frames_ref <- dim(reference_element_xform)[3]
  }

  if(is.na(dim(mobile_element_xform)[3])){
    n_frames_mob <- 1
  } else {
    n_frames_mob <- dim(mobile_element_xform)[3]
  }
  n_frames <-  max(n_frames_ref, n_frames_mob)

  # Replicate static matric across n_frames, if one input is dynamic
  if (xor(ref_conditions$isStatic, mob_conditions$isStatic)){
    if(ref_conditions$isStatic){
      reference_element_xform <- array(rep(reference_element_xform,
                                           times = n_frames),
                                       dim = c(dim(reference_element_xform)[1:2],n_frames))
    } else {
      mobile_element_xform <- array(rep(mobile_element_xform, times = n_frames),
                                    dim = c(dim(reference_element_xform)[1:2]
                                            , n_frames))
    }
  }

  # Which frames have data?
  frameIdxref <- detect_frames_with_data(reference_element_xform,
                                         ref_conditions$isTM)
  frameIdxmob <- detect_frames_with_data(mobile_element_xform,
                                         mob_conditions$isTM)
  if (is.null(dim(frameIdxmob))) {
    frameIdxmob <- matrix(frameIdxmob, nrow = length(frameIdxmob), ncol = 1)
  }

  frameIdx <- frameIdxref & (rowSums(frameIdxmob)>0)

  if(mob_conditions$isTM){
    n_rows <- 4
    n_cols <- 4
  } else {
    n_rows <- dim(mobile_element_xform)[1]
    n_points <- n_rows
    n_cols <- 3
  }

  # Preallocate output
  rel_motion <- array(data = NaN, dim = c(n_rows, n_cols, n_frames))

  # MAIN LOOP
  for (fr in c(1:n_frames)){  # for every frame
    if (frameIdx[fr]){  # if there's data for this frame
      ref_matrix <- reference_element_xform[,,fr]
      inv_ref_matrix <- solve(ref_matrix)  # invert reference TM

      if (mob_conditions$isTM){  # if mobile element is a transformation matrix

        # mobile element matrix for this frame
        mob_matrix <- mobile_element_xform[,,fr]
        tmp_out <- inv_ref_matrix %*% mob_matrix  # CORE OPERATION
        rel_motion[,,fr] <- tmp_out
      } else {  # 3D points
        for (pt in c(1:n_points)){
          if(frameIdxmob[fr, pt]){  # if there's data for that point
            mob_matrix = t(t(c(mobile_element_xform[pt,,fr],1)))  # transpose and add 1 for math
            tmp_out <- inv_ref_matrix %*% mob_matrix  # CORE OPERATION
            tmp_out <- t(tmp_out)[1:3]  # Get rid of the 1
            rel_motion[pt,,fr] <- tmp_out
          }
        }
      }
    }
  }
  rel_motion
}


#' Apply ACS tranformation matrix to rigid body transformation
#'
#' The rigid body transformations that are output from XMALab describe a
#' transformation from CT space to Cube space. \code{apply_acs_tm} applies the
#' ACS transformation matrix to the RBTs, such tht the new_tm describes the
#' transformation of a bone from anatomical (ACS) space to Cube space, and thus
#' can be used to calculate the relative motion of points and other bones. In
#' short, this function multiplies the RBT by the ACS TM for every frame.
#'
#' @param rbt 2- or 3-D matrix where D1, D2 are 4x4 transformation matrixes and
#' D3 is frames
#' @param acs_tm 4x4 transformation matrix of ACS relative to bone model
#' @return new transformation matrix, same dimensions as input RBT
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @export
#' @examples
#' \dontrun{
#' new_rbt <- apply_acs_tm(rbts[,,,1], acs_tms[,,1])
#' }
apply_acs_tm <- function(rbt, acs_tm){
  # First take stock of data
  # Check ACS format
  if ((length(dim(acs_tm)) != 2) || (dim(acs_tm)[1] != 4) || (dim(acs_tm)[2] != 4)){
    stop("Something's wrong with ACS transformation matrix")
  }

  # Check RBT format
  if ((dim(rbt)[1] != 4) || (dim(rbt)[2] != 4)){
    stop("Something's wrong with RBT transformation matrix")
  }

  n_rows <- 4
  n_cols <- 4

  if(is.null(dim(rbt)[3])){
    n_frames <- 1
  } else {
    n_frames <- dim(rbt)[3]
  }

  # Which frames have data?
  detect_frames_with_data <- function(X, isTM){
    new_isnan <- function(x) any(!is.nan(x))
    if (isTM) {
      frameIdx <- apply(X, MARGIN = c(3), FUN = new_isnan)
    } else {
      frameIdx <- apply(X, MARGIN = c(3,1), FUN = new_isnan)
    }
    frameIdx
  }
  frameIdx <- detect_frames_with_data(rbt, isTM = TRUE)

  new_tm <- array(NaN, dim = c(n_rows, n_cols, n_frames))  # pre-allocate output array

  for (t in c(1:n_frames)){  # for every frame
    if (frameIdx[t]){  # if there's data for this frame
      # rbt for this frame
      tmp_rbt <- rbt[,,t]
      tmp_out <- tmp_rbt %*% acs_tm  # MAIN EQUATION
      new_tm[,,t] <- tmp_out
    }
  }
  new_tm
}



#' Convert transformation matrix to JCS format
#'
#' This function converts a 3-D transformation matrix (4 x 4 x n_frames)
#' into standard JCS format, n_frames x 6, where columns are
#' \[tx, ty, tz, rx. ry, rz]. The translations are easy: just the 4th column of
#' each transformation matrix. PLEASE BE AWARE: Grood and Suntay (1983) formally
#' define JCS translations as being along the 3 axes of a JCS (two fixed axes
#' and one floating (calculated) axis). The output of this function
#' as well as that of oRel/MayaTools is translation along the axes of the
#' proximal ACS/element, not a combination of proximal/distal ACSs.
#' The rotations, which are often referred to as "Euler angles" are actually
#' Tait-Bryan angles, if we want to be most accurate. The decomposition of a 3x3
#'  rotation matrix to Tait-Bryan angles involves a
#' bunch of trig functions, which you can view in all of their glory in the
#' helper function \code{rot2taitbryan} within this function. As in XROMM
#' analysis, we use a ZYX rotation order (change within this function, at your
#'  peril).
#' @param tm 3-D transformation array (4 x 4 x n_frames)
#' @return JCS motions data where D1 is frames and D2 is
#' \[tx, ty, tz, rx, ry, rz]
#' @author Kara L. Feilich, J.D. Laurence-Chasen
#' @export
#' @examples
#' \dontrun{}
convert_tm_to_jcs <- function(tm){
  #' Calculates extrinsic Tait-Bryan angles from rotation matrix
  #'
  #' @param R rotation matrix (3x3)
  #' @param Order: Order of anger angles to return, any of: {"XYZ", "XZY", "YXZ", "YZX", "ZYX", "ZXY"}, case insensitive
  #' @return angles (degrees) in specified order
  rot2taitbryan <- function(R, Order){
    ang <- rep(NA, 3)
    switch(toupper(Order),
           "XYZ" = {
             ang[1] <- pracma::atan2d(-R[2,3], R(3,3))
             ang[2] <- pracma::asind(R[1,3])
             ang[3] <- pracma::atan2d(-R[1,2], R[1,1])
           },
           "XZY" = {
             ang[1] <- pracma::atan2d(R[3,2], R[2,2])
             ang[2] <- -pracma::asind(R[1,2])
             ang[3] <- pracma::atan2d(R[1,3], R[1,1])
           },
           "YXZ" = {
             ang[1] <- pracma::atan2d(R[1,3], R[3,3])
             ang[2] <- -pracma::asind(R[2,3])
             ang[3] <- pracma::atan2d(R[2,1], R[2,2])
           },
           "YZX" = {
             ang[1] <- pracma::atan2d(-R[3,1], R[1,1])
             ang[2] <- pracma::asind(R[2,1])
             ang[3] <- pracma::atan2d(-R[2,3], R[2,2])
           },
           "ZXY" = {
             ang[1] <- pracma::atan2d(-R[1,2], R[2,2])
             ang[2] <- pracma::asind(R[3,2])
             ang[3] <- pracma::atan2d(-R[3,1], R[3,3])
           },
           "ZYX" = {
             ang[1] <- pracma::atan2d(R[2,1], R[1,1])
             ang[2] <- -pracma::asind(R[3,1])
             ang[3] <- pracma::atan2d(R[3,2], R[3,3])
           },
           stop(paste("Don't know specified rotation order"))
           )
    ang
  }
  # Which frames have data?
  detect_frames_with_data <- function(X, isTM){
    new_isnan <- function(x) any(!is.nan(x))
    if (isTM) {
      frameIdx <- apply(X, MARGIN = c(3), FUN = new_isnan)
    } else {
      frameIdx <- apply(X, MARGIN = c(3,1), FUN = new_isnan)
    }
    frameIdx
  }
  frameIdx <- detect_frames_with_data(tm, isTM = TRUE)
  
  n_col <- 6  # 3 translations, 3 rotations

  # Check format, needs to be 4 x 4 x n_frames
  if (dim(tm)[1] == 4 && dim(tm)[2] == 4 && is.na(dim(tm)[4])){
    n_frames <- dim(tm)[3]
    jcs_data <- matrix(NaN, nrow = n_frames, ncol = n_col)  # pre-allocate output

    for(fr in c(1:n_frames)){
      if (frameIdx[fr]){  # if there's data for this frame
      translation <- tm[1:3, 4, fr]  # Translation
      # Decompose transformation to tait-bryan angles
      rotation <- rot2taitbryan(tm[1:3, 1:3, fr], "ZYX")
      jcs_data[fr,] <- c(translation, rotation[3], rotation[2], rotation[1])
      }
    }
  }
  jcs_data
}
