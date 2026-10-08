%% PDU + CDU Assembly (TL-TL)

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImagePDUCDUTLTLAssembly.png>>
% 
% This block combines the *PDU Racks (TL)*, *CDU (TL) Detailed* blocks and uses the
% *Thermal Multiplier* to acheive the desired rating for the data center.
% Port name uses and underscore with _gpu_, _cpu_, _pdu_, _cdu_ to specify
% GPU, CPU, PDU, and CDU parameters. Port name starting with _U_ specifies
% the utilization for _gpu_ or the _cpu_. Port name starting with _P_
% specifes the electrical power consumption. Port names _Q_, _N_, _S_
% specify CDU heat removal capacity, number of pumps in CDU, and the speed
% of each pump. Port _T_ specifies the temperature of _gpu_ and _cpu_. The
% Thermal node *H* connects the block to ambient heat transfer path.

%% PDU Racks
% * *Number of PDU+CDU assemblies (-)*, |nAssembly|, specified as a scalar value.
% * *Number of IT trays per rack (-)*, |nTrays|, specified as a scalar value.
% * *Number of racks (-)*, |nRacks|, specified as a scalar value.

%% CDU
% * *Total number of pumps (-)*, |nPumps|, specified as a scalar value.
% * *Pump nominal rating (rpm)*, |pumpNominalRPM|, specified as a scalar value.
% * *Reference capacity vector for each pump (m^3/s)*, |pumpCapacityVec|, specified as a scalar value.
% * *Reference head vector for each pump (m)*, |pumpRefHeadVec|, specified as a scalar value.
% * *Reference brake power vector (kW)*, |pumpRefBrkPowVec|, specified as a scalar value.
% * *Electrical efficiency vector, 0-1 (-)*, |pumpEff|, specified as a scalar value.
% * *Pump speed upper limit factor (-)*, |speedLimFactor|, specified as a scalar value.
% * *Impeller diameter scale factor (-)*, |pumpImpellerDiaFactor|, specified as a scalar value.
% * *External liquid loop mass flow rate vector (kg/s)*, |extFluidMdot|, specified as a scalar value.
% * *External liquid loop pressure drop vector (kPa)*, |extFluidPrDrop|, specified as a scalar value.
% * *External liquid volume in heat exchanger (m^3)*, |extFluidVol|, specified as a scalar value.
% * *External liquid loop pipe cross-sectional area (m^2)*, |extFluidPipeArea|, specified as a scalar value.
% * *Internal liquid loop mass flow rate vector (kg/s)*, |intFluidMdot|, specified as a scalar value.
% * *Internal liquid loop pressure drop vector (kPa)*, |intFluidPrDrop|, specified as a scalar value.
% * *Internal liquid volume in heat exchanger (m^3)*, |intFluidVol|, specified as a scalar value.
% * *Internal liquid loop pipe cross-sectional area (m^2)*, |intFluidPipeArea|, specified as a scalar value.
% * *Reference flow temperature (K)*, |refT|, specified as a scalar value.
% * *Reference flow pressure (MPa)*, |refP|, specified as a scalar value.
% * *Reference density for internal liquid (kg/m^3)*, |refDensity|, specified as a scalar value.

%% IT Tray
% * *Tray mass (kg)*, |trayMass|, specified as a scalar value.
% * *Tray specific heat capacity (J/kg*K)*, |trayCp|, specified as a scalar value.
% * *Tray to external thermal resistance (K/W)*, |trayThermalR|, specified as a scalar value.
% * *Cold plate pipe length (m)*, |pipeLen|, specified as a scalar value.
% * *Cold plate pipe cross-sectional area (m^2)*, |pipeArea|, specified as a scalar value.
% * *Cold plate pipe hydraulic diameter (m)*, |pipeDia|, specified as a scalar value.
% * *Cold plate pipe aggregate equivalent length of local resistances (m)*, |pipeLenXtra|, specified as a scalar value.
% * *Tray to cold plate thermal resistance (K/W)*, |thermalKtc|, specified as a scalar value.

%% GPU
% * *Number of GPU per tray (-)*, |nGPU|, specified as a scalar value.
% * *GPU TDP per die (W)*, |gpuTDPperDie|, specified as a scalar value.
% * *GPU idle power (W)*, |gpuIdlePower|, specified as a scalar value.
% * *HBM power per GPU (W)*, |gpuHBMpower|, specified as a scalar value.
% * *GPU power utilization exponent (-)*, |gpuExponent|, specified as a scalar value.
% * *HBM utilization as fraction of compute utilization (-)*, |gpuHBMutil|, specified as a scalar value.
% * *Leakage increase per K above nominal temperature (W/K)*, |gpuLeakage|, specified as a scalar value.
% * *Nominal die temperature at TDP (K)*, |gpuNominalDieT|, specified as a scalar value.
% * *GPU die thermal capacitance (J/K)*, |gpuDieThermalC|, specified as a scalar value.
% * *GPU die-heat-sink thermal resistance (K/W)*, |gpuHeatSinkR|, specified as a scalar value.
% * *Surface area per die for ambient heat transfer (m^2)*, |gpuSurfArea|, specified as a scalar value.
% * *GPU die-ambient thermal resistance (K/W)*, |gpuAmbientR|, specified as a scalar value.

%% CPU
% * *Number of CPU per tray (-)*, |nCPU|, specified as a scalar value.
% * *CPU TDP per socket (W)*, |cpuTDPperSocket|, specified as a scalar value.
% * *CPU idle power per socket (W)*, |cpuIdlePower|, specified as a scalar value.
% * *CPU power utilization exponent (-)*, |cpuExponent|, specified as a scalar value.
% * *Leakage increase per K above nominal temperature (W/K)*, |cpuLeakage|, specified as a scalar value.
% * *Nominal die temperature at TDP (K)*, |cpuNominalDieT|, specified as a scalar value.
% * *CPU die thermal capacitance (J/K)*, |cpuDieThermalC|, specified as a scalar value.
% * *CPU die-heat-sink thermal resistance (K/W)*, |cpuHeatSinkR|, specified as a scalar value.
% * *Surface area per die for ambient heat transfer (m^2)*, |cpuSurfArea|, specified as a scalar value.
% * *CPU die-ambient thermal resistance (K/W)*, |cpuAmbientR|, specified as a scalar value.

%% Initial Conditions
% * *Initial temperature (K)*, |initialT|, specified as a scalar value.
% * *Initial pressure (MPa)*, |initialP|, specified as a scalar value.
% * *Heat transfer coefficient to ambient (W/m^2.K)*, |htc|, specified as a scalar value.

