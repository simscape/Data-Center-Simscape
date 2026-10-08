% DataCenterBBU Parameter File
% Battery Backup Unit for 800V DC datacenter rack (5 MW)
%
% Architecture:
%   Active supercap BDC (400V bank → boost to 800V bus, washout filter, no deadband)
%   Battery with droop-gated BDC (750V pack, activates when Vdc exits ±5V deadband)
%   Handoff: supercap responds first (washout peak), battery responds second (droop gate)
%   No state machine — voltage levels + temporal filtering encode priority.
%
% Copyright 2026 The MathWorks, Inc.

%% DC Bus
baseVoltageDC = 800;            % Rated DC bus voltage (V)
dcBusCapacitance = 50e-3;       % DC bus link capacitance (F)

%% Supercapacitor Bank (active BDC, 400V nominal)
% 150S x 8P, 2.7V/3000F cells → 5.33F at 405V, 424 kJ stored
% Swings 400→200V during discharge (extracts 75% energy)
% Rated for ~2.5MW peak (bridges first 500ms until battery ramps)
scCapacitance = 5.33;           % Pack equivalent capacitance (F)
scInitVoltage = 400;            % Initial supercap voltage (V)
scESR = 0.005;                  % Pack ESR (Ohm)
scEnergy_kJ = 0.5 * scCapacitance * scInitVoltage^2 / 1000; % 426 kJ

% Supercap BDC Controller (washout filter — transient-only response)
% H(z) = K*(1-z^-1) / (1 - (1-Ts/tau)*z^-1)
% Responds instantly to voltage dip, then decays with time constant tau.
% Discharge only (Iref clamped ≥ 0). ±1V deadband on error input.
scWashoutK = 150;               % Washout gain (A/V at peak)
scWashoutTau = 0.5;             % Washout time constant (s)
scDeadband = 1;                 % Error deadband half-width (V)
irefMaxSC = 4000;               % Max discharge Iref (A) → ~2.5MW from 400V supercap
irefMinSC = 0;                  % Min Iref (A) → discharge only, no charge via washout

%% Battery (750V source with internal resistance)
% Sustains full 5MW load after supercap bridge period
% Power: 750V × 6211A ≈ 4.7MW (steady state with load at 795V bus)
vBattNom = 750;                 % Nominal battery voltage (V)
battR = 0.05;                   % Battery internal resistance (Ohm)

% Battery BDC Controller (PI with droop gate — activates after supercap)
droopDeadband = 5;              % Deadband half-width (V): battery idle at 795-805V
kpBatt = 80;                    % Proportional gain (fast ramp after deadband)
kiBatt = 400;                   % Integral gain (eliminates offset within deadband)
irefMax = 7500;                 % Max discharge Iref (A) → 5.6MW from 750V battery
irefMin = -1000;                % Max charge Iref (A)

%% Grid Feed (represents SST output or utility)
gridVoltage = 800;              % Grid output voltage (V)

%% Server Load (5 MW rack)
serverPower = 5e6;              % Server load power (W)
serverR = baseVoltageDC^2 / serverPower; % Load resistance (Ohm) = 0.128

%% Simulation
Ts = 5e-5;                      % Sample time (s)

%% Display summary
fprintf('=== DataCenterBBU Parameters (5 MW) ===\n');
fprintf('DC Bus: %dV, Cap=%.0f mF\n', baseVoltageDC, dcBusCapacitance*1e3);
fprintf('Supercap (washout BDC): %.2fF at %dV (%.0f kJ), K=%d, tau=%.1fs, Iref=[%d,%d] A\n', ...
    scCapacitance, scInitVoltage, scEnergy_kJ, scWashoutK, scWashoutTau, irefMinSC, irefMaxSC);
fprintf('Battery: %dV, Kp=%d Ki=%d, Iref=[%d,%d] A (%.1f MW max)\n', ...
    vBattNom, kpBatt, kiBatt, irefMin, irefMax, vBattNom*irefMax*0.9/1e6);
fprintf('Droop gate: +/-%dV deadband (battery idle at %d-%dV)\n', ...
    droopDeadband, baseVoltageDC-droopDeadband, baseVoltageDC+droopDeadband);
fprintf('Server Load: %.1f MW (R=%.3f Ohm)\n', serverPower/1e6, serverR);
