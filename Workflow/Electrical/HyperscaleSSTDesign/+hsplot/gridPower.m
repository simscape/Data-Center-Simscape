function gridPower(simOut, zoomRange, timeRange)
%GRIDPOWER Plot grid-side voltage and total load current.
%
%   hsplot.gridPower(simOut) plots grid voltage (top) and DC bus current (bottom).
%
%   hsplot.gridPower(simOut, zoomRange) adds zoomed subplots.
%
%   hsplot.gridPower(simOut, zoomRange, [tStart tStop]) sets full-range limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

gridV = simOut.logsout.get('gridVoltage').Values;
Idc = simOut.logsout.get('IdcTotal').Values;

tStart = max(timeRange(1), gridV.Time(1));
tStop = min(timeRange(2), gridV.Time(end));

[tPlotV, idxV] = hsplot.utils.sliceTime(gridV.Time, tStart, tStop);
vRaw = double(gridV.Data(idxV));
vGrid = hsplot.utils.rmsEnvelope(tPlotV, vRaw, 1/60) * sqrt(2);

[tPlotI, idxI] = hsplot.utils.sliceTime(Idc.Time, tStart, tStop);
iDc = double(Idc.Data(idxI));

maxPts = 2000;
[tDsV, vDs] = hsplot.utils.downsample(tPlotV, maxPts, vGrid);
[tDsI, iDs] = hsplot.utils.downsample(tPlotI, maxPts, iDc);

hasZoom = ~isempty(zoomRange);

fig = figure('Name', 'Grid Power');
if hasZoom
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 50 1200 500]);
    end
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
else
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 50 1200 400]);
    end
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
end

% Grid voltage - full
nexttile;
hold on;
plot(tDsV, vDs, 'LineWidth', 0.8, 'Color', [0.00 0.45 0.74]);
yline(1.0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Voltage (pu)');
title('Grid Voltage RMS (Phase A, base = 13.8 kV)');
xlim([tDsV(1) tDsV(end)]);
grid on; hold off;

% Grid voltage - zoom
if hasZoom
    nexttile;
    [tZ, zIdx] = hsplot.utils.sliceTime(gridV.Time, zoomRange(1), zoomRange(2));
    vZ_raw = double(gridV.Data(zIdx));
    vZ = hsplot.utils.rmsEnvelope(tZ, vZ_raw, 1/60) * sqrt(2);
    [tZd, vZd] = hsplot.utils.downsample(tZ, maxPts, vZ);
    plot(tZd, vZd, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
    yline(1.0, '--', 'Color', [0.5 0.5 0.5]);
    xlabel('Time (s)'); ylabel('Voltage (pu)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on;
end

% DC bus current - full
nexttile;
hold on;
fill([tDsI(1); tDsI(:); tDsI(end)], [0; iDs(:); 0], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsI, iDs, 'LineWidth', 1, 'Color', [0.47 0.67 0.19]);
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Current (A)');
title('Total DC Bus Current (800V side)');
xlim([tDsI(1) tDsI(end)]);
grid on; hold off;

% DC current - zoom
if hasZoom
    nexttile;
    hold on;
    [tZI, zIdxI] = hsplot.utils.sliceTime(Idc.Time, zoomRange(1), zoomRange(2));
    iZ = double(Idc.Data(zIdxI));
    [tZdI, iZd] = hsplot.utils.downsample(tZI, maxPts, iZ);
    fill([tZdI(1); tZdI(:); tZdI(end)], [0; iZd(:); 0], ...
        [0.47 0.67 0.19], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    plot(tZdI, iZd, 'LineWidth', 1.2, 'Color', [0.47 0.67 0.19]);
    xlabel('Time (s)'); ylabel('Current (A)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on; hold off;
end

sgtitle('Grid-Side Measurements', 'FontSize', 14);
end
