function [rbt_matrix] = import_rbt(filename)
% IMPORT RIGID BODY TRANSFORMATION FILE
%
% import_rbt takes the RBT file output from XMALab and converts it into a
% 4-D matrix of dimensions [4 x 4 x n_frames x n_rigid_bodies]. If
% the RBT file contains only one RBT (as when "Single files" is checked
% upon XMALab export), size(rbt_matrix,4) == 1.
% 
%
% INPUT:
% - filename: character string of RBT file from XMALab
%
% OUTPUT:
% - rbt_matrix: 4-D matrix where the D1 and D2 are the rows and
%               columns of a 4x4 transformation matrix, D3 is frames, and
%               D4 is rigid bodies (if there are more than one in the
%               file).
%
% EXAMPLE:
% [rbt_matrix] = import_rbt('Trial01_RBT.csv')
%
% Written by J.D. Laurence-Chasen 2021

% Check input format
if ischar(filename) % assume it's a filename
    
    tmp = csvread(filename,1,0);
    % check if frame numbers
    if rem(size(tmp,2),16) ~= 0
        frameNum = 1;
    else
        frameNum = 0;
    end
    
    try
        x = csvread(filename,0,frameNum); % no header
    catch
        x = csvread(filename,1,frameNum); % column headers
    end
    
elseif isnumeric(filename)
    
    x = filename; 
else
    error('Data must be in .csv or matrix (double) format')
end


n_rigid_bodies = size(x,2) / 16;
n_frames = size(x,1);
rbt_matrix = NaN(4,4,n_frames,n_rigid_bodies); % pre-allocate output matrix

for rb = 1:n_rigid_bodies               % for every rigid body 
    cols = (rb-1)*16+1:(rb-1)*16+16;    % these are the columns
    for fr = 1:n_frames                 % for every frame  
        % reshape 1x16 to 4x4 and store in output var
        rbt_matrix(:,:,fr,rb) = reshape(x(fr,cols),4,4);
    end
end

end

