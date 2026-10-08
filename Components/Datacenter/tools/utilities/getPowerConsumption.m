function [powGPUtotal,powCPUtotal] = getPowerConsumption(NameValueArgs)
% Get power consumption in data center

% Copyright 2026 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.NumOfGPUperTray simscape.Value {mustBeNonempty}
        NameValueArgs.NumOfCPUperTray simscape.Value {mustBeNonempty}
        NameValueArgs.GPUtdp simscape.Value {mustBeNonempty}
        NameValueArgs.GPUidlePower simscape.Value {mustBeNonempty}
        NameValueArgs.GPUexponent simscape.Value {mustBeNonempty}
        NameValueArgs.GPUhbmUtilFrac simscape.Value {mustBeNonempty}
        NameValueArgs.GPUhbmPower simscape.Value {mustBeNonempty}
        NameValueArgs.CPUtdp simscape.Value {mustBeNonempty}
        NameValueArgs.CPUidlePower simscape.Value {mustBeNonempty}
        NameValueArgs.CPUexponent simscape.Value {mustBeNonempty}
        NameValueArgs.UtilizationGPU simscape.Value {mustBeNonempty}
        NameValueArgs.UtilizationCPU simscape.Value {mustBeNonempty}
    end

    arguments (Output)
        powGPUtotal simscape.Value {mustBeNonempty}
        powCPUtotal simscape.Value {mustBeNonempty}
    end
    
    % === GPU POWER MODEL ===
    % Nonlinear: P = P_idle + P_dyn * (2U - U^alpha)
    powGPUdyn   = (NameValueArgs.GPUtdp - NameValueArgs.GPUidlePower) * (2*NameValueArgs.UtilizationGPU - NameValueArgs.UtilizationGPU^NameValueArgs.GPUexponent);
    utilMemory  = min(NameValueArgs.UtilizationGPU * NameValueArgs.GPUhbmUtilFrac + {0.1, "1"}, {1, "1"});
    powGPUhbm   = NameValueArgs.GPUhbmPower * utilMemory * NameValueArgs.NumOfGPUperTray;
    powGPUtotal = (NameValueArgs.GPUidlePower + powGPUdyn) * NameValueArgs.NumOfGPUperTray + powGPUhbm;

    % === CPU POWER MODEL ===
    % Near-linear with DVFS: P = P_idle + P_dyn * U^beta
    powCPUdyn   = (NameValueArgs.CPUtdp - NameValueArgs.CPUidlePower) * NameValueArgs.UtilizationCPU^NameValueArgs.CPUexponent;
    powCPUtotal = (NameValueArgs.CPUidlePower + powCPUdyn) * NameValueArgs.NumOfCPUperTray;

end