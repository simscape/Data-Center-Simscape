function [timePlot, timeIdx] = sliceTime(timeData, startTime, stopTime)
%SLICETIME Extract a time window from simulation time vector.

% Copyright 2026 The MathWorks, Inc.

startTime = max(startTime, timeData(1));
stopTime = min(stopTime, timeData(end));

timeIdx = timeData >= startTime & timeData <= stopTime;
timePlot = timeData(timeIdx);
end
