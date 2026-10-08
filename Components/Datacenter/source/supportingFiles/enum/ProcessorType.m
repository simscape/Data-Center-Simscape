classdef ProcessorType < int32
    % ProcessorType  Enumeration for processor type selection (GPU vs CPU).
    %   Used by gpuDieSignal to switch between GPU and CPU power models.

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        GPU  (1)
        CPU  (2)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('GPU') = 'GPU';
            map('CPU') = 'CPU';
        end
    end
end
