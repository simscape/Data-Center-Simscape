classdef WorkloadType < int32
    % WorkloadType  Enumeration for compute workload pattern.
    %   Used by computeProfileSource to shape the demand cycle.

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        Training    (1)
        Inference   (2)
        FineTuning  (3)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('Training') = 'Training';
            map('Inference') = 'Inference';
            map('FineTuning') = 'FineTuning';
        end
    end
end
