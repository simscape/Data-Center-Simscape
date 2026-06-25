function openSolarPVControllerBlock(blockPath)
%This function opens the solar PV controller block 

% Copyright 2025 The MathWorks, Inc.
%blockPath = [gcb,'/','Detailed','/','PV Plant & Controller','/','Controller','/','MPPT','/','Solar PV Controller'];
blockHandle = get_param(blockPath, 'Handle');
open_system(blockHandle,'mask');
end