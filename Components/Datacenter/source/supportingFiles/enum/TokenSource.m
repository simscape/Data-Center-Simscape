classdef TokenSource < int32
    % TokenSource  Enumeration for inference token length source.
    %   Fixed:    use parameter values for prompt/output token counts
    %   External: use input port signals (e.g. from a distribution)

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        Fixed    (1)
        External (2)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('Fixed')    = 'Fixed';
            map('External') = 'External';
        end
    end
end
