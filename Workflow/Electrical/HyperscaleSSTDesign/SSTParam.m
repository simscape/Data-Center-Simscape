% SST Parameter File
% Parameters for the Solid State Transformer (CHB-DAB topology)

% Copyright 2026 The MathWorks, Inc.

%% General
sst.inputVoltage = 13800;          % Input voltage - phase to phase RMS (V)
sst.dcOutputVoltage = 800;         % DC output voltage (V)
sst.frequency = 60;                % Grid frequency (Hz)

%% CHB (Cascaded H-Bridge)
sst.chb.numModules = 3;            % Number of H-bridge modules per phase
sst.chb.dcBusVoltage = 4400;       % DC bus voltage per module (V)
sst.chb.dcBusCapacitance = 5e-3;   % DC bus capacitance per module (F)
sst.chb.Ron = 1e-3;                % On-state resistance per module (Ohm)
sst.chb.Vdc_init = sst.chb.dcBusVoltage; % Initial DC bus voltage per module (V)
sst.chb.Vdc_total = sst.chb.numModules * sst.chb.dcBusVoltage; % Total DC voltage per phase (V)
sst.chb.V_grid = sst.inputVoltage; % Nominal grid voltage L-L RMS for modulation scaling (V)
sst.chb.modulationScale = 1; % Gain_mod_scale = 1 (internal scaling in custom.chb_module handles modulation)
sst.chb.Kbal = 1.0 / sst.chb.dcBusVoltage; % Vertical balancing gain with sign(m)

%% Filter
sst.filter.inductance = 10e-3;     % Filter inductance (H)
sst.filter.resistance = 0.1;       % Filter resistance (Ohm)

%% DAB (Dual Active Bridge)
sst.dab.turnsRatio = 5.5;          % Transformer turns ratio (N = Vpri/Vsec)
sst.dab.primaryLeakageInductance = 34e-6;  % Primary leakage inductance L1 (H)
sst.dab.secondaryLeakageInductance = 1.12e-6; % Secondary leakage inductance L2 (H)
sst.dab.windingResistance = 5e-3;  % Equivalent winding + switch resistance (Ohm)
sst.dab.outputCapacitance = 1e-3;  % Output capacitance per module (F)
sst.dab.switchingFrequency = 20000;% Switching frequency (Hz)
sst.dab.includeESR = false;        % Include capacitor ESR in model
sst.dab.capacitorESR = 0.25;       % Capacitor ESR (Ohm) - used only if includeESR=true

% DAB Initial Conditions
sst.dab.vo0_init = sst.dcOutputVoltage; % Initial output voltage (V)
sst.dab.it1R_init = 0;             % Initial transformer current real part (A)
sst.dab.it1I_init = 0;             % Initial transformer current imaginary part (A)

%% DAB Voltage Controller (PI)
sst.dab.kp = 5.5;                  % Proportional gain (tuned for OCP +/-3% dynamic regulation)
sst.dab.ki = 130;                  % Integral gain (tuned for OCP +/-3% dynamic regulation)
sst.dab.upperLimit = 0.45;         % Phase shift upper limit
sst.dab.lowerLimit = -0.45;        % Phase shift lower limit
sst.dab.sampleTime = 50e-6;        % Controller sample time (s)
sst.dab.Kp_bal = 5e-4;             % DAB inter-phase balancing gain (V^-1) — applied through ZOH(2ms) + Saturation(±0.02)
sst.dab.bal_fc = 0.15;             % Balancing LPF cutoff frequency (Hz) — must be below closed-loop resonance (~4Hz)
sst.dab.bal_Ts = 2e-3;             % Balancing ZOH/LPF sample time (s)
sst.dab.bal_alpha = exp(-2*pi*sst.dab.bal_fc*sst.dab.bal_Ts); % LPF coefficient

%% PFC Rectifier Controller
sst.pfc.frequency = 60;            % System frequency (Hz)
sst.pfc.filterInductance = 10e-3;  % AC filter inductance (H)
sst.pfc.SRated = 20e6;             % Sensor rated power (VA) — must match baseImpedance
sst.pfc.baseImpedance = 9.522;     % AC side base impedance (Ohm) — V_LL²/SRated
sst.pfc.sampleTime = 5e-5;         % Sample time (s)
sst.pfc.baseVdc = sst.chb.dcBusVoltage; % DC bus base voltage (V)

% PLL
sst.pfc.kpPLL = 15;                % PLL proportional gain
sst.pfc.kiPLL = 100;               % PLL integral gain

% Voltage Controller
sst.pfc.kpVoltage = 18;            % Voltage controller proportional gain
sst.pfc.kiVoltage = 500;           % Voltage controller integral gain
sst.pfc.kdVoltage = 0;             % Voltage controller derivative gain
sst.pfc.NdVoltage = 100;           % Voltage controller derivative filter coefficient
sst.pfc.voltageUpperLimit = 1;     % Voltage controller output upper limit (pu)
sst.pfc.voltageLowerLimit = -1;    % Voltage controller output lower limit (pu)

% Id Current Controller
sst.pfc.kpId = 10;                 % Id proportional gain
sst.pfc.kiId = 200;                % Id integral gain
sst.pfc.kdId = 0;                  % Id derivative gain
sst.pfc.IdUpperLimit = 1;          % Id controller output upper limit (pu)
sst.pfc.IdLowerLimit = -1;         % Id controller output lower limit (pu)

% Iq Current Controller
sst.pfc.kpIq = 10;                 % Iq proportional gain
sst.pfc.kiIq = 200;                % Iq integral gain
sst.pfc.kdIq = 0;                  % Iq derivative gain
sst.pfc.NdCurrent = 100;           % Current controller derivative filter coefficient
sst.pfc.IqUpperLimit = 1;          % Iq controller output upper limit (pu)
sst.pfc.IqLowerLimit = -1;         % Iq controller output lower limit (pu)
