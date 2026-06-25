classdef cloudCoverLibOption < int32
% Cloud cover option definition for library.

% Copyright 2025 The MathWorks, Inc.
    
    enumeration
        none   (1)
        hourly (2)
        daily  (3)
    end
    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('none')   = 'None';
            map('hourly') = 'Hourly data';
            map('daily')  = 'Day-wise data';
        end
    end
end