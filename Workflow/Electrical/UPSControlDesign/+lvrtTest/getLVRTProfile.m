function gridCode = getLVRTProfile(codeName)
%GETLVRTPROFILE Return a predefined LVRT grid code definition by name.
%
%   gridCode = lvrtTest.getLVRTProfile(codeName)
%
%   Available grid codes:
%     'None'       - No fault; nominal voltage throughout (normal operation)
%     'ERCOT'      - Electric Reliability Council of Texas
%     'RTEFrance'  - Reseau de Transport d''Electricite (linear ramp recovery)
%     'EirGrid'    - Irish transmission system operator
%     'ATC'        - American Transmission Company
%     'AESO'       - Alberta Electric System Operator
%     'SevereSag'  - Complete voltage loss for 0.5s
%
%   OUTPUT:
%     gridCode - struct with fields: name, faultTime, voltagePu, interpolation
%
%   EXAMPLE - Normal operation (no fault):
%     gridCode = lvrtTest.getLVRTProfile('None');
%
%   EXAMPLE - Define a custom grid code:
%     myCode.name          = 'MyUtility';
%     myCode.faultTime     = [0, 0.15, 0.5, 2.0, 4.0];
%     myCode.voltagePu     = [0.10, 0.40, 0.70, 0.90, 1.0];
%     myCode.interpolation = 'step';

% Copyright 2026 The MathWorks, Inc.

    sampleTime = 5e-5;

    switch codeName
        case 'None'
            gridCode.name          = 'None';
            gridCode.faultTime     = [0, 1];
            gridCode.voltagePu     = [1.0, 1.0];
            gridCode.interpolation = 'step';

        case 'ERCOT'
            gridCode.name          = 'ERCOT';
            gridCode.faultTime     = [0, 0.15, 0.5, 2.0, 4.0];
            gridCode.voltagePu     = [0.15, 0.50, 0.80, 0.90, 1.0];
            gridCode.interpolation = 'step';

        case 'RTE France'
            % Segment 2 ramps linearly from the 0.15 pu floor up to 0.9 pu,
            % reached one sample before t = 1.2 s and then held. Each entry is
            % the target voltage at its breakpoint, not a ramp rate:
            % buildLvrtProfile interpolates between breakpoint values, so a rate
            % written here overshoots. The earlier
            % 0.15+0.9*(1.2-sampleTime-0.15) evaluated to 1.094955 pu, giving a
            % 9.5% swell and then a 0.195 pu step back down to 0.9.
            gridCode.name          = 'RTE France';
            gridCode.faultTime     = [0, 0.15, 1.2-sampleTime, 1.2, 4.0];
            gridCode.voltagePu     = [0.15, 0.15, 0.9, 0.9, 1.0];
            gridCode.interpolation = {'step', 'linear', 'step', 'step'};

        case 'Eir Grid'
            gridCode.name          = 'Eir Grid';
            gridCode.faultTime     = [0, 0.45, 0.50, 2.0, 4.0];
            gridCode.voltagePu     = [0.15, 0.50, 0.90, 0.90, 1.0];
            gridCode.interpolation = 'step';

        case 'ATC'
            gridCode.name          = 'ATC';
            gridCode.faultTime     = [0, 0.15, 1.2, 2.5, 3.0, 4.0];
            gridCode.voltagePu     = [0.15, 0.25, 0.50, 0.70, 0.90, 1.0];
            gridCode.interpolation = 'step';

        case 'AESO'
            gridCode.name          = 'AESO';
            gridCode.faultTime     = [0, 0.15, 0.3, 2.0, 3.0, 4.0];
            gridCode.voltagePu     = [0.15, 0.45, 0.65, 0.75, 0.90, 1.0];
            gridCode.interpolation = 'step';

        case 'SevereSag'
            gridCode.name          = 'SevereSag';
            gridCode.faultTime     = [0, 0.5];
            gridCode.voltagePu     = [0.01, 1.0];
            gridCode.interpolation = 'step';
        case 'MainsLoss'
            gridCode.name          = 'MainsLoss';
            gridCode.faultTime     = [0, 100];
            gridCode.voltagePu     = [0.001, 0.001];
            gridCode.interpolation = 'step';

        otherwise
            error('getLVRTProfile:unknownCode', ...
                'Unknown grid code: %s. Available: None, ERCOT, RTE France, Eir Grid, ATC, AESO, SevereSag', codeName); %#ok<*CTPCT>
    end

end
