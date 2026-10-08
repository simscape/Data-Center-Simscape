% HyperscalarDataCenter Parameter File
% Parameters for the Battery Energy Storage System connected to 800V DC bus
% Run this before simulating HyperscalarDataCenter.slx

% Copyright 2026 The MathWorks, Inc.
%DataCenterParam;
%% Battery
vBattMax = 420;             % Maximum battery voltage (V)

%% DC Bus
baseVoltageDC = 800;        % Rated DC bus voltage (V)
vDCThreshold = 850;         % DC bus overvoltage threshold (V)

%% DC-DC Converter Controller
kpDC = 1;                   % Proportional gain
kiDC = 50;                  % Integral gain
iBatt = 100;                % Maximum battery current (A)
droopGain = 0.02;           % Voltage droop coefficient

%% Mode Control / BMS
vGridMin = 5;               % Current threshold for mode switching (A)
initialMode = 1;            % Initial operating mode (1 = standby)

%% Peak Shaving Controller
peakShavingPowerLimit = 800e3;  % Grid power threshold (W) - battery activates above this
Prated_batt = 40e3;             % Battery rated power for pu normalization (W)
tauPS = 0.1;                    % Low-pass filter time constant (s)
Ts_PS = 1e-3;                   % Controller sample time (s)

%% Load Step Event (GPU burst synchronization)
loadStep.time = 0.3;              % Step time (s) - after SST reaches steady state
loadStep.initialUtil = 0.45;      % Steady-state utilization
loadStep.finalUtil = 0.95;        % Post-step utilization (near TDP)
loadStep.riseTime = 1e-4;         % Rise time (s) - faster than IT tray tau_response

% %% Server Load (Rubin Ultra NVL576 rack)
% nGPU = 576;                     % GPU dies per tray
% nCPU = 2;                       % CPU sockets per tray
% gpuTDPperDie = 2500;            % GPU TDP per die (W)
% gpuIdlePower = 375;             % GPU idle power per die (W)
% gpuExponent = 1.4;              % Fan/Barroso power-utilization exponent
% gpuHBMpower = 80;               % HBM power per GPU (W)
% gpuHBMutil = 0.7;               % HBM util as fraction of compute util
% cpuTDPperSocket = 350;          % CPU TDP per socket (W)
% cpuIdlePower = 80;              % CPU idle power per socket (W)
% gpuLeakage = 1.5;               % Leakage increase per K above T_nom (W/K)
% gpuNominalDieT = 350;           % Nominal die temperature (K)
% gpuDieThermalC = 50;            % Die thermal capacitance per die (J/K)
% gpuHeatSinkR = 0.15;            % Die-to-heatsink thermal resistance per die (K/W)
% initialT = 350;                 % Initial die temperature (K)

%% PDU Racks Parameters
RackParam;

%% SST Parameters
SSTParam;

%% Hybrid BBU Parameters
BBUParam;

%% UPS BESS Parameters
UPSParam;
UPSBESSParam;
SSTBESSParam;

%% Other Parameters
grid.voltage = 132000;
grid.frequency = 60;
lineResistance = 1e-3;
lineInductance = 1e-6;
powerTau = 0.005;
Ts = 5e-5;

%% LVRT Profile (Grid Voltage)
lvrtGridCode = sstLvrt.getProfile('None');
lvrt.startTime = 10;
lvrtProfile = sstLvrt.buildProfile(lvrtGridCode, Ts, 10, lvrt.startTime);