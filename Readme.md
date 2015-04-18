## Instructions for use of masclab

### Introduction

**masclab** is a selection of MATLAB tools for analyzing data collected by the [Fallgatter Technologies](http://fall-tech.com)
Multi-Angle Snowflake Camera or [MASC](http://www.inscc.utah.edu/~tgarrett/Snowflakes/MASC.html).
It takes the scientist from raw image and velocity data to statistics for relating hydrometeor properties. 

**masclab** *is not a commercial product and comes with no explicit offer of support*.

**masclab** is nothing more than a collection of rather poorly designed programming tools that were developed by
Tim Garrett at the University of Utah for his own scientific research. It may all be rather bad. Nonetheless, 
**masclab** is designed with other users in mind, and it is hoped that others might find it useful and improve it.

IT IS CRITICAL TO CONTACT TIM GARRETT BEFORE USING THIS SUITE. IT IS NOT A PROFESSIONALLY DESIGNED PRODUCT.

Where there are months of data, it will be advisable to find a computer with as much memory as possible 
and multiple cores. Analysis at the University of Utah is run on, at a minimum, a 32 GB machine with 8 cores 
in parallel mode.

### Overview

**masclab** has four primary components organized by folder. Main programs that are not either functions 
(subroutines) or called by a main program are italicized: Programs that must be read, roughly understood, 
and / or modified to some degree are underlined. It might be a good idea to read all the codes.

#### dataio/
| File | Modify | Description |
|-----|-----|-----|
| uploaddirs.m | | Determines directories where MASC data is stored |
| upload.m | | Determines velocity and image files |
| outdirs.m | | Creates filenames and directories for processed images and statistics |

#### userspecs/
| File | Modify | Description |
|-----|:---:|----|
| mascpaths.m | Y | Specify path to masclab |
| label_params.m | Y | Specifies label format for input and output images for MASC_process.m |
| cam_params.m | Y | Specifies camera lens, camera type, and image transfer rate for MASC_process.m |
| process_params.m | Y | Image analysis thresholds. Primarily for image rejection for MASC_process.m |
| diagnostics_params.m | Y | Specifies file output files from loadstats.m and loaddiags.m |
| blockstats_params.m | Y | Sets file input and output parameters for blockstats.m |
| strip_params.m | Y | Sets file input and output parameters for creating a stripchart with flakestrip.m |

#### processing/
| File | Modify | Description |
|-----|:---:|----|
| MASC_process.m | Y | Analyzes all raw MASC data to create diagnostics and statistical variables |
| loaddiags.m | Y | Loads all analyzed MASC diagnostics data and creates higher level data products including paths to snowflake images. Saves data as a continuous time series |
| loadstats.m | Y | Loads all analyzed MASC data and creates higher level data products. Saves data as a continuous time series |
| brightening.m |  | Adds gamma correction to snowflake images to increase their apparent exposure as specified in process_params.m |
| masking.m |  | Blocks out extraneous background clutter in the edges of the image frame as specified in process_params.m |
| sxthresholds.m | Y | This offers a chance for a second cut through the snowflakes for quality control. THIS IS A MUST READ AHEAD OF ANY SERIOUS ANALYSIS |
| uploadstats.m |  | Uploads the continuous output from loaddiags.m and loadstats.m according to the input from diagnostics_params.m. From this point, you are on your own for creating your own plots of the data. Scientific collaboration is always possible. |
| blockstats.m |  | Create a file with consecutive time blocks of statistics for hydrometeor parameters, as specified in blockstats_params.m |

#### statistics/
| File | Modify | Description |
|-----|-----|----|
| camstats.m | | Calculates statistics for hydrometeor properties accounting for multiple view per image |
| camlabelstats.m | | Image paths for the statistics produced by camstats.m |
| insertnans.m | | Creates a continuous time series with NaNs inserted where no MASC data was recorded |
| labelinsertnans.m | | Image paths for the continuous time series produced by instertnans.m |
| nanblockstats.m | | Creates a running statistical analysis of a time series, organized in sequential time blocks. A range of statistical analyses are available. |

#### plotting/
| File | Modify | Description |
|-----|-----|----|
| flakestrip.m | | Creates a strip chart booklet in postscript format for the output from blockstats.m according to the variables, plotting conditions, and input and output files specified in strip_params.m |
| stripchart.m | | Subroutine for creating a stripchart |

### Operation
1. Place **masclab** in your MATLAB _path_ using _pathtool_ or by editing **mascpaths.m**
1. Adjust the matlabfiles in **userspecs/** as you see fit and as pertain to your MASC and field program.
Adjust **process_params.m**. only if you feel brave, perhaps if you think the image processing is rejecting too
much or too little, and then perhaps after consultation with Tim Garrett
1. If possible, find a fast computer with nothing else to do, preferably with as many processors as 
possible so that MATLAB can take advantage of the parallel processing toolbox.
1. Run **MASC_process.m** Specify _starthr_ and _endhr_ first. In general _firsttime_ should be equal to 1,
unless you are feeling brave and want to test analysis algorithms on individual flakes.
1. Wait. Count on a second per flake per processor. Sorry. Image analysis apparently takes time. It might be days.
1. Run **loaddiags.m** Specify _starthr_ and _endhr_ Matlab is terrible at handling strings. Count on lots of 
time particularly when it comes to saving data.
1. Run **loadstats.m** Specify _starthr_ and _endhr_
1. Run **uploadstats.m** to upload analyzed variables into memory in continuous time form in order begin detailed
scientific analyses.
1. Adjust and run **sxthresholds.m** to optimize selection of good images. Scientific analyses may begin here.
1. (Optional) Run **blockstats.m** to create time blocked statistics using nanblockstats.m, which can do quite a lot.
1. (Optional) Run **flakestrip.m** to create a booklet of how hydrometeor parameters have evolved through
time over the course of the project.


### Dependencies
1. **MASC_process.m**
  * uploaddirs.m
  * upload.m
  * outdirs.m
  * label_params.m
  * process_params.m
     - cam_params.m
     - masking.m
     - brightening.m
1. **loaddiags.m**
  * uploaddirs.m
  * label_params.m
  * cam_params.m
  * camstats.m
  * insertnans.m 
1. **loadstats.m**
  * uploaddirs.m
  * label_params.m
  * cam_params.m
  * camstats.m
  * insertnans.m
1. **uploadstats.m**
  * diagnostics_params.m
  * cam_params.m
  * sxthresholds.m
1. **blockstats.m**
  * blockstats_params.m
  * diagnostics_params.m
  * nanblockstats.m
1. **flakestrip.m**
  * ockstats_params.m
  * diagnostics_params.m
  * strip_params.m
  * stripchart.m
 
### Externally supplied functions and libraries
**jab** available at [http://www.jmlilly.net/jmlsoft.html](http://www.jmlilly.net/jmlsoft.html) 
This is worth downloading in any case. Lots of goodies. 

**ismemberf.m** floating point errors are a pain. This helps. 
[http://www.mathworks.com/matlabcentral/fileexchange/23294-ismemberf](http://www.mathworks.com/matlabcentral/fileexchange/23294-ismemberf)

### Required matlab toolboxes
**Image processing**

**Parallel computing** Not necessary, but will accelerate processing where there is access to a machine
with multiple cores



