classdef wallExternalModelOption < int32
% Wall external model option definition.
    
% Copyright 2025 The MathWorks, Inc.

    enumeration
        wallSolar        (1)
        wallSolarWin     (2)
        wallSolarWinVent (3)
        wallSolarVent    (4)
    end
    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('wallSolar') = 'Solid Wall with Solar Load';
            map('wallSolarWin') = 'Solid Wall with Window/Door and Solar Load';
            map('wallSolarWinVent') = 'Solid Wall with Window/Door, Vent, and Solar Load';
            map('wallSolarVent') = 'Solid Wall with Vent and Solar Load';
        end
    end
end