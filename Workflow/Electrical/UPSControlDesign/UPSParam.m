% Copyright 2026 The MathWorks, Inc.

ups.rating = 5000;
ups.Vdc = 800;
ups.Vac = 480;
ups.frequency = 60;
ups.sampleTime = 5e-5;

%% Active Front End parameters
ups.AFE.filterResistance = 0.0004;
ups.AFE.filterInductance = 1e-5;
ups.AFE.kpPLL = 15;
ups.AFE.kiPLL = 100;

% Voltage Controller
ups.AFE.kpVoltage = 20;
ups.AFE.kiVoltage = 300;
ups.AFE.kdVoltage = 0;
ups.AFE.voltageUpperLimit = 2;
ups.AFE.voltageLowerLimit = -2;

% Current Controller
ups.AFE.kpId = 0.01;
ups.AFE.kiId = 1;
ups.AFE.kdId = 0;
ups.AFE.IdUpperLimit = 1;
ups.AFE.IdLowerLimit = -1;
ups.AFE.derivativeFilter = 100;
ups.AFE.kpIq = 0.01;
ups.AFE.kiIq = 1;
ups.AFE.kdIq = 0;
ups.AFE.IqUpperLimit = 1;
ups.AFE.IqLowerLimit = -1;

%% DC-Link
ups.batt.Vnom = 400;
ups.batt.iRated = 16000;
ups.batt.VMax = 400;
ups.batt.VMin = 0.01;
ups.batt.initialMode = 3;
ups.batt.rampRate = 50;

ups.DCBus.VThreshold = 200;
ups.DCBus.gridThreshold = 0.01;
ups.DCBus.kpConverter = 5;
ups.DCBus.kiConverter = 20;
ups.DCBus.converterEff = 100;
ups.DCBus.capacitance = 0.8;
ups.DCBus.droop = 20;

%% Inverter
ups.inverter.filterInductance = 1e-6;
ups.inverter.filterResistance = 1e-5;
ups.inverter.fDroop = 0.2;
ups.inverter.vDroop = 0.02;

% Voltage Controller
ups.inverter.kpVd = 0.005;
ups.inverter.kiVd = 100;
ups.inverter.IMaxVd = 1.8;
ups.inverter.IMinVd = -1.8;

ups.inverter.kpVq = 0.005;
ups.inverter.kiVq = 1;
ups.inverter.IMaxVq = 1.8;
ups.inverter.IMinVq = -1.8;

% Current Controller
ups.inverter.kpId = 0.1;
ups.inverter.kiId = 1;
ups.inverter.IMaxId = 1.8;
ups.inverter.IMinId = -1.8;

ups.inverter.kpIq = 0.1;
ups.inverter.kiIq = 1;
ups.inverter.IMaxIq = 1.8;
ups.inverter.IMinIq = -1.8;

% Current Limiting
ups.iLimit.value = 1.2;
ups.iLimit.XByR = 10;
ups.iLimit.resistance = 0.5;