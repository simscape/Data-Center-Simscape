%% PDU + CDU Assembly (LUT)

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImagePDUCDULUTAssembly.png>>
% 
% This block combines the *PDU Racks*, *CDU (LUT)* blocks and uses the
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
% * *Number of racks (-)*, |nRacks|, specified as a scalar value.
% * *Number of IT trays per rack (-)*, |nTrays|, specified as a scalar value.

%% CDU
% * *Coolant volumetric flowrate vector (m^3/s)*, |flowrate_vec|, specified as a vector value.
% * *Heat exchanger capacity vector (W)*, |capacity_vec|, specified as a vector value.
% * *Total number of pumps in each assembly (-)*, |numPump|, specified as a scalar value.
% * *Pump efficiency vector, 0-1 (-)*, |effPump_vec|, specified as a vector value.
% * *Pressure drop (Pa)*, |prDrop_mat|, specified as a matrix.
% * *Pump speed scaling (-)*, |speed|, specified as a scalar value.

%% IT Tray
% * *Tray mass (kg)*, |trayMass|, specified as a scalar value.
% * *Tray specific heat capacity (J/kg*K)*, |trayCp|, specified as a scalar value.
% * *Tray to external thermal resistance (K/W)*, |trayThermalR|, specified as a scalar value.

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
% * *Heat transfer coefficient to ambient (W/m^2.K)*, |htc|, specified as a scalar value.

