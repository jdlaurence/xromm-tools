# XROMM Tools MATLAB

Welcome dear reader, to the wild world of MATLAB. Here's how to use this toolbox:

## Installation

Installation is simple. Just download or clone this respository, and ensure the three sub-folders ([example-data](https://github.com/jdlaurence/xromm-tools/tree/main/MATLAB/example-data), [functions](https://github.com/jdlaurence/xromm-tools/tree/main/MATLAB/functions), [manual](https://github.com/jdlaurence/xromm-tools/tree/main/MATLAB/manual)) are added to your MATLAB search paths. (In MATLAB, go to the Home ribbon, then Environment --> Set Path.)

## Documentation / Tutorial

The contents of the package are as follows:
* example-data - set of files to accompany the tutorial script (from [Pig Feeding tutorial](https://xmaportal.org/sandbox/larequest.php?request=studyOverview_public&StudyID=49&instit=SANDBOX1))
* functions - a set of processing functions, the core of this toolbox
* manual - a tutorial, [walk-through script](https://github.com/jdlaurence/xromm-tools/blob/main/MATLAB/manual/xromm_tools_matlab_tutorial.mlx) that can also serve as a template for your analysis.

**Please, please, please, work through the tutorial.mlx script before looking at the quickstart listed below or trying your own data. I promise it'll help.**

## Quickstart

For those interested in seeing the basic functionality without opening the tutorial script, here it is:

#### To import RBT files: 
```matlab
rbt = import_rbt('your_rbt_file.csv'); % For a single or combined file from XMALab

% For multiple RBT files
rbnames = {'Mandible' 'Cranium'}; 
rbts = [];
for rb = 1:length(rbnames)
   filename = [rbnames{rb} '.csv'];
   tmp_rbt = import_rbt(filename);
   rbts(:,:,:,rb) = tmp_rbt;
end
```

#### To import 3D point files:
```matlab
xyzpoints = import_xyz_points('your_3d_points_file.csv'); % import 3D points from XMALab
```

#### To import ACS positions (transformation matrices)
```matlab
acs_tm = import_acs_rel_bone('your_acs_file.csv'); % For a single file (less common)

% For multiple ACSs
acs_tms = []; % this variable will contain the transformation matrices for both mandible and cranium ACSs
for rb = 1:length(rbnames)
    filename = [rbnames{rb} '_acs_tm.csv'];
    tmp_acs_tm = import_acs_rel_bone(filename); % import
    acs_tms(:,:,rb) = tmp_acs_tm; % assign to variable
end
```

#### To calculate ACS motion
```matlab
tmp_rbt = rbts(:,:,:,rb); % From an matrix of multiple RBTs, where rb is the number of the rigid body of interest
tmp_acs_tm = acs_tms(:,:,rb); % From an matrix of ACS tms, where rb is the rigid body of interest
new_rbt = apply_acs_tm(tmp_rbt, tmp_acs_tm);
```

#### To calculate motion of 3D points in anatomical space
```matlab
new_pts = calculate_relative_motion(new_rbt, xyzpoints);   % Note, you may need to index the new_rbt if you have a 4D matrix of multiple rigid bodies
```

#### Quantify motion using a JCS
```matlab
% If new_rbt is combined with multiple rigid bodies
new_cranium_rbt = new_rbt(:,:,:,cranium_idx);
new_mandible_rbt = new_rbt(:,:,:,mandible_idx);

jcs_tm = calculate_relative_motion(new_cranium_rbt, new_mandible_rbt);

% Convert to Tait-Bryan angles and translations, the JCS standard
jcs_data = convert_tm_to_jcs(jcs_tm);

```

## Questions

For any questions, feel free to shoot me (J.D.) and email at jdlaurence@uchicago.edu
