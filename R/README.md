# XROMM Tools R

Welcome dear reader, to the wild world of XROMM in R. Let's talk about how to use this toolbox. 

## Installation
I've developed this code as an R package, which means you can install it, the vignette, and the tutorial data all in one fell swoop from within R.
Using devtools:

```
devtools::install_github("jdlaurence/xromm-tools", subdir = "R", build_vignettes = TRUE)
```

Note that because of R's package name requirements, the name of the package when you go to load it is NOT xromm-tools. Instead, you'll have to call this clunky thing:
```
library(xrommToolsR)
```
I'm so sorry.
Note the dependencies of this R package. You will need at a minimum:
* abind  -- an R package for high-dimensional arrays
* utils
* pracma -- for the matrix math
* rmarkdown
* knitr


## Documentation / Tutorial
After installing and loading the package as above, you'll want to go through the vignette. To access that, type the following into your console.
```
vignette("xrommToolsR-vignette", package = "xrommToolsR")
```

I am begging you. PLEASE look at the vignette before you ask questions or use the "quickstart". The "quickstart" is only useful if you already know what you're doing.

## Quickstart

#### To import RBT files: 
```
rbt <- import_rbt("your_rbt_file.csv")  # For a single or combined file

# For multiple RBT files
rbt_list <- lapply(list("file1.csv", "file2.csv",...), import_rbt)  # will generate a list object of RBT arrays
# To combine an RBT list into an array, use abind
rbt_array <- abind(rbt_list, along = 4)

```

#### To import 3D point files:
```
xyz_pts <- import_xyz_points("your_3dpts_file.csv")
```

#### To import ACS positions (transformation matrices)
```
acs <- import_acs_rel_bone("your_acs_file.csv")  # For a single file

# For multiple ACSs
acs_list <- lapply(list("acs_file_1.csv", "acs_file_2.csv", ...), import_acs_rel_bone)  # Will generate a list of ACS matrices
acs_array <- abind(acs_list, along = 3)
```

#### To calculate ACS motion
```
tmp_rbt <- rbt_array[,,,rb]  # From an array of multiple RBTs, where rb is the number of the rigid body of interest
tmp_acs <- acs_array[,,rb]  # From an array of ACS tms, where rb is the rigid body of interest
new_rbt <- apply_acs_tm(tmp_rbt, tmp_acs)
```

#### To calculate motion of 3D points in anatomical space
```
new_pts <- calculate_relative_motion(new_rbt, xyz_points)   # Note, you may need to index the new_rbt if you have a 4D array of multiple rigid bodies
```

#### Quantify motion using a JCS
```
#Iff new_rbt is combined with multiple rigid bodies
new_cranium_rbt <- new_rbt[,,,cranium_idx]
new_mandible_rbt <- new_rbt[,,,mandible_idx]

jcs_tm <- calculate_relative_motion(new_cranium_rbt, new_mandible_rbt)

# Convert to Tait-Bryan angles and translations, the JCS standard
jcs_data <- convert_tm_to_jcs(jcs_tm)

```

## Questions

