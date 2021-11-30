function [jcs_data] = convert_tm_to_jcs(tm)
%CONVERT TRANSFORMATION MATRIX TO JCS FORMAT 
% This function converts a 3-D transformation matrix [4 x 4 x nframes] into
% standard Joint coordinate system format, [nframes x 6], where columns are
% [tx ty tz rx ry rz]. 
%
% TRANSLATIONS
% The translations are easy: they're just the 4th column of each
% transformation matrix. 
%
% PLEASE BE AWARE: Grood and Suntay (1983) formally define JCS translations
% as being along the three axes of a JCS (two fixed axes and one floating
% (calculated) axis). The output of this function as well as oRel/MayaTools
% is translation along the axes of the proximal ACS/element, NOT a
% combination of proximal/distal ACSs.
%
% ROTATIONS
% The rotations, which are often referred to as "Euler Angles", are
% actually Tait-Bryan angles if we want to be most accurate. The
% decomposion of a 3x3 rotation matrix to Tait-Bryan angles involves a
% bunch of trig functions, which you can view in all their glory in the
% function rot2taitbryan below. As is standard in XROMM analysis, we use a
% ZYX rotation order (change below, at your peril).
%
% INPUT:
% - tm: 3-D transformation matrix (4 x 4 x nframes)
%
% OUTPUT:
% - jcs_data: JCS motion data where D1 is frames and D2 is
%            [tx ty tz rx ry rz]
%
%
% Written by J.D. Laurence-Chasen 2021

n_col = 6; % 3 translations, 3 rotations

% check format, needs to be 4 x 4 x nframes
if size(tm,1) == 4 && size(tm,2) == 4 && size(tm,4) == 1
    
    n_frames = size(tm,3);
    jcs_data = NaN(n_frames,n_col); % pre-allocate output
    
    for fr = 1:n_frames
        translation = tm(1:3,4,fr); % translation
        rotation = rot2taitbryan(tm(1:3,1:3,fr), 'ZYX'); % decompose transformation matrix to tait-bryan angles
        jcs_data(fr,:) = [translation' rotation(3) rotation(2) rotation(1)];
    end
end
        
   
function ang = rot2taitbryan(R,order)
% Calculates extrinsic Tait-Bryan angles from rotation matrix
%
% * `R`: Rotation matrix (3x3)
% * `order`: Order of anger angles to return; any of:
%              {'XYZ','XZY','YXZ','YZX','ZYX','ZXY'} %case insensitive
%           
% * `ANG`: Angles (degrees) in specified order
%
%NOTE: order of application of these rotations is right-to-left, both as
%indicated by `order` and `ANG'. 

switch upper(order)

  case 'XYZ'
    ang(1) = atan2d(-R(2,3),R(3,3));
    ang(2) = asind(R(1,3));
    ang(3) = atan2d(-R(1,2),R(1,1));
    
  case 'XZY'
    ang(1) = atan2d(R(3,2),R(2,2));
    ang(2) = -asind(R(1,2));
    ang(3) = atan2d(R(1,3),R(1,1));
    
  case 'YXZ'
    ang(1) = atan2d(R(1,3),R(3,3));
    ang(2) = -asind(R(2,3));
    ang(3) = atan2d(R(2,1),R(2,2));
    
  case 'YZX'
    ang(1) = atan2d(-R(3,1),R(1,1));
    ang(2) = asind(R(2,1));
    ang(3) = atan2d(-R(2,3),R(2,2));
    
  case 'ZXY'
    ang(1) = atan2d(-R(1,2),R(2,2));
    ang(2) = asind(R(3,2));
    ang(3) = atan2d(-R(3,1),R(3,3));

  case 'ZYX'
    ang(1) = atan2d(R(2,1),R(1,1));
    ang(2) = -asind(R(3,1));
    ang(3) = atan2d(R(3,2),R(3,3));
    
  otherwise
    error('Don''t know specified rotation order %s', order)

end

