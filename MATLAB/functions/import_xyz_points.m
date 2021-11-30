function [xyz_matrix] = import_xyz_points(filename)
% IMPORT XYZ (3D) POINTS
%
% import_xyz_points takes the 3D points file output from XMALab and
% converts it into a 3-D matrix of dimensions [n_points x 3 x n_frames],
% where columns are [x y z] positions.
%
%
% INPUT:
% - filename: character string of 3D points file from XMALab
%
% OUTPUT:
% - xyz_matrix: 3-D matrix where D1 is points (as in framespec file), D2 is
%               [x y z] positions, and D3 is frames
%
% EXAMPLE:
% [xyz_matrix] = import_xyz_points('Trial01_3DPoints.csv')
% 
% Written by J.D. Laurence-Chasen 2021

if ischar(filename) % assume it's a filename
    x = csvread(filename,1,0);   
elseif isnumeric(filename)  
    x = filename;  
else
    error('Data must be in .csv or matrix (double) format')
end

n_points = size(x,2) / 3;
n_frames = size(x,1);

xyz_matrix = NaN(n_points,3,n_frames); % pre-allocate output matrix

for pt = 1:n_points                 % for every point
    cols = (pt-1)*3+1:(pt-1)*3+3;   % these are the columns
    for fr = 1:n_frames             % for every frame
        xyz_matrix(pt,:,fr) = x(fr,cols);
    end
end
end

