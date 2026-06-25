function gridCodeResults(logsout, timeRange)
% gridCodeResults  Plot a 2x2 summary of UPS performance during an LVRT event.
%
%   plot.gridCodeResults(logsout, timeRange) creates a tiled figure with:
%     Top-left: Active power (Grid, Load, UPS, Generator)
%     Top-right: Load RMS voltage with acceptable band
%     Bottom-left: DC bus voltage with acceptable band
%     Bottom-right: Battery current
%
%   timeRange = [tStart tStop] specifies the plotting window.
%
%   Example:
%     plot.gridCodeResults(logsout, [2.9 8])

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    timeRange (1,2) double
end

maxPts = 2000;
timeData = logsout.get('gridActivePower').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange(1), timeRange(2));

figure('Name', 'Grid Code Results');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

%% Active Power
nexttile;
hold on
powerNames = {'grid','load','UPS','generator'};
legendLabels = {'Grid','Load','UPS','Generator'};
colors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19; 0.93 0.69 0.13];
nIdx = sum(timeIdx);
powerData = zeros(numel(powerNames), nIdx);
for powerIdx = 1:numel(powerNames)
    raw = logsout.get(strcat(powerNames{powerIdx},'ActivePower')).Values.Data;
    powerData(powerIdx,:) = reshape(raw(timeIdx), 1, []);
end
[tDs, pDs] = plot.utils.downsample(tPlot, maxPts, powerData);
for powerIdx = 1:numel(powerNames)
    plot(tDs, pDs(powerIdx,:), 'LineWidth', 1.5, 'Color', colors(powerIdx,:));
end
grid on; title('Active Power'); ylabel('Power (MW)'); xlabel('Time (s)')
legend(legendLabels, 'Location', 'best');

%% Load Voltage
nexttile;
hold on
rmsVoltage = logsout.get('rmsVoltage').Values.Data * sqrt(2);
vPlot = rmsVoltage(timeIdx);
[tDs, vDs] = plot.utils.downsample(tPlot, maxPts, vPlot);
plot.utils.voltageBand(gca, [tPlot(1) tPlot(end)], 0.9, 1.1);
plot.utils.plotWithViolations(gca, tDs, vDs, 0.9, 1.1);
grid on; axis([tPlot(1) tPlot(end) 0.5 1.5])
title('Load Voltage (RMS)'); ylabel('Voltage (pu)'); xlabel('Time (s)')

%% DC Bus Voltage
nexttile;
hold on
dcData = logsout.get('VdcUPS1').Values.Data(timeIdx);
[tDs, dcDs] = plot.utils.downsample(tPlot, maxPts, dcData);
plot.utils.voltageBand(gca, [tPlot(1) tPlot(end)], 0.9, 1.1);
plot.utils.plotWithViolations(gca, tDs, dcDs, 0.9, 1.1);
grid on; axis([tPlot(1) tPlot(end) 0.5 1.5])
title('DC Bus Voltage'); ylabel('Voltage (pu)'); xlabel('Time (s)')

%% Battery Current
nexttile;
hold on
battData = logsout.get('IBattUPS1').Values.Data(timeIdx);
[tDs, battDs] = plot.utils.downsample(tPlot, maxPts, battData);
plot(tDs, battDs, 'LineWidth', 1.5, 'Color', [0 0.45 0.74]);
grid on; title('Battery Current'); ylabel('Current (pu)'); xlabel('Time (s)')
[yLo, yHi] = plot.utils.autoMargin(battDs);
xlim([tPlot(1) tPlot(end)]); ylim([yLo yHi]);
end
