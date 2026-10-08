% BESS Parameter File
% Parameters for the Battery Energy Storage System connected to 800V DC bus

% Copyright 2026 The MathWorks, Inc.

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
