# xromm-tools
![xromm-tools](https://user-images.githubusercontent.com/53494838/144144359-f118f0f4-9aab-4ba5-888a-2d77a5d76b5c.PNG)
## What is this? (and what isn't it?)
This toolbox replicates the core functionality of the [XROMM_MayaTools](https://bitbucket.org/xromm/xromm_mayatools/wiki/Home) shelf and introduces a workflow for the batch processing of [XROMM](https://www.xromm.org/) (X-ray Reconstruction of Moving Morphology) data directly from XMALab. In bypassing Autodesk Maya, all downstream analysis (ACS + JCS calculation, statistics, figure generation, etc.) can be performed in a single programming environment (R or MATLAB). Importantly, Autodesk Maya is still required in a key step in the workflow, and retaining Maya and MayaTools as resource for 'sanity-checks' and visualizations is definitely a good idea.

## Motivation
The XROMM community continues to grow rapidly, as does the use of XROMM data. Concurrently, the scientific community has adopted higher standards of data reproducibility and transparency of analysis; more often than not, researchers are required to submit both their data and code alongside a manuscript.  

The XROMM_MayaTools shelf, the standard toolbox for XROMM data processing, is powerful and user-friendly but is not ideal for the programmatic automation of data analysis. After exporting tracked data from XMALab, it is virtually impossible to reproduce a user's processing steps in Autodesk Maya (unless they have meticulously documented every mouse-click). Fortunately, the actual mathematic operations underlying most data processing in Maya are (relatively) straightforward and, thus, replicable in common programming languages.

_Overall, the motivation for performing these operations outside of Maya is to increase **reproducibility**, **transparency**, and **ease of batch processing** in XROMM projects._ 

## Installation + Instructions 
The [R](https://github.com/jdlaurence/xromm-tools/tree/main/R) and [MATLAB](https://github.com/jdlaurence/xromm-tools/tree/main/MATLAB) subfolders in this repository contain functionally identical versions of the toolkit; we tried our best to keep things consistent. There are, however, slight differences in terms of installation and usage, so be sure to follow the instructions for the language you wish to use (located in their respective subfolders).

## Generalized Quickstart
Regardless of implementation (R vs. MATLAB), the basic flow of data through the `xromm-tools` pipeline is the same. You'll need:  
* This package installed
* Autodesk Maya and the MayaTools shelf installed
* Bone mesh models and corresponding rigid body transformations from XMALab  
* Optional: 3D points from XMALab

The first step is placing anatomical coordinate systems and exporting their positions from Maya. It's totally fine if the bone models are already animated and/or you've already placed the ACSs. You'll use standard MayaTools functions to export the position of the ACSs from Maya to CSV files. If you ever want to change the position/orientation of an ACS, or create a new one, you'll re-export its position.

The rest of the workflow is in R or MATLAB. You'll import the ACS positions, RBTs, and 3D points, then calculate JCS motions and/or 3D point positions relative to bones with the provided scripts. If you want to add more trials or re-run an analysis across all trials, you won't ever need to re-animate bones or re-calculate oRel again. 

## Credits
### XROMM and MayaTools
[Professor Dave Baier](https://biology.providence.edu/faculty-members/david-baier/) is the primary developer of XROMM_MayaTools, upon which the entirety of this toolbox is based. We are sincerely grateful for all of his work. Professors Steve Gatesy and Beth Brainerd lead the development of XROMM, which itself was based on Prof. Gatesy's [Scientific Rotoscoping](https://onlinelibrary.wiley.com/doi/10.1002/jez.588) work. [See here](https://www.xromm.org/history/) for a full history of XROMM. 
### xromm-tools MATLAB
[J.D. Laurence-Chasen](https://github.com/jdlaurence) developed the MATLAB version of xromm-tools over the duration of his PhD.

### xromm-tools R
[Kara Feilich](https://github.com/kfeilich) translated the MATLAB version of xromm-tools to R, and was consistently perplexed by J.D.'s variable naming.
