function openCellBlock()

% Copyright 2025 The MathWorks, Inc.

blockPath = [gcb,'/','PV Array'];
blockHandle = get_param(blockPath, 'Handle');
set_param(blockHandle,'LinkStatus','none');
open_system(blockHandle,'Mask');
end