classdef datacenterPhysics < int32
% Datacenter physics model option definition.
    
% Copyright 2025 The MathWorks, Inc.

    enumeration
        linear    (1)
        nonlinear (2)
    end
    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('linear') = 'Linear';
            map('nonlinear')  = 'Non-linear';
        end
    end
end