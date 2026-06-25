function [timePlot, timeIdx] = sliceTime(timeData, startTime, stopTime)
%SLICETIME Extract a time window from simulation time vector.
%
%   [tPlot, idx] = plot.utils.sliceTime(timeData, tStart, tStop)
%   returns the subset of timeData within (tStart, tStop) and the logical
%   index mask. Clamps tStart/tStop to the available data range.
%
%   Example:
%     [tPlot, mask] = plot.utils.sliceTime(timeData, 0.5, 10);
%     voltageSlice = voltageData(mask);

% Copyright 2026 The MathWorks, Inc.

startTime = max(startTime, timeData(1));
stopTime = min(stopTime, timeData(end));

timeIdx = timeData > startTime & timeData < stopTime;
timePlot = timeData(timeIdx);
end
