% UPS Parameters for DataCenterStability Study
% 8 MW double-conversion unit (AFE + DC Link + Inverter)
% Tuned for stability assessment (AFE gains optimized for 17 Hz load cycling)

ups.rating = 8000;            % kW (sized for 8 MW facility)
ups.Vdc = 800;                % V DC bus
ups.Vac = 480;                % V AC output
ups.frequency = 60;           % Hz
ups.sampleTime = 5e-5;        % s

%% Active Front End parameters
ups.AFE.filterResistance = 0.0004;   % Ohm
ups.AFE.filterInductance = 1e-5;     % H
ups.AFE.kpPLL = 15;
ups.AFE.kiPLL = 100;

% AFE Voltage Controller (tuned for 8 MW load with ~17 Hz compute cycling)
ups.AFE.kpVoltage = 80;
ups.AFE.kiVoltage = 1200;
ups.AFE.kdVoltage = 0;
ups.AFE.voltageUpperLimit = 2;
ups.AFE.voltageLowerLimit = -2;

% AFE Current Controller
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
ups.batt.Vnom = 400;                % V
ups.batt.iRated = 16000;            % A
ups.batt.VMax = 400;
ups.batt.VMin = 0.01;
ups.batt.initialMode = 3;
ups.batt.rampRate = 50;

ups.DCBus.VThreshold = 200;
ups.DCBus.gridThreshold = 0.01;
ups.DCBus.kpConverter = 5;
ups.DCBus.kiConverter = 20;
ups.DCBus.converterEff = 100;
ups.DCBus.capacitance = 1.6;        % F (sized for ripple rejection at 17 Hz cycling)
ups.DCBus.droop = 20;
ups.DCBus.kpDC = 500;
ups.DCBus.kiDC = 500;

%% Inverter
ups.inverter.filterInductance = 1e-6;    % H
ups.inverter.filterResistance = 1e-5;    % Ohm
ups.inverter.fDroop = 0.2;
ups.inverter.vDroop = 0.02;

% Inverter Voltage Controller
ups.inverter.kpVd = 0.005;
ups.inverter.kiVd = 100;
ups.inverter.IMaxVd = 1.8;
ups.inverter.IMinVd = -1.8;

ups.inverter.kpVq = 0.005;
ups.inverter.kiVq = 1;
ups.inverter.IMaxVq = 1.8;
ups.inverter.IMinVq = -1.8;

% Inverter Current Controller
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
