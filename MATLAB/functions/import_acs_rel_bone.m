function [acs_matrix] = import_acs_rel_bone(filename)
%IMPORT ACS POSITION
% Takes a RBT file from MAYA and converts it into a 4x4 transformation
% matrix.
%
% INPUT:
% - filename: character string of RBT file from ~Maya~ (following tutorial
%             instructions)
%
% OUTPUT:
% - acs_matrix: 4x4 transformation matrix that describes the position of
%               the ACS relative to the bone model
%
% EXAMPLE:
% [acs_matrix] = import_acs_rel_bone('cranium_acs_tm.csv')
%
% Written by J.D. Laurence-Chasen 11/17/2021

if ischar(filename) % assume it's a filename
    x = csvread(filename,1,0);
elseif isnumeric(filename)
    x = filename;
else
    error('Data must be in .csv or matrix (double) format')
end

if size(x,2) > 1  % if there are multiple frames (rows)
    % use first frame with data (not NaN)
    frame_to_use = find(any(~isnan(x),2),1);
else
    frame_to_use = 1;
end
    acs_matrix = reshape(x(frame_to_use,:),4,4);
end

