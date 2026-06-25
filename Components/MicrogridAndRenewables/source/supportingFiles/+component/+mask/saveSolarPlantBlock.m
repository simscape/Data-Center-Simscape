function saveSolarPlantBlock()
%This function opens the solar cell block 

% Copyright 2025 The MathWorks, Inc.
blockPath = [gcb,'/','Detailed','/','PV Plant & Controller','/','PV Plant','/','PV Array'];
blockHandle = get_param(blockPath, 'Handle');
set_param(blockHandle,'LinkStatus','restore');
end