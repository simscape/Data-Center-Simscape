classdef vanadiumRedoxFlowShuntCurrModel < int32
% Chemistry model selection definition.
    
% Copyright 2023 The MathWorks, Inc.

    enumeration
        disabled (1)
        equation (2)
        userdef  (3)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('disabled') = 'Disabled';
            map('equation') = 'Equation';
            map('userdef')  = 'User defined';
        end
    end
end
