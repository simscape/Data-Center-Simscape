function plotWithViolations(axHandle, timeVector, data, voltageMin, voltageMax)
%PLOTWITHVIOLATIONS Plot a signal with red segments outside voltage limits.
%
%   plot.utils.plotWithViolations(ax, t, data, vMin, vMax) plots the data
%   in blue where it is within [vMin, vMax] and in red where it exceeds the
%   limits. Adds appropriate legend entries.
%
%   Example:
%     plot.utils.plotWithViolations(gca, time, voltage, 0.9, 1.1);

% Copyright 2026 The MathWorks, Inc.

traceColor = [0 0.45 0.74];
violationColor = [0.9 0 0];

outsideMask = data > voltageMax | data < voltageMin;

if any(outsideMask)
    dataInside = data; dataInside(outsideMask) = NaN;
    dataOutside = data; dataOutside(~outsideMask) = NaN;
    hIn = plot(axHandle, timeVector, dataInside, 'LineWidth', 2, 'Color', traceColor);
    hOut = plot(axHandle, timeVector, dataOutside, 'LineWidth', 2, 'Color', violationColor);
    legend(axHandle, [hIn(1), hOut(1)], 'Within Band', 'Outside Band', 'Location', 'best');
else
    hIn = plot(axHandle, timeVector, data, 'LineWidth', 2, 'Color', traceColor);
    legend(axHandle, hIn(1), 'Within Band', 'Location', 'best');
end
end
