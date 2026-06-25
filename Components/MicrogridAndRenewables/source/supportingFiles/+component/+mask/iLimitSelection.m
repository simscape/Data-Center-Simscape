function iLimitSelection(tabs)
%This function displays the appropriate mask options depending on the
%fidelity chosen

% Copyright 2026 The MathWorks, Inc.

arguments
   tabs = {'ctLimitXbyR','ctLimitVirtualImp'};
end

blockPath = gcb;
choice = get_param(gcb,'currentLimitMethod');
maskObj = Simulink.Mask.get(gcb);
iLimitBlock = [blockPath,'/','Current Limiter','/','Current Limiter'];
switch choice
    case 'Virtual impedance'
        set_param(iLimitBlock, 'LabelModeActiveChoice', 'Virtual Impedance');
         for tabIdx = 1:length(tabs)
            tab = maskObj.getParameter(tabs{tabIdx});
            tab.Visible = 'on';
         end
    case 'Current saturation'
         set_param(iLimitBlock, 'LabelModeActiveChoice', 'Current Saturation');
         for tabIdx = 1:length(tabs)
             tab = maskObj.getParameter(tabs{tabIdx});
             tab.Visible = 'off';
         end
    otherwise
        disp('Choose proper variant');
end
end