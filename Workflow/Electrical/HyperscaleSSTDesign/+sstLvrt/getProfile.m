function gridCode = getProfile(codeName)
%GETPROFILE Return a predefined LVRT grid code definition by name.
%
%   gridCode = sstLvrt.getProfile(codeName)
%
%   Available grid codes:
%     'None'            - No fault; nominal voltage throughout
%     'ERCOT'           - ERCOT descending staircase (standard)
%     'ERCOT_Ascending' - ERCOT ascending staircase for SST recovery testing
%     'SevereSag'       - Complete voltage loss for 0.5s
%     'MainsLoss'       - Extended mains loss
%
%   OUTPUT:
%     gridCode - struct with fields: name, faultTime, voltagePu, interpolation

% Copyright 2026 The MathWorks, Inc.

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

        case 'ERCOT_Ascending'
            % Ascending staircase per ERCOT LVRT grid voltage profile:
            %   0.2 pu at 9 cycles (150 ms)
            %   0.5 pu at 15 cycles (250 ms)
            %   0.8 pu at 30 cycles (500 ms)
            %   0.9 pu at 120 cycles (2.0 s)
            %   1.0 pu at 180 cycles (3.0 s) — full recovery
            gridCode.name          = 'ERCOT_Ascending';
            gridCode.faultTime     = [0, 0.15, 0.25, 0.50, 2.00, 3.00];
            gridCode.voltagePu     = [0.001, 0.2, 0.5, 0.8, 0.9, 1.0];
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
            error('sstLvrt:getProfile:unknownCode', ...
                'Unknown grid code: %s. Available: None, ERCOT, ERCOT_Ascending, SevereSag, MainsLoss', codeName);
    end

end
