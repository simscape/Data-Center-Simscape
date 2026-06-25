function activePower(logsout, timeRange)
% activePower  Plot load, grid, and battery active power during an event.
%
%   plot.activePower(logsout, timeRange) creates a 1x2 tiled figure:
%     Panel 1: Load active power
%     Panel 2: Grid power and battery power (+ = discharge)
%
%   timeRange = [tStart tStop] specifies the plotting window.
%
%   Example:
%     plot.loadPower(logsout, [2.9 10])

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    timeRange (1,2) double
end

maxPts = 2000;
timeData = logsout.get('loadActivePower').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange(1), timeRange(2));

loadData = reshape(logsout.get('loadActivePower').Values.Data(timeIdx), 1, []);
gridData = reshape(logsout.get('gridActivePower').Values.Data(timeIdx), 1, []);
iDcDc = logsout.get('IDCDC1').Values.Data(timeIdx);
vDc = logsout.get('VdcUPS1').Values.Data(timeIdx) * 800; % convert from pu to V
battData = reshape(-(iDcDc .* vDc) / 1e6, 1, []); % negate so positive = discharge, scale to MW

figure('Name', 'Active Power', 'Position', [100 50 1200 350], 'Color', 'w');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

%% Panel 1: Load Power
nexttile
hold on
[tDs, pDs] = plot.utils.downsample(tPlot, maxPts, loadData);
[yLo, yHi] = plot.utils.autoMargin(pDs);
fill([3 7 7 3], [min(yLo,0) min(yLo,0) yHi yHi], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(5, yHi*0.95, 'Grid Disturbance', 'FontSize', 7, ...
    'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
plot(tDs, pDs, 'LineWidth', 1.8, 'Color', [0.85 0.33 0.10]);
grid on; box on
xlim(timeRange);
ylim([min(yLo, 0) yHi]);
ylabel('Power (MW)', 'FontSize', 8)
xlabel('Time (s)', 'FontSize', 8)
title('Load Active Power', 'FontSize', 8)

%% Panel 2: Grid & Battery Power
nexttile
hold on
powerData = [gridData; battData];
[tDs, pDs] = plot.utils.downsample(tPlot, maxPts, powerData);
[yLo, yHi] = plot.utils.autoMargin(pDs);
fill([3 7 7 3], [yLo yLo yHi yHi], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(5, yHi*0.95, 'Grid Disturbance', 'FontSize', 7, ...
    'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
plot(tDs, pDs(1,:), 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDs, pDs(2,:), 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19]);
yline(0, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.8, 'HandleVisibility', 'off');
grid on; box on
xlim(timeRange);
ylim([yLo yHi]);
ylabel('Power (MW)', 'FontSize', 8)
xlabel('Time (s)', 'FontSize', 8)
title('Grid & Battery Power', 'FontSize', 8)
legend('Grid', 'Battery', 'Location', 'best')

end
