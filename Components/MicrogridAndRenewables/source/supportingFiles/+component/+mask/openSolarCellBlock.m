function openSolarCellBlock(blockPath)

% Copyright 2025 The MathWorks, Inc.

%This function opens the solar cell block 

% Copyright 2025 The MathWorks, Inc.
%blockPath = [gcb,'/','Detailed','/','PV Plant & Controller','/','PV Plant','/','PV Array'];
%blockHandle = get_param(blockPath, 'Handle');
%linkStatus = get_param(blockPath,'LinkStatus');
% if strcmp(linkStatus,'resolved')
%     set_param(blockPath,'LinkStatus','none');
% end
open_system(blockPath,'Mask');
%set_param(blockPath,'ReferenceBlock','ee_lib/Sources/Solar Cell');

end
