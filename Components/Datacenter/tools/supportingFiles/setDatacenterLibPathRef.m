% Specify library and custom library paths.
% 
% Copyright 2025 - 2026 The MathWorks, Inc.

%% Define custom library path
customBlkPath.datacenter = 'datacenter_lib/Datacenter Server Unit';
customBlkPath.load3ph = 'datacenter_lib/Custom Dynamic Load (3-phase) block';
customBlkPath.roomVol = 'buildingEnergy_lib/Room Volume';
customBlkPath.extWall = 'buildingEnergy_lib/Wall External';
customBlkPath.selectWall = 'buildingEnergy_lib/Wall Selector';

%% Define product library path
libBlkPath.thermalRes = 'fl_lib/Thermal/Thermal Elements/Thermal Resistance';
libBlkPath.arrayConn = 'nesl_utility/Array Connection';
libBlkPath.connPort = 'nesl_utility/Connection Port';
libBlkPath.concatPS = 'fl_lib/Physical Signals/Functions/PS Concatenate';
libBlkPath.selectorPS = 'fl_lib/Physical Signals/Nonlinear Operators/PS Selector';
libBlkPath.dynLoad3ph = 'ee_lib/Passive/Dynamic Load (Three-Phase)';
libBlkPath.gainBlock = 'fl_lib/Physical Signals/Functions/PS Gain';
libBlkPath.convHeatTransfer = 'fl_lib/Thermal/Thermal Elements/Convective Heat Transfer';
libBlkPath.insulator = 'fl_lib/Thermal/Thermal Elements/Perfect Insulator';