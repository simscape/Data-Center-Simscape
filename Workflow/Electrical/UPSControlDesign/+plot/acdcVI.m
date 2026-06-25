function acdcVI(logsout, zoomRange, voltageLimit, timeRange)
% acdcVI  Plot grid voltage, UPS voltage, and system currents.
%
%   plot.acdcVI(logsout, zoomRange) plots a 3x2 layout:
%     Row 1: Grid voltage (RMS) — full range & zoomed
%     Row 2: UPS output voltage (RMS) — full range & zoomed
%     Row 3: DC input, battery, and load currents — full range & zoomed
%   zoomRange = [tStart tStop] specifies the zoom window.
%
%   plot.acdcVI(__, 'max', val, 'min', val) sets voltage limit
%   band boundaries. Default: max = 1.1, min = 0.9 (pu).
%
%   plot.acdcVI(__, 'tStart', val, 'tStop', val) overrides the
%   default plotting time range. Default: tStart = 0.1, tStop = 10 (s).
%
%   Required logsout signals: 'gridVoltage', 'VacRMS', 'Idc', 'IBatt',
%   'ILoad'
%
%   Examples:
%     plot.acdcVI(logsout, [2 4])
%     plot.acdcVI(logsout, [2 4], 'max', 1.05, 'min', 0.95)
%     plot.acdcVI(logsout, [3 5], 'tStart', 1, 'tStop', 8)

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    zoomRange (1,2) double
    voltageLimit.max double = 1.1;
    voltageLimit.min double = 0.9;
    timeRange.tStart double = 0.1;
    timeRange.tStop double = 10;
end

fig = figure('Name', 'System Monitor');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 50 1200 800]);
end

vMax       = voltageLimit.max;
vMin       = voltageLimit.min;
tZoomStart = zoomRange(1);
tZoomStop  = zoomRange(2);
maxPts     = 2000;

%% Pre-fetch — slice to time range
timeData = logsout.get('gridVoltage').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange.tStart, timeRange.tStop);
tStart = tPlot(1);
tStop = tPlot(end);

zoomMask = tPlot > tZoomStart & tPlot < tZoomStop;
tZoom    = tPlot(zoomMask);

gridRMS = sliceRMS(logsout.get('gridVoltage').Values.Data, timeIdx);
upsRMS  = reshape(squeeze(logsout.get('VacRMS').Values.Data(1, 1, timeIdx)), 1, []) * sqrt(2);
idcData   = sliceVec(logsout.get('Idc').Values.Data, timeIdx) / 1000;
ibattData = -sliceVec(logsout.get('IBattUPS1').Values.Data, timeIdx) / 1000;
iloadData = sliceVec(logsout.get('ILoad').Values.Data, timeIdx) / 1000;

%% Decimate for plotting
[tPd, gPd, uPd] = plot.utils.downsample(tPlot, maxPts, gridRMS, upsRMS);
[tZd, gZd, uZd] = plot.utils.downsample(tZoom, maxPts, gridRMS(zoomMask), upsRMS(zoomMask));

allCurrents = [idcData; ibattData; iloadData];
[~, allCurrentsDs] = plot.utils.downsample(tPlot, maxPts, allCurrents);
[~, zoomCurrentsDs] = plot.utils.downsample(tZoom, maxPts, allCurrents(:, zoomMask));

[cMin, cMax] = plot.utils.autoMargin(allCurrents);
[zcMin, zcMax] = plot.utils.autoMargin(allCurrents(:, zoomMask));

currentNames  = {'I_{dc}', 'I_{batt}', 'I_{load}'};
currentColors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19];

%% Row 1 — Grid Voltage RMS
axHandle = subplot(3,2,1);
hold(axHandle, 'on')
plot.utils.voltageBand(axHandle, [tStart tStop], vMin, vMax);
plotRMSTrace(axHandle, tPd, gPd, vMin, vMax, tStart, tStop);
plot.utils.highlightZoom(axHandle, zoomRange);
title(axHandle, 'Grid Voltage (RMS)'); ylabel(axHandle, 'Voltage (pu)'); xlabel(axHandle, 'Time (s)')

axHandle = subplot(3,2,2);
hold(axHandle, 'on')
plot.utils.voltageBand(axHandle, zoomRange, vMin, vMax);
plotRMSTrace(axHandle, tZd, gZd, vMin, vMax, tZoomStart, tZoomStop);
title(axHandle, sprintf('Grid Voltage (%.1fs - %.1fs)', tZoomStart, tZoomStop))
ylabel(axHandle, 'Voltage (pu)'); xlabel(axHandle, 'Time (s)')

%% Row 2 — UPS Output Voltage RMS
axHandle = subplot(3,2,3);
hold(axHandle, 'on')
plot.utils.voltageBand(axHandle, [tStart tStop], vMin, vMax);
plotRMSTrace(axHandle, tPd, uPd, vMin, vMax, tStart, tStop);
ylim(axHandle, [0.5 1.5]);
plot.utils.highlightZoom(axHandle, zoomRange);
title(axHandle, 'UPS Output Voltage (RMS)'); ylabel(axHandle, 'Voltage (pu)'); xlabel(axHandle, 'Time (s)')

axHandle = subplot(3,2,4);
hold(axHandle, 'on')
plot.utils.voltageBand(axHandle, zoomRange, vMin, vMax);
plotRMSTrace(axHandle, tZd, uZd, vMin, vMax, tZoomStart, tZoomStop);
ylim(axHandle, [0.5 1.5]);
title(axHandle, sprintf('UPS Voltage (%.1fs - %.1fs)', tZoomStart, tZoomStop))
ylabel(axHandle, 'Voltage (pu)'); xlabel(axHandle, 'Time (s)')

%% Row 3 — Currents full range
axHandle = subplot(3,2,5);
hold(axHandle, 'on')
plotCurrentTraces(axHandle, tPd, allCurrentsDs, currentColors, currentNames);
plot.utils.highlightZoom(axHandle, zoomRange);
title(axHandle, 'DC Link Currents'); ylabel(axHandle, 'Current (kA)'); xlabel(axHandle, 'Time (s)')
xlim(axHandle, [tStart tStop]); ylim(axHandle, [cMin cMax])

%% Row 3 — Currents zoomed
axHandle = subplot(3,2,6);
hold(axHandle, 'on')
plotCurrentTraces(axHandle, tZd, zoomCurrentsDs, currentColors, currentNames);
title(axHandle, sprintf('DC Link Currents (%.1fs - %.1fs)', tZoomStart, tZoomStop))
ylabel(axHandle, 'Current (kA)'); xlabel(axHandle, 'Time (s)')
xlim(axHandle, [tZoomStart tZoomStop]); ylim(axHandle, [zcMin zcMax])

sgtitle('Voltage and Current Measurements', 'Fontsize', 15);
end

%% ====== Local functions ======

function rmsData = sliceRMS(rawData, idx)
    data = squeeze(rawData);
    if isvector(data)
        rmsData = reshape(abs(data(idx)) * sqrt(2), 1, []);
    else
        if size(data,2) < size(data,1)
            data = data.';
        end
        rmsData = rms(data(:, idx), 1) * sqrt(2);
    end
end

function vecData = sliceVec(rawData, idx)
    vecData = reshape(squeeze(rawData(idx)), 1, []);
end

function plotRMSTrace(axHandle, timeVector, vData, vMin, vMax, tLo, tHi)
    traceColor = [0 0.45 0.74];
    hTrace = plot(axHandle, timeVector, vData, 'LineWidth', 2, 'Color', traceColor);
    legend(axHandle, hTrace, 'Voltage', 'Location', 'best');
    grid(axHandle, 'on')
    yLo = min([vMin; vData(:)]);
    yHi = max([vMax; vData(:)]);
    yMargin = 0.1 * max(abs(yHi - yLo), 0.01);
    axis(axHandle, [tLo tHi yLo-yMargin yHi+yMargin])
end

function plotCurrentTraces(axHandle, timeVector, data, colors, names)
    nSig = size(data, 1);
    lineHandles = gobjects(1, nSig);
    for sigIdx = 1:nSig
        lineHandles(sigIdx) = plot(axHandle, timeVector, data(sigIdx,:), 'LineWidth', 1.5, 'Color', colors(sigIdx,:));
    end
    legend(axHandle, lineHandles, names, 'Location', 'best', 'FontSize', 12);
    grid(axHandle, 'on')
end
