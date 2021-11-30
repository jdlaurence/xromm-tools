function [rbt_out] = export_rbt(rbt,filename)
%Export RIGID BODY TRANSFORMATION FILE
% Converts 3- or 4-D matrix to Maya format and saves to csv
% User can decide not to save the file as CSV
%
% NOTE: Output file does NOT have column headers, so you need to uncheck
% 'Column Headers' in the imp window in Maya
%
% INPUT:
% - rbt: Matrix to be saved as csv [4 x 4 x nframes x nrigidbodies]
% - filename: Filename (string), or [] if you don't wanna save
% 
% OUTPUT:
% - rbt_out: Matrix in Maya format [nframes x 16(*nrigidbodies)]
%
% EXAMPLES:
%
% % with filesave
% [rbt_out] = export_rbt(rbt,'best_rigid_body_transform_ever.csv')
% % without filesave 
% [rbt_out] = export_rbt(rbt,[])
% 
% Written by J.D. Laurence-Chasen

if isempty(filename)
    savefile = false;
else
    savefile = true;
end

n_rigid_bodies = size(rbt,4);
nframes = size(rbt,3);
rbt_out = NaN(4,4,nframes,n_rigid_bodies); % pre-allocate

for rb = 1:n_rigid_bodies
    
    cols = (rb-1)*16+1:(rb-1)*16+16;
    
    for i = 1:nframes
        
        rbt_out(i,cols) = reshape(rbt(:,:,i,rb),1,16);
        
    end
    
end

if savefile
csvwrite(filename,rbt_out);
end

end

