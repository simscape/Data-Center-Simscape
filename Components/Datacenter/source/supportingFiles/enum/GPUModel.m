classdef GPUModel < int32
    % GPUModel  Enumeration for GPU hardware presets.
    %   Used by computeProfileSource to set peak TFLOPS per GPU.

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        Rubin_Ultra (1)
        B200        (2)
        H200        (3)
        H100        (4)
        A100        (5)
        MI300X      (6)
        MI325X      (7)
        Gaudi3      (8)
        Custom      (9)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('Rubin_Ultra') = 'Rubin Ultra';
            map('B200')        = 'B200';
            map('H200')        = 'H200';
            map('H100')        = 'H100';
            map('A100')        = 'A100';
            map('MI300X')      = 'MI300X';
            map('MI325X')      = 'MI325X';
            map('Gaudi3')      = 'Gaudi3';
            map('Custom')      = 'Custom';
        end
    end
end
