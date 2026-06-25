function setSwitchingFrequency(blockPath)
%This function opens the solar cell block 
arguments
    blockPath = gcb;
end
% Copyright 2025 The MathWorks, Inc.
converterFidelity = get_param(blockPath,'converterFidelity');
maskObj = Simulink.Mask.get(blockPath);
allNames = {maskObj.Parameters.Name};
fSwIdx = find(strcmp(allNames, 'fSw'));
if strcmp(converterFidelity,'Average')
    maskObj.Parameters(fSwIdx).Visible = 'off';
else
    maskObj.Parameters(fSwIdx).Visible = 'on';
end
end