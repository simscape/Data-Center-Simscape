function setBESSController(blockPath)
%This function displays the appropriate mask options depending on the
%fidelity chosen
% Copyright 2025 The MathWorks, Inc.

arguments
    blockPath = [gcb,'/','Detailed','/','BESS Controller'];
end
% Copyright 2025 The MathWorks, Inc.
choice = get_param(gcb,'bessController');
%maskObj = Simulink.Mask.get(gcb);

switch choice
    case 'Grid Following'
        set_param(blockPath, 'LabelModeActiveChoice', 'Grid Following');
    case 'Grid Forming'
         set_param(blockPath, 'LabelModeActiveChoice', 'Grid Forming');
    otherwise
        disp('Choose proper variant');
end
end