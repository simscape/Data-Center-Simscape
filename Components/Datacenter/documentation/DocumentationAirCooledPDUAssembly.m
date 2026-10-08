%% Air Cooled PDU Assembly

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImageAirCooledPDUAssembly.png>>
% 
% Use this block to design air cooled data centers. This composite block 
% models *PDU Racks* with *Rack Air Cooling* block. *Thermal Multiplier* 
% block is used to scale up the data center rating to the desired levels.

%% PDU Racks
% * *Number of PDU + Fan assemblies (-)*, |nAssembly|, specified as a scalar value.
% * *Number of racks per PDU (-)*, |nRacks|, specified as a scalar value.
% * *Number of IT trays per rack (-)*, |nTrays|, specified as a scalar value.

%% Fans
% * *Number of fans per assembly (-)*, |nFans|, specified as a scalar value.
% * *Fan flow rate vector (m^3/s)*, |flowVec|, specified as a scalar value.
% * *Fan pressure drop vector (Pa)*, |prDropVec|, specified as a scalar value.
% * *Fan efficiency vector, 0-1 (-)*, |fanEffVec|, specified as a scalar value.
% * *Fan assembly area with racks (m^2)*, |fanAreaTotal|, specified as a scalar value.
% * *Heat transfer coefficient to ambient (W/m^2.K)*, |fanHTC|, specified as a scalar value.

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

