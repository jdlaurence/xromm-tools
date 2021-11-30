function [rel_motion] = calculate_relative_motion(reference_element_xform, mobile_element_xform)
% CALCUATE RELATIVE MOTION OF TWO BODIES
%
% This function, similar to oRel in Maya, calculates the relative motion of
% either 'mobile' 3D point/s or rigid body relative to 'proximal'/reference
% rigid body.
% 
% The function is written to handle multiple frames/timepoints of data (see
% INPUT for format), and will automatically detect which frames have data,
% and pad the output with NaNs accordingly.
%
%
% LOGIC:
% The math underlying the calculation ultimately boils down to multiplying
% the inverse of the reference transformation matrix by the mobile
% element's position (XYZ or transformation matrix).
%
%
% INPUT:
% - reference_element_xform: matrix (double) of reference/proximal rigid 
%        body transformation (transformation matrix)
%
%
% - mobile_element_xform: matrix (double) of either 3D point/s position or
%        mobile element's rigid body transformation (transformation
%        matrix). In the case of 3D points, format is D1 is points,
%        D2 is [x y z] positions, and D3 is frames, in
%        case of transformation matrix, D1,D2 are 4x4 TMs,
%        D3 is frames.
%
% OUTPUT:
% - rel_motion: matrix of relative motions, of same dimensions as
%               mobile_element_xform
%
%
% Written by J.D. Laurence-Chasen, 2021


% First take stock of data...
% let's shorten names
ref = reference_element_xform;
mob = mobile_element_xform;

% Check format (TM or 3D points) and whether there are multiple time points
[isTMref, isStaticref] = check_data_format(ref);
[isTMmob, isStaticmob] = check_data_format(mob);

if ~isTMref
    error('Uh oh. Reference input needs to be a 4x4 transformation matrix')
end

% If both are dynamic, make sure they have the same number of frames
if ~isStaticref && ~isStaticmob
    if size(ref,3) ~= size(mob,3)
       error('Uh oh...inputs have unequal number of frames')
    end
end

% How many frames?
n_frames = max(size(ref,3),size(mob,3));

% Replicate static matrix n_frames times, if one input is dynamic
if xor(isStaticref,isStaticmob) 
    if isStaticref
        ref = repmat(ref,1,1,n_frames);
    else
        mob = repmat(mob,1,1,n_frames);
    end
end        

% Which frames have data?
frame_idx_ref = detect_frames_with_data(ref,isTMref);
frame_idx_mob = detect_frames_with_data(mob,isTMmob);
frame_idx = frame_idx_ref & any(frame_idx_mob,2);

if isTMmob
    n_rows = 4;
    n_cols = 4;
else
    n_rows = size(mob,1);
    n_points = n_rows;
    n_cols = 3;
end

rel_motion = NaN(n_rows,n_cols,n_frames); % pre-allocate output array

% MAIN LOOP
for fr = 1:n_frames % for every frame
    
    if frame_idx(fr) % if there's data for this frame
        
        % reference transformation matrix for this frame
        ref_matrix = ref(:,:,fr);
        inv_ref_matrix = inv(ref_matrix); % invert reference tm
        
        if isTMmob % if mobile element is a transformation matrix
            
            % mobile element matrix for this frame
            mob_matrix = mob(:,:,fr);
            %%%
            tmp_out = inv_ref_matrix * mob_matrix; % CORE OPERATION
            %%%
            rel_motion(:,:,fr) = tmp_out;
            
        else % it's 3D points
            
            for pt = 1:n_points
                
                if frame_idx_mob(fr,pt) % if there's data for that point
                    
                    mob_matrix = mob(pt,:,fr)'; % transpose for math
                    mob_matrix = [mob_matrix; 1]; % add 1 for math
                    %%%
                    tmp_out = inv_ref_matrix * mob_matrix; % CORE OPERATION
                    %%%
                    tmp_out = tmp_out(1:3)'; % get rid of 1
                    rel_motion(pt,:,fr) = tmp_out; % store
                end
            end
        end    
    end
end

function [isTM, isStatic] = check_data_format(X)

% see if its 3D points or a xform matrix
if size(X,1) == 4 && size(X,2) == 4 % if it's a 4x4 xform matrix
    isTM = true;
elseif size(X,2) == 3 % if it has 3 colums i.e. xyz point/s
    isTM = false;
else
    error('Hmmm. Check your input formats...')
end

% see if it's dynamic or static (multiple frames or one frame)
if size(X,3) > 1
    isStatic = false;
else
    isStatic = true;
end

% just a quick error check
if length(size(X)) > 3
    error('Hmmm. Your input data matrix should only have 2 or 3 dimensions')
end

function [frameIdx] = detect_frames_with_data(X,isTM)
% frameIdx is a logical nFrames long, where frames with data are true;
% if X is multiple 3D points, it will be nframes x npoints, and show which
% specific points have data for a given frame

if isTM % if it's a transformation matrix
   
    frameIdx = squeeze(any(any(~isnan(X),1),2));

else % if it's 3D points, have columns be different points
    
    frameIdx = squeeze(any(~isnan(X),2))';
    
end

