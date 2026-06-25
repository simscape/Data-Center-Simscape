function dcBusVI(logsout,zoomRange,zoomRangeCurrent,voltageLimit)
% dcBusVI  Plot DC bus voltage and UPS battery current.
%
%   plot.dcBusVI(logsout) plots DC bus voltage (top) and battery current
%   (bottom) from simulation logsout. Voltage is shown with a yellow-gold
%   shaded acceptable band; trace segments outside the band are red.
%
%   plot.dcBusVI(logsout, zoomRange) adds an inset zoom on the voltage
%   subplot for the time window specified by zoomRange = [tStart tStop].
%
%   plot.dcBusVI(logsout, zoomRange, zoomRangeCurrent) also adds an
%   inset zoom on the current subplot for the specified time window.
%   Pass [] for zoomRange to skip the voltage zoom.
%
%   plot.dcBusVI(__, 'max', val, 'min', val) sets voltage limit band
%   boundaries. Default: max = 1.1, min = 0.9 (pu).
%
%   Required logsout signals: 'VdcUPS1', 'IBattUPS1'
%
%   Examples:
%     plot.dcBusVI(logsout)
%     plot.dcBusVI(logsout, [3 5])
%     plot.dcBusVI(logsout, [3 5], [4 6])
%     plot.dcBusVI(logsout, [], [], 'max', 1.05, 'min', 0.95)

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    zoomRange (1,2) double = [5 5.5];
    zoomRangeCurrent (1,2) double = [5 5.5];
    voltageLimit.max double = 1.1;
    voltageLimit.min double = 0.9;
end

fig = figure('Name', 'DCBusVI');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 50 1200 800]);
end

vMax = voltageLimit.max;
vMin = voltageLimit.min;
maxPts = 2000;

timeData = logsout.get('VdcUPS1').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, 1, 10);
tStartPlot = tPlot(1);
tStopPlot = tPlot(end);

voltageData = logsout.get('VdcUPS1').Values.Data(timeIdx);
currentData = logsout.get('IBattUPS1').Values.Data(timeIdx) / 16000;

[tPd, vPd, cPd] = plot.utils.downsample(tPlot, maxPts, voltageData, currentData);

hasZoom = ~isempty(zoomRange);
hasZoomCurrent = ~isempty(zoomRangeCurrent);
nCols = 1 + (hasZoom || hasZoomCurrent);

%% Voltage — full range
subplot(2, nCols, 1:nCols:nCols);
hold on

plot.utils.voltageBand(gca, [tStartPlot tStopPlot], vMin, vMax);
plot.utils.plotWithViolations(gca, tPd, vPd, vMin, vMax);

grid on;
axis([tStartPlot tStopPlot 0.5 1.5]);
title('DC Bus Voltage')
ylabel('Voltage (pu)')
xlabel('Time (s)')

%% Voltage — zoomed
if hasZoom
    zoomMask = tPlot > zoomRange(1) & tPlot < zoomRange(2);
    tZoom = tPlot(zoomMask);
    vZoom = voltageData(zoomMask);
    [tZd, vZd] = plot.utils.downsample(tZoom, maxPts, vZoom);

    subplot(2, nCols, nCols);
    hold on
    plot.utils.voltageBand(gca, zoomRange, vMin, vMax);
    plot.utils.plotWithViolations(gca, tZd, vZd, vMin, vMax);
    grid on;
    axis([zoomRange(1) zoomRange(2) 0.5 1.5]);
    title(sprintf('Voltage Zoom: %.1fs - %.1fs', zoomRange(1), zoomRange(2)))
    ylabel('Voltage (pu)')
    xlabel('Time (s)')
end

%% Current — full range
subplot(2, nCols, nCols+1:2*nCols-1+~hasZoomCurrent);
plot(tPd, cPd, 'LineWidth', 1)
hold on
grid on

[currentMin, currentMax] = plot.utils.autoMargin(cPd);
axis([tStartPlot tStopPlot currentMin currentMax]);
title('UPS Battery Current')
ylabel('Battery Current (pu)')
xlabel('Time (s)')

%% Current — zoomed
if hasZoomCurrent
    zoomMaskCurrent = tPlot > zoomRangeCurrent(1) & tPlot < zoomRangeCurrent(2);
    cZoomData = currentData(zoomMaskCurrent);
    tZoomCurrent = tPlot(zoomMaskCurrent);
    [tZdCurrent, cZdCurrent] = plot.utils.downsample(tZoomCurrent, maxPts, cZoomData);

    [cZoomMin, cZoomMax] = plot.utils.autoMargin(cZoomData);

    subplot(2, nCols, 2*nCols);
    plot(tZdCurrent, cZdCurrent, 'LineWidth', 1.5, 'Color', [0 0.45 0.74]);
    hold on
    grid on;
    axis([zoomRangeCurrent(1) zoomRangeCurrent(2) cZoomMin cZoomMax]);
    title(sprintf('Current Zoom: %.1fs - %.1fs', zoomRangeCurrent(1), zoomRangeCurrent(2)))
    ylabel('Battery Current (pu)')
    xlabel('Time (s)')
end

sgtitle('DC Bus Voltage and Current','Fontsize',15);
end
