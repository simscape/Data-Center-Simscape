% Copyright 2026 The MathWorks, Inc.

%% UPS Parameters (defines ups.* struct)
UPSParamStability;

%% === WORKSPACE VARIABLES FOR UPS BLOCK ===
baseVoltageDC       = ups.Vdc;
frequency           = ups.frequency;
Vac                 = ups.Vac;
plantRating         = ups.rating;
capacitance         = ups.DCBus.capacitance;
kpDC                = ups.DCBus.kpDC;
kiDC                = ups.DCBus.kiDC;
filterInductance    = ups.inverter.filterInductance;
filterResistance    = ups.inverter.filterResistance;
invKpVd             = ups.inverter.kpVd;
invKiVd             = ups.inverter.kiVd;
invKpId             = ups.inverter.kpId;
invKiId             = ups.inverter.kiId;
filterInductanceAFE = ups.AFE.filterInductance;
filterResistanceAFE = ups.AFE.filterResistance;
vBattMax            = ups.batt.VMax;
vBattNom            = ups.batt.Vnom;
vGridMin            = ups.DCBus.gridThreshold;
vDCThreshold        = ups.DCBus.VThreshold;
initialMode         = ups.batt.initialMode;
iBatt               = ups.batt.iRated;
droopGain           = ups.DCBus.droop;
rampRate            = ups.batt.rampRate;
bessConverterEfficiency = ups.DCBus.converterEff;

%% Generator Parameters
GeneratorParam;

%% === TOPOLOGY PARAMETERS ===
N_total = 400;              % PFC units (400 × 20 kW = 8 MW)
N_pfc = round(N_total * [1/3, 1/3, 1/3]);  % equal rating across all 3 PFC blocks
N_pfc(3) = N_total - N_pfc(1) - N_pfc(2);  % ensure sum == N_total

%% === RACK / TRAY PARAMETERS ===
itRack.numRack = 3;             % IT Load channels (racks) in the model

% Per-tray hardware (single physical server tray: 8 GPUs + 1 CPU)
itTray.nGPU = [8, 8, 8];       % GPUs per tray (same all racks)
itTray.nCPU = [1, 1, 1];       % CPUs per tray
itTray.dcdc.eff = 0.80;
itTray.capacitor = 1e-5;        % F — DC bus capacitor per tray

% Number of server trays per rack (PS Gain1 scales single-tray power)
nTray = 216;                    % 216 trays/rack × 3 racks × 8 GPU/tray = 5184 GPUs

% DC-DC converter P_rated per rack (W) — handles full rack power
itTray.dcdc.P_rated = nTray * itTray.nGPU * 1200;   % [2.07 MW per rack]

%% === WORKSPACE VARIABLES FOR COMPUTE PROFILE SOURCE ===
numGPUs = nTray * itRack.numRack * itTray.nGPU(1);  % 5184 total GPUs
Ngpu    = numGPUs;

%% === SERVER TRAY PARAMETERS (per-GPU base values) ===
serverTray.gpuTDPperDie   = 1200;       % W
serverTray.gpuIdlePower   = 300;        % W
serverTray.gpuHBMpower    = 80;         % W
serverTray.gpuExponent    = 1.4;
serverTray.gpuHBMutil     = 0.7;
serverTray.gpuLeakage     = 0.05;
serverTray.gpuNominalDieT = 350;        % K
serverTray.gpuDieThermalC_perGPU = 1e6;  % J/K per GPU (large → freeze die temp for stability study)
serverTray.gpuHeatSinkR_perGPU   = 1e6;  % K/W per GPU (insulate — no heat leaves die to network)
serverTray.gpuSurfArea_perGPU    = 0.01;  % m² per GPU
serverTray.gpuAmbientR_perGPU    = 1e6;   % K/W per GPU (insulate ambient path)
%% === SERVER TRAY PARAMETERS (per-CPU base values) ===
serverTray.cpuTDPperSocket   = 350;     % W
serverTray.cpuIdlePower      = 80;      % W
serverTray.cpuExponent       = 1.1;
serverTray.cpuLeakage        = 0.05;
serverTray.cpuNominalDieT    = 350;     % K
serverTray.cpuDieThermalC_perCPU = 1e6;  % J/K per CPU (large → freeze die temp)
serverTray.cpuHeatSinkR_perCPU   = 1e6;  % K/W per CPU (insulate)
serverTray.cpuSurfArea_perCPU    = 0.01;  % m² per CPU
serverTray.cpuAmbientR_perCPU    = 1e6;   % K/W per CPU (insulate)

serverTray.trayMass       = 50;         % kg
serverTray.trayCp         = 2000;       % J/(kg·K)
serverTray.trayThermalR_perGPU = 1e6;   % K/W per GPU (insulate — Hc port unconnected)
serverTray.initialT       = 298.15;     % K — ambient (room temperature)
serverTray.htc            = 10;         % W/(m²·K)

%% === PFC PARAMETERS (per-unit base values, scaled by N_pfc in block masks) ===
pfc.Kp      = 200;         % W/V — proportional gain (single unit)
pfc.Ki      = 600;         % W/(V·s) — integral gain
pfc.C_dc    = 0.03;        % F — DC bus capacitance (30 mF)
pfc.G_damp  = 0.002;       % S — parallel damping conductance (loss < 5%)
pfc.P_max   = 0.02;        % MW — power rating per unit (20 kW)
pfc.V_dc_ref = 400;        % V — DC bus setpoint
pfc.L_ac    = 0.5e-3;      % H — AC boost inductor
pfc.R_ac    = 0.01;        % Ohm — inductor ESR
pfc.tau_rms = 0.040;       % s — RMS voltage filter time constant
pfc.V_nom   = 480;         % V — nominal AC voltage
pfc.eta     = 0.97;        % efficiency

% PFC block masks use workspace expressions:
%   PFC A (k=1):  Kp_pfc = "N_pfc(1) * pfc.Kp"
%   PFC B (k=2):  Kp_pfc = "N_pfc(2) * pfc.Kp"
%   PFC C (k=3):  Kp_pfc = "N_pfc(3) * pfc.Kp"

%% === CABLE PARAMETERS ===
lineResistance = 1e-3;      % Ohm
lineInductance = 1e-6;      % H

%% === GRID / UTILITY PARAMETERS ===
grid.voltage   = 480;       % V LL
grid.frequency = 60;        % Hz

%% === COMPUTE PROFILE SOURCE PARAMETERS ===
computeProfile.numGPUs      = numGPUs;
computeProfile.gpuModel     = 'GPUModel.B200';
computeProfile.workloadType = 'WorkloadType.Training';
computeProfile.timeScale    = 1;                          % real-time (no compression)
computeProfile.llmSize      = 'LLMModelSize.Llama_70B';
computeProfile.parallelism  = 'ParallelismStrategy.Custom';
computeProfile.customTP     = 8;
computeProfile.customPP     = 2;
computeProfile.microBatch   = 8;
computeProfile.globalBatch  = 16384;
computeProfile.seqLength    = 1350;
computeProfile.idleUtil     = 0.55;
computeProfile.fwdUtil      = 0.92;
computeProfile.bwdUtil      = 0.98;
computeProfile.commSyncUtil = 0.55;
computeProfile.MFU          = 0.85;
computeProfile.checkpointOverhead = 0.05;
computeProfile.stragglerOverhead  = 0.03;
computeProfile.enableNoise        = true;
computeProfile.noiseAmplitude     = 0.05;
computeProfile.stepJitter         = 0.0;
computeProfile.enableFilter       = true;
computeProfile.filterTimeConstant = 0.05;

%% === LOAD PATH GAINS ===
G1 = 1;   % Compute profile path (1 = active)
G2 = 0;   % PS Constant path (1 = active)

%% === SCAN BLOCK DEFAULTS (PRBS disabled — perturbation starts after sim) ===
scan.Vd = 0;
scan.Vq = 0;
scan.Vdc = 0;
scan.f = logspace(log10(0.1), log10(500), 50);
scan.samplingfrequency = 10000;
scan.start = 100;
scan.end = 200;

%% === OTHER PARAMETERS ===
powerTau = 0.005;
Ts = 5e-5;

% Sag parameters
sag.voltage   = 0.5;
sag.startTime = 50;
sag.endTime   = 55;

% Breaker parameters
breaker.grid      = 40;
breaker.generator = 45;
breaker.UPS       = 5;

% Load parameters
loadPower         = 8e6;        % W — 8 MW facility
utilizationFactor = 0.45;
upsConfig         = 1;          % 1 = Single UPS

% LVRT parameters
lvrt.startTime = 3;
parasiticConductance = 1e-5;

%% Token Rate Profile (Server Utilization)
tokenRateWaypoints.time     = [0.0, 0.5, 2.0, 3.5, 5.0, 6.5, 8.0, 9.2, 10.0];
tokenRateWaypoints.rate     = [0.60, 0.60, 0.60, 0.60, 0.60, 0.60, 0.60, 0.60, 0.60];
tokenRateWaypoints.riseTime = 0.15;
tokenRateProfile = buildTokenRateProfile(tokenRateWaypoints, Ts, 10);

%% LVRT Profile (Grid Voltage)
lvrtGridCode = lvrtTest.getLVRTProfile('None');
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtGridCode, Ts, 10, lvrt.startTime);

if exist('Stateflow.disableInstrumentation','class')
    Stateflow.disableInstrumentation(true);
end
