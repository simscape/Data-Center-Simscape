function numPDU = getPDUCountForRating(NameValueArgs)
% Get number of PDUs required to acheive a desired data center rating

% Copyright 2026 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.DataCenterRating simscape.Value {mustBeNonempty}
        NameValueArgs.NumOfGPUperTray (1,1) {mustBeNonnegative,mustBeInteger}
        NameValueArgs.NumOfCPUperTray (1,1) {mustBeNonnegative,mustBeInteger}
        NameValueArgs.NumOfTraysPerRack (1,1) {mustBeNonnegative,mustBeInteger} = 6
        NameValueArgs.NumOfRacksPerPDU (1,1) {mustBeNonnegative,mustBeInteger} = 4
        NameValueArgs.GPUtdp simscape.Value {mustBeNonempty} = simscape.Value(1200,"W")
        NameValueArgs.GPUidlePower simscape.Value {mustBeNonempty} = simscape.Value(300,"W")
        NameValueArgs.GPUexponent simscape.Value {mustBeNonempty} = simscape.Value(1.4,"1")
        NameValueArgs.GPUhbmUtilFrac simscape.Value {mustBeNonempty} = simscape.Value(0.7,"1")
        NameValueArgs.GPUhbmPower simscape.Value {mustBeNonempty} = simscape.Value(80,"W")
        NameValueArgs.CPUtdp simscape.Value {mustBeNonempty} = simscape.Value(350,"W")
        NameValueArgs.CPUidlePower simscape.Value {mustBeNonempty} = simscape.Value(80,"W")
        NameValueArgs.CPUexponent simscape.Value {mustBeNonempty} = simscape.Value(1.1,"1")
        NameValueArgs.UtilizationGPU simscape.Value {mustBeNonempty} = simscape.Value(1,"1")
        NameValueArgs.UtilizationCPU simscape.Value {mustBeNonempty} = simscape.Value(1,"1")
    end
    
    [powGPUperTray,powCPUperTray] = ...
        getPowerConsumption(NumOfCPUperTray=simscape.Value(NameValueArgs.NumOfCPUperTray,"1"), ...
                            NumOfGPUperTray=simscape.Value(NameValueArgs.NumOfGPUperTray,"1"), ...
                            CPUexponent=NameValueArgs.CPUexponent, ...
                            CPUidlePower=NameValueArgs.CPUidlePower, ...
                            CPUtdp=NameValueArgs.CPUtdp, ...
                            GPUexponent=NameValueArgs.GPUexponent, ...
                            GPUhbmPower=NameValueArgs.GPUhbmPower, ...
                            GPUhbmUtilFrac=NameValueArgs.GPUhbmUtilFrac, ...
                            GPUidlePower=NameValueArgs.GPUidlePower, ...
                            GPUtdp=NameValueArgs.GPUtdp, ...
                            UtilizationCPU=NameValueArgs.UtilizationCPU, ...
                            UtilizationGPU=NameValueArgs.UtilizationGPU);

    totalPower = (powGPUperTray+powCPUperTray)*NameValueArgs.NumOfTraysPerRack*NameValueArgs.NumOfRacksPerPDU;

    numPDU = max(1,ceil(value(NameValueArgs.DataCenterRating,"W") / value(totalPower,"W")));
end