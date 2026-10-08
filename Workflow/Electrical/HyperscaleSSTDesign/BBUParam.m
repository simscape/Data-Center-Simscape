% BBUParam - Hybrid BBU Parameter File
% Parameters for the Battery + Supercapacitor Backup Unit on 800V DC bus
% Supercapacitor handles ms-range transients, battery handles sec-range sustained dips
%
% Deadzones are sized so the BBU remains silent during normal DAB-regulated
% operation (Cases 1-5) and only activates during island/fault events.
% Sign convention: negative Iref = discharge (source current to bus).
% Both battery and supercap are clamped to discharge-only (Iref <= 0).

% Copyright 2026 The MathWorks, Inc.

%% Detection & Activation
Ts = 50e-6;                         % Controller sample time (s)
tau = 0.005;                        % Complementary filter time constant (s)
bbu.detectionDelay = 2e-3;          % Fault detection delay (s) - breaker-open to BBU activation

%% Supercapacitor (HPF path — fast transient response)

bbu.scap.deadZone = 60;            % Dead zone (V) - silent during normal DAB-regulated operation
bbu.scap.lpfAlpha = exp(-Ts/tau);  % LPF coefficient for complementary split (~0.999667)
bbu.scap.Kp = 150;                  % Proportional gain (A/V beyond dead zone)
bbu.scap.Imax = 12000;             % Current limit (A) - burst rating
bbu.scap.capacitance = 5;          % Capacitance (F)
bbu.scap.ESR = 1e-6;               % ESR (Ohm)

%% Battery (LPF path — steady-state authority)
bbu.batt.deadZone = 60;            % Dead zone (V) - silent during normal operation
bbu.batt.lpfAlpha = exp(-Ts/tau);  % LPF coefficient for complementary split
bbu.batt.Kp_ctrl = 200;            % PI proportional gain
bbu.batt.Ki_ctrl = 2000;           % PI integral gain
bbu.batt.Imax = 10000;             % Current limit (A) - island sustained rating
bbu.batt.Vnom = 800;               % Nominal battery voltage (V)
bbu.batt.R1 = 0.004;              % Internal resistance (Ohm)
