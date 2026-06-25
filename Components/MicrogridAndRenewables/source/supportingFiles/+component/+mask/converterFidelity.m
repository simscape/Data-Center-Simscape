function converterFidelity(blockPath)

% Copyright 2025 The MathWorks, Inc.

%This function displays the appropriate mask options depending on the
%fidelity chosen
arguments
    blockPath = gcb;
end
% Copyright 2025 The MathWorks, Inc.
choice = get_param(gcb,'converterFidelity');
%blockPath = gcb;
maskObj = Simulink.Mask.get(gcb);
allNames = {maskObj.Parameters.Name};
fSwIdx = find(strcmp(allNames, 'fSw'));

switch choice
    case 'Average'
        set_param(blockPath, 'LabelModeActiveChoice', 'Average');
         maskObj.Parameters(fSwIdx).Visible = 'off';
        % maskObj.Parameters(swIdx).Visible = 'off';
    case 'Switching'
         set_param(blockPath, 'LabelModeActiveChoice', 'Switching');
         maskObj.Parameters(fSwIdx).Visible = 'on';
        % maskObj.Parameters(swIdx).Visible = 'on';
    otherwise
        disp('Choose proper variant');
end
end