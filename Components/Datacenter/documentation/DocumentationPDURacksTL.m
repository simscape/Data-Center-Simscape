%% PDU Racks (TL)

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImagePDURacksTL.png>>
% 
% PDU racks are modeled from *Server Tray (TL)* component and scaling up values,
% using *Thermal Multiplier* and *Flow Multiplier*, to account for total 
% number of trays in a rack, as well as the number of racks. Thermal node 
% *H* specifies the server tray heat transfer to ambient. The Thermal Liquid 
% nodes *A* and *B* specify the heat transfer path to the cooling system. 
% The input ports _U_ are used to specify the GPU and CPU utilization 
% values. The utilization values are set to same for all the tray blocks 
% modeled using the *Thermal Multiplier*. The output port _P_, _Tgpu_, and 
% _Tcpu_ specify the electrical power consumption and temperatures of the 
% GPU and CPU chips on each server tray.

%% PDU Racks
% * *Number of IT trays per rack (-)*, |nTrays|, specified as a scalar value.
% * *Number of racks (-)*, |nRacks|, specified as a scalar value.

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

