classdef vanadiumRedoxFlowThermalModel < int32
% Thermal model selection definition.
    
% Copyright 2023 The MathWorks, Inc.

    enumeration
        disabled (1)
        enabled  (2)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('disabled') = 'Disabled';
            map('enabled')  = 'Enabled';
        end
    end
end
