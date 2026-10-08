% SST BESS Parameter File
% Parameters for the Battery Energy Storage System in HyperscaleDataCenterLVRT
% Tuned for ERCOT Ascending LVRT with mixed Training+Inference load profile

% Copyright 2026 The MathWorks, Inc.

%% Battery
bess.battery.Vnom = 400;                % Nominal battery voltage (V)
bess.battery.R1 = 1e-3;                 % Internal resistance (Ohm)
bess.battery.capacity = 50;             % Capacity (Ah) - infinite mode in model

%% DC Bus Reference
bess.dcBus.voltage = 800;               % Rated DC bus voltage (V)
bess.dcBus.Voref = 1.0;                 % Per-unit voltage reference

%% DC-DC Converter Controller
bess.controller.Kp = 30;                % PID proportional gain
bess.controller.Ki = 1000;              % PID integral gain
bess.controller.gain = 18750;           % Current scaling gain (sized for 15 MW rating)
bess.controller.saturationUpper = 0;    % Saturation upper limit (A)
bess.controller.saturationLower = -40000; % Saturation lower limit (A)
bess.controller.lpfTimeConstant = 0.0001; % Low-pass filter time constant (s)
bess.controller.lpfGain = 1;            % Low-pass filter gain

%% Droop Mode
bess.droop.gain = 50;                   % Droop proportional gain
bess.droop.saturationUpper = 0;         % Droop output upper limit
bess.droop.saturationLower = -100;      % Droop output lower limit

%% Mode Control Thresholds
bess.mode.dischargeThreshold = 0.95;    % Vac (pu) above which BESS goes to standby
bess.mode.droopThreshold = 0.5;         % Vac (pu) below which BESS uses full PID control
bess.mode.startupDelay = 0.1;           % Time before BESS activates (s)

% Operating modes:
%   Vac <= 0.5:           Mode 0 - Full PID bus voltage control (BESS carries load)
%   0.5 < Vac <= 0.95:   Mode 1 - Droop support (BESS supplements DAB/SST)
%   Vac > 0.95:          Standby (DischargeFlag = 0, BESS inactive)

%% Bidirectional DC-DC Converter
bess.converter.efficiency = 100;        % Converter efficiency (%)

%% Assign to workspace for model compatibility
bess_Kp = bess.controller.Kp;
bess_Ki = bess.controller.Ki;
droopGain = 0.02;%bess.droop.gain;
