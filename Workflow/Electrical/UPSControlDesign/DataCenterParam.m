% Copyright 2026 The MathWorks, Inc.

%% UPS Parameters
UPSParam;

%% Generator Parameters
GeneratorParam;

%% Other Parameters
grid.voltage = 132000;
grid.frequency = 60;
lineResistance = 1e-3;
lineInductance = 1e-6;
powerTau = 0.005;
Ts = 5e-5;

% Sag parameters
sag.voltage = 0.5;
sag.startTime = 50;
sag.endTime = 55;

% Breaker parameters
breaker.grid = 40;
breaker.generator = 45;
breaker.UPS = 5;

% Load parameters
loadPower = 5e6;
utilizationFactor = 0.45;
upsConfig = 1;  % 1 = Single UPS, 3 = Three UPS Parallel

% LVRT parameters
lvrt.startTime = 3;
parasiticConductance = 1e-5;

model = "UPSControl";
blockPath = strcat(model,'/','Server Load','/','UPS Units');
set_param(blockPath,'upsConfiguration','Single UPS');

%% Token Rate Profile (Server Utilization)
tokenRateWaypoints.time     = [0.0, 0.5, 2.0, 3.5, 5.0, 6.5, 8.0, 9.2, 10.0];
tokenRateWaypoints.rate     = [0.00, 0.55, 0.80, 0.35, 0.90, 0.60, 0.25, 0.70, 0.70];
tokenRateWaypoints.riseTime = 0.15;
tokenRateProfile = buildTokenRateProfile(tokenRateWaypoints, Ts, 10);

%% LVRT Profile (Grid Voltage)
lvrtGridCode = lvrtTest.getLVRTProfile('None');
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtGridCode, Ts, 10, lvrt.startTime);

