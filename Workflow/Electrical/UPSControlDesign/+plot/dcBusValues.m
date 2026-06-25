function dcBusValues(logsout, timeRange)
% dcBusValues  Plot DC bus performance during an LVRT event.
%
%   plot.dcBusValues(logsout, timeRange) creates a 2x1 tiled figure with:
%     Panel 1: Battery current
%     Panel 2: DC bus voltage
%
%   timeRange = [tStart tStop] specifies the plotting window.
%
%   Example:
%     plot.dcBusValues(logsout, [2.9 10])

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    timeRange (1,2) double
end

maxPts = 2000;
timeData = logsout.get('VdcUPS1').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange(1), timeRange(2));

figure('Name', 'DC Bus Values', 'Position', [100 50 1200 350], 'Color', 'w');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

%% Panel 1: Battery Current
nexttile
hold on
battData = logsout.get('IBattUPS1').Values.Data(timeIdx) / 15000;
[tDs, battDs] = plot.utils.downsample(tPlot, maxPts, battData);
[yLo, yHi] = plot.utils.autoMargin(battDs);
fill([3 7 7 3], [yLo yLo yHi yHi], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(5, yHi*0.95, 'Grid Disturbance', 'FontSize', 7, ...
    'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
plot(tDs, battDs, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
yline(0, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.8, 'HandleVisibility', 'off');
grid on; box on
xlim(timeRange); ylim([yLo yHi]);
ylabel('Current (pu)', 'FontSize', 8)
xlabel('Time (s)', 'FontSize', 8)
title('Battery Current', 'FontSize', 8)

%% Panel 2: DC Bus Voltage
nexttile
hold on
dcData = logsout.get('VdcUPS1').Values.Data(timeIdx);
[tDs, dcDs] = plot.utils.downsample(tPlot, maxPts, dcData);
fill([3 7 7 3], [0.5 0.5 1.5 1.5], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(5, 1.42, 'Grid Disturbance', 'FontSize', 7, ...
    'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
plot.utils.voltageBand(gca, timeRange, 0.9, 1.1);
plot.utils.plotWithViolations(gca, tDs, dcDs, 0.9, 1.1);
grid on; box on
xlim(timeRange); ylim([0.5 1.5]);
ylabel('Voltage (pu)', 'FontSize', 8)
xlabel('Time (s)', 'FontSize', 8)
title('DC Bus Voltage', 'FontSize', 8)

end
