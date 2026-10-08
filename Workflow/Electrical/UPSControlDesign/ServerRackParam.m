% ServerRackParam - PDU Racks parameters for UPSControl.slx
%
% Defines the "rack" struct consumed by the mask of
%   Server Load/Server Racks/PDU Racks
% and by the Efficiency Gain block that sits in the load path between
% PDU Racks and the Custom Dynamic Load (3-phase) block.
%
% Field names match the mask parameter names one-for-one, so a mask entry
% reads simply "rack.<maskParamName>". This mirrors RackParam.m in
% HyperscaleSSTDesign, and the tray definition below is deliberately
% identical to it, so both examples describe the same IT hardware.
%
% Run before simulating; called from DataCenterParam.m.

% Copyright 2026 The MathWorks, Inc.

%% Rack / tray counts
% nRacks sizes the load group for this example. The UPS example is built
% around loadPower at utilizationFactor, and 5 racks of 144 trays land on
% that figure once the load-path trim below is applied.
%
% nRacks is also the lever for studies that need more load, such as the N+1
% redundancy case in RedundancyAnalysis.m. PDU Racks multiplies one
% representative tray by nTrays*nRacks, so power is exactly linear in nRacks
% and the tray temperatures do not move. Do not reach for utilizationFactor
% instead: the Server Chip power curves saturate near full utilization, so
% these 5 racks top out near 8.4 MW no matter how hard they are driven.
rack.nTrays = 144;                  % Server trays per rack (1)
rack.nRacks = 5;                    % Racks in this load group (1)

%% Tray thermal
% Deliberately written as a rack-aggregate figure scaled by nTrays so the
% aggregate-vs-per-unit intent stays visible: trayMass is one tray's share
% of an 80 kg rack, trayThermalR scales the 1.11e-05 K/W rack-level
% resistance up to the per-tray value.
rack.trayMass     = 80/rack.nTrays;         % Tray thermal mass (kg)
rack.trayCp       = 500;                    % Tray specific heat (J/(kg*K))
rack.trayThermalR = 1.11e-05*rack.nTrays;   % Tray-to-ambient thermal resistance (K/W)

%% GPU
rack.nGPU           = 4;            % GPU dies per tray (1)
rack.gpuTDPperDie   = 2500;         % GPU TDP per die (W)
rack.gpuIdlePower   = 375;          % GPU idle power per die (W)
rack.gpuHBMpower    = 80;           % HBM power per GPU (W)
rack.gpuExponent    = 1.4;          % Fan/Barroso power-utilization exponent (1)
rack.gpuHBMutil     = 0.7;          % HBM utilization as a fraction of compute utilization (1)
rack.gpuLeakage     = 1.5;          % Leakage power increase per K above nominal (W/K)
rack.gpuNominalDieT = 350;          % Nominal die temperature for the leakage term (K)
rack.gpuDieThermalC = 28800;        % GPU die thermal capacitance (J/K)
rack.gpuHeatSinkR   = 3.4722e-05;   % GPU die-to-heatsink thermal resistance (K/W)
rack.gpuSurfArea    = 0.01;         % GPU convective surface area per die (m^2)
rack.gpuAmbientR    = 0.5;          % GPU-to-ambient thermal resistance (K/W)

%% CPU
rack.nCPU            = 2;           % CPU sockets per tray (1)
rack.cpuTDPperSocket = 250;         % CPU TDP per socket (W)
rack.cpuIdlePower    = 75;          % CPU idle power per socket (W)
rack.cpuExponent     = 1.1;         % Fan/Barroso power-utilization exponent (1)
rack.cpuLeakage      = 1.5;         % Leakage power increase per K above nominal (W/K)
rack.cpuNominalDieT  = 350;         % Nominal die temperature for the leakage term (K)
rack.cpuDieThermalC  = 14400;       % CPU die thermal capacitance (J/K)
rack.cpuHeatSinkR    = 6.9444e-05;  % CPU die-to-heatsink thermal resistance (K/W)
rack.cpuSurfArea     = 0.01;        % CPU convective surface area per socket (m^2)
rack.cpuAmbientR     = 0.5;         % CPU-to-ambient thermal resistance (K/W)

%% Ambient / initial conditions
rack.initialT = 308.15;             % Initial die and tray temperature (K), 35 degC
rack.htc      = 10;                 % Convective heat transfer coefficient (W/(m^2*K))

%% Load-path calibration
% Trim that makes PDU Racks draw the same power as the four Datacenter
% Server Unit blocks it replaced. This is a calibration factor, not a
% physical efficiency: it is a least-squares fit over the utilization range
% that the token rate profile sweeps, so changing any count, TDP or the
% token rate profile invalidates it and it must be re-derived from an A/B
% run against the Datacenter Server Unit model.
rack.efficiencyGain = 1.087718;     % PDU Racks load-path trim (1)
