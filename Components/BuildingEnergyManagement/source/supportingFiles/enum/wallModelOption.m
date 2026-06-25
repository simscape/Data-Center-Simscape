classdef wallModelOption < int32
% Wall model option definition.
    
% Copyright 2025 The MathWorks, Inc.

    enumeration
        wallOnly         (1)
        wallWinVent      (2)
        wallSolar        (3)
        wallSolarWin     (4)
        wallSolarWinVent (5)
        wallSolarVent    (6)
    end
    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('wallOnly') = 'Solid Wall';
            map('wallWinVent') = 'Solid Wall with Opening';
            map('wallSolar') = 'Solid Wall with Solar Load';
            map('wallSolarWin') = 'Solid Wall with Window/Door and Solar Load';
            map('wallSolarWinVent') = 'Solid Wall with Window/Door, Vent, and Solar Load';
            map('wallSolarVent') = 'Solid Wall with Vent and Solar Load';
        end
    end
end