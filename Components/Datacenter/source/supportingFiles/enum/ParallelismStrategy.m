classdef ParallelismStrategy < int32
    % ParallelismStrategy  Enumeration for GPU parallelism presets.
    %   Used by computeProfileSource to set TP and PP degrees.

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        TP8_PP4  (1)
        TP4_PP8  (2)
        TP8_PP8  (3)
        TP4_PP4  (4)
        Custom   (5)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('TP8_PP4') = 'TP8 PP4';
            map('TP4_PP8') = 'TP4 PP8';
            map('TP8_PP8') = 'TP8 PP8';
            map('TP4_PP4') = 'TP4 PP4';
            map('Custom')  = 'Custom';
        end
    end
end
