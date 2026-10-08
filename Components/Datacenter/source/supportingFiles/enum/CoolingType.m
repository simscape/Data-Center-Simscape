classdef CoolingType < int32
    enumeration
        DirectToChip  (1)
        RearDoor      (2)
        Immersion     (3)
        Custom        (4)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('DirectToChip') = 'Direct To Chip';
            map('RearDoor')     = 'Rear Door';
            map('Immersion')    = 'Immersion';
            map('Custom')       = 'Custom';
        end
    end
end
