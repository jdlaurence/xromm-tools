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

## Quickstart

## Questions

