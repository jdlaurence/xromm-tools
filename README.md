# XROMM Tools (for R and MATLAB)

## Motivation
The [XROMM](https://www.xromm.org/) (X-ray Reconstruction of Moving Morphology) community continues to grow rapidly, as does the use of XROMM data. Concurrently, the scientific community has adopted higher standards of data reproducibility and transparency of analysis; more often than not, researchers are required to submit both their data and code alongside a manuscript.
The [XROMM_MayaTools](https://bitbucket.org/xromm/xromm_mayatools/wiki/Home) shelf, the standard toolbox for XROMM data processing, is powerful and user-friendly but is not ideal for the programmatic automation of data analysis. After exporting tracked data from XMALab, it is virtually impossible to reproduce a user's processing steps in Maya (unless they have meticulously documented every mouse-click). Fortunately, the actual mathematic operations underlying most data processing in Maya are (relatively) straightforward and, thus, replicable.

Thus, the motivation for the performing these operations outside of Maya is to increase **reproducibility**, **transparency**, and **ease of batch processing**.

## What this is, and what this is not
Replicates Mayatools functions, allows for batch processing. Does not fully eliminate maya from workflow, still need to..

## Instructions

## Credits
### XROMM and MayaTools
[Full history of XROMM and its development](https://www.xromm.org/history/). Dave Baier is the primary developer of XROMM_MayaTools, upon which the entirety of this repository is based. We are sincerely grateful for all of his work. Steve Gatesy and Beth Brainerd lead the development of XROMM as a, which itself is based on ...  
### xromm-tools MATLAB
[J.D. Laurence-Chasen](https://github.com/jdlaurence) developed the MATLAB version of xromm-tools over the duration of his PhD.

### xromm-tools R
[Kara Feilich](https://github.com/kfeilich) translated the MATLAB version of xromm-tools to R, and was consistently perplexed by J.D.'s variable naming.
