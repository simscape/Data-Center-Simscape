% Copyright 2025 - 2026 The MathWorks, Inc.

function sl_customization(cm)
    % Change the order of libraries in the Simulink Library Browser. 
    cm.LibraryBrowserCustomizer.applyNodePreference({"Simulink",false,"Simscape Custom Components",true});
end