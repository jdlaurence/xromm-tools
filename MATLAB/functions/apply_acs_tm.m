function [new_rbt] = apply_acs_tm(rbt, acs_tm)
% APPLY ACS TRANSFORMATION MATRIX
% Apply anatomical coordinate system transformation matrix to a rigidy body
% transformation.
% 
% The rigid body transformations that are output from XMALab describe a
% transformation of a bone from CT space to Cube space. This function
% applies the ACS transformation matrix to the RBTs, such that the new_rbt
% describes the transformation of a bone from anatomical (ACS) space to
% Cube space, and thus can be used to calculate the relative motion of
% points and other bones.
%
% In short, this functions multiplies the RBT by the ACS TM for every frame.
%
% INPUT
% - rbt: 2- or 3- matrix where D1,D2 are 4x4 transformation matrices and D3 is frames 
% - acs_tm: 4x4 transformation matrix of ACS relative to bone model 
%
% OUTPUT
% - new_rbt: new transformation matrix, same dimensions as input rbt
%
% EXAMPLE
% new_rbt = apply_acs_tm(rbts(:,:,:,1),acs_tms(:,:,1));
%
% Written by J.D. Laurence-Chasen, 2021


% First take stock of data...
% Check ACS format
if length(size(acs_tm)) ~= 2 || size(acs_tm,1) ~= 4 || size(acs_tm,2) ~=4 
    error('Something"s wrong with ACS transformation matrix')
end

% Check RBT format
if size(rbt,1) ~= 4 || size(acs_tm,2) ~=4 
    error('Something"s wrong with RBT transformation matrix')
end

n_rows = 4;
n_cols = 4;
n_frames = size(rbt,3); 

% Which frames have data?
frame_idx = squeeze(any(any(~isnan(rbt),1),2));

new_rbt = NaN(n_rows, n_cols, n_frames); % pre-allocate output array

% MAIN LOOP
for fr = 1:n_frames % for every frame
    
    if frame_idx(fr) % if there's data for this frame
            
            % rbt for this frame
            tmp_rbt = rbt(:,:,fr);           
            tmp_out =  tmp_rbt * acs_tm; % MAIN EQUATION
            new_rbt(:,:,fr) = tmp_out;
    end
end

