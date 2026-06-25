function openConverterBlock(blockPath)

% Copyright 2025 The MathWorks, Inc.

%This function opens the solar cell block 

% Copyright 2025 The MathWorks, Inc.
%converterFidelity = get_param(gcb,'converterFidelity');
%blockPath = [gcb,'/',converterFidelity,'/','Converter'];

%blockHandle = get_param(blockPath, 'Handle');
%linkStatus = get_param(blockPath,'LinkStatus');
% if strcmp(linkStatus,'resolved')
%     set_param(blockPath,'LinkStatus','none');
% end
%set_param(blockHandle,'LinkStatus','none');
open_system(blockPath,'mask');
% 
% if strcmp (converterFidelity,'Switching')
%     refBlock = sprintf('ee_lib/Semiconductors &\nConverters/Converters/Converter\n(Three-Phase)');
% else
%     refBlock = sprintf('ee_lib/Semiconductors &\nConverters/Converters/Average-Value\nVoltage Source\nConverter\n(Three-Phase)');
% end
  % set_param(blockPath,'ReferenceBlock',refBlock);
end