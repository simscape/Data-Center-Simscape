function batteryPower(logsout, timeRange)
% batteryPower  Plot battery power during an event.
%
%   plot.batteryPower(logsout, timeRange) plots the battery power
%   (Vdc * IDCDC1) over the specified time window with a shaded area.
%
%   timeRange = [tStart tStop] specifies the plotting window.
%
%   Example:
%     plot.batteryPower(logsout, [2.9 8])

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    timeRange (1,2) double
end

maxPts = 2000;
timeData = logsout.get('VdcUPS1').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange(1), timeRange(2));

vdcData = logsout.get('VdcUPS1').Values.Data;
idcdcData = logsout.get('IDCDC1').Values.Data;
powerPlot = vdcData(timeIdx) .* idcdcData(timeIdx);

[tDs, pDs] = plot.utils.downsample(tPlot, maxPts, powerPlot);

activeThreshold = 10;

figure('Name', 'Battery Power');
hold on

activeMask = abs(pDs) > activeThreshold;
tShaded = tDs;
pShaded = pDs;
pShaded(~activeMask) = 0;

fill([tShaded(1); tShaded(:); tShaded(end)], [0; pShaded(:); 0], ...
    [0.20 0.50 0.75], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
plot(tDs, pDs, 'LineWidth', 2, 'Color', [0.20 0.50 0.75]);

grid on
xlim([tPlot(1) tPlot(end)]);
[yLo, yHi] = plot.utils.autoMargin(pDs);
ylim([yLo yHi]);
title('Battery Power', 'FontSize', 14)
ylabel('Power (W)')
xlabel('Time (s)')
end
