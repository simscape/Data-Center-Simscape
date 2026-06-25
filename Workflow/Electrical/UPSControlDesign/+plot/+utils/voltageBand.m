function bandHandle = voltageBand(axHandle, timeRange, voltageMin, voltageMax)
%VOLTAGEBAND Draw a shaded acceptable voltage band on axes.
%
%   h = plot.utils.voltageBand(ax, [tStart tStop], vMin, vMax)
%   draws a yellow-gold semi-transparent rectangle representing the
%   acceptable voltage range. Returns the fill handle for legend use.
%
%   Example:
%     hBand = plot.utils.voltageBand(gca, [0 10], 0.9, 1.1);
%     legend(hBand, 'Acceptable Band');

% Copyright 2026 The MathWorks, Inc.

bandX = [timeRange(1), timeRange(2), timeRange(2), timeRange(1)];
bandY = [voltageMin, voltageMin, voltageMax, voltageMax];

bandHandle = fill(axHandle, bandX, bandY, ...
    [1 0.85 0.35], 'FaceAlpha', 0.25, 'EdgeColor', [0.9 0.7 0.1], 'LineWidth', 0.5);
end
