% Specify library and custom library paths.
% 
% Copyright 2025 The MathWorks, Inc.

%% Define custom library path
customBlkPath.roomVol = "buildingEnergy_lib/Room Volume";
customBlkPath.extWall = "buildingEnergy_lib/Wall External";
customBlkPath.selectWall = "buildingEnergy_lib/Wall Selector";
customBlkPath.roomRadUFP = "buildingEnergyComposite/Room, Radiator, and Under-floor Piping";
customBlkPath.roomRad = "buildingEnergyComposite/Room with Radiator";
customBlkPath.roomUFP = "buildingEnergyComposite/Room with Under-floor Piping";
customBlkPath.roomOnly = "buildingEnergyComposite/Room with Air Volume";
customBlkPath.solar = "buildingEnergy_lib/Solar Radiation (LUT)";
customBlkPath.thermal = "buildingEnergy_lib/Temperature Source (LUT)";
customBlkPath.heatSourceControl = "buildingEnergyComposite/Heat Source Control";
customBlkPath.dailyScheduler = "buildingEnergy_lib/Day Scheduler";
customBlkPath.heatPumpTL = "buildingEnergyComposite/Air Water Heat Pump (TL)";

%% Define product library path
libBlkPath.thermalRes = "fl_lib/Thermal/Thermal Elements/Thermal Resistance";
libBlkPath.arrayConn = "nesl_utility/Array Connection";
libBlkPath.labelConn = "nesl_utility/Connection Label";
libBlkPath.connPort = "nesl_utility/Connection Port";
libBlkPath.concatPS = "fl_lib/Physical Signals/Functions/PS Concatenate";
libBlkPath.selectorPS = "fl_lib/Physical Signals/Nonlinear Operators/PS Selector";
libBlkPath.gainBlock = "fl_lib/Physical Signals/Functions/PS Gain";
libBlkPath.convHeatTransfer = "fl_lib/Thermal/Thermal Elements/Convective Heat Transfer";
libBlkPath.insulator = "fl_lib/Thermal/Thermal Elements/Perfect Insulator";
libBlkPath.addition = "fl_lib/Physical Signals/Functions/PS Add";
libBlkPath.pipe = "fl_lib/Thermal Liquid/Elements/Pipe (TL)";
libBlkPath.temperature = "fl_lib/Thermal/Thermal Sources/Temperature Source";