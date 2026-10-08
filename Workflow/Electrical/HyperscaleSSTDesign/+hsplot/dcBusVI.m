function dcBusVI(simOut, zoomRange, timeRange)
%DCBUSVI Plot DC bus voltage (top) and BBU current (bottom) with zoom.
%
%   hsplot.dcBusVI(simOut) plots voltage with +-5% band and BBU current.
%
%   hsplot.dcBusVI(simOut, zoomRange) adds zoomed insets.
%
%   hsplot.dcBusVI(simOut, zoomRange, [tStart tStop]) sets full-range limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

Vdc = simOut.logsout.get('Vdc800V').Values;
BattIref = simOut.logsout.get('BattIrefTrain').Values;

tStart = max(timeRange(1), Vdc.Time(1));
tStop = min(timeRange(2), Vdc.Time(end));

[tPlotV, idxV] = hsplot.utils.sliceTime(Vdc.Time, tStart, tStop);
vData = double(Vdc.Data(idxV));

[tPlotI, idxI] = hsplot.utils.sliceTime(BattIref.Time, tStart, tStop);
iData = double(BattIref.Data(idxI));

maxPts = 2000;
[tDsV, vDs] = hsplot.utils.downsample(tPlotV, maxPts, vData);
[tDsI, iDs] = hsplot.utils.downsample(tPlotI, maxPts, iData);

vBandHi = 840; vBandLo = 760;
hasZoom = ~isempty(zoomRange);

fig = figure('Name', 'DC Bus V & I');
if hasZoom
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 50 1200 600]);
    end
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
else
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 50 1200 400]);
    end
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
end

% Voltage - full
nexttile;
hold on;
fill([tDsV(1) tDsV(end) tDsV(end) tDsV(1)], [vBandLo vBandLo vBandHi vBandHi], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsV, vDs, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('DC Bus Voltage (\\mu=%.1fV, \\sigma=%.1fV)', mean(vData), std(vData)));
xlim([tDsV(1) tDsV(end)]);
grid on; hold off;

% Voltage - zoom
if hasZoom
    nexttile;
    hold on;
    [tZ, zIdx] = hsplot.utils.sliceTime(Vdc.Time, zoomRange(1), zoomRange(2));
    vZ = double(Vdc.Data(zIdx));
    [tZd, vZd] = hsplot.utils.downsample(tZ, maxPts, vZ);
    fill([tZd(1) tZd(end) tZd(end) tZd(1)], [vBandLo vBandLo vBandHi vBandHi], ...
        [0.47 0.67 0.19], 'FaceAlpha', 0.12, 'EdgeColor', 'none');
    plot(tZd, vZd, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
    yline(800, '--', 'Color', [0.5 0.5 0.5]);
    xlabel('Time (s)'); ylabel('Voltage (V)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on; hold off;
end

% Current - full
nexttile;
hold on;
fill([tDsI(1); tDsI(:); tDsI(end)], [0; iDs(:); 0], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsI, iDs, 'LineWidth', 1, 'Color', [0.85 0.33 0.10]);
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Current (A)');
title('BBU Current (Training Rack)');
xlim([tDsI(1) tDsI(end)]);
grid on; hold off;

% Current - zoom
if hasZoom
    nexttile;
    hold on;
    [tZI, zIdxI] = hsplot.utils.sliceTime(BattIref.Time, zoomRange(1), zoomRange(2));
    iZ = double(BattIref.Data(zIdxI));
    [tZdI, iZdI] = hsplot.utils.downsample(tZI, maxPts, iZ);
    fill([tZdI(1); tZdI(:); tZdI(end)], [0; iZdI(:); 0], ...
        [0.85 0.33 0.10], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    plot(tZdI, iZdI, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
    yline(0, '-', 'Color', [0.7 0.7 0.7]);
    xlabel('Time (s)'); ylabel('Current (A)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on; hold off;
end

sgtitle('DC Bus Voltage and BBU Current', 'FontSize', 14);
end
