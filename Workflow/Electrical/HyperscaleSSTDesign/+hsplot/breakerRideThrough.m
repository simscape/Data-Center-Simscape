function breakerRideThrough(simOut, zoomRange, timeRange)
%BREAKERRIDETHROUGH Plot Training Rack local voltage and BBU current during breaker trip.
%
%   hsplot.breakerRideThrough(simOut) plots full timeline.
%
%   hsplot.breakerRideThrough(simOut, zoomRange) zooms to event window.
%
%   hsplot.breakerRideThrough(simOut, zoomRange, [tStart tStop]) sets limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

VdcTrain = simOut.logsout.get('VdcTrain').Values;
Vdc_main = simOut.logsout.get('Vdc800V').Values;
BattIref = simOut.logsout.get('BattIrefTrain').Values;
BattIrefBatt = simOut.logsout.get('BattIrefBattTrain').Values;
hasBattChannel = ~isempty(BattIrefBatt);

tStart = max(timeRange(1), VdcTrain.Time(1));
tStop = min(timeRange(2), VdcTrain.Time(end));

[tPlot, idx] = hsplot.utils.sliceTime(VdcTrain.Time, tStart, tStop);
vTrain = double(VdcTrain.Data(idx));
vMain = interp1(Vdc_main.Time, double(Vdc_main.Data), tPlot, 'linear', 'extrap');

[tI, idxI] = hsplot.utils.sliceTime(BattIref.Time, tStart, tStop);
iRef = double(BattIref.Data(idxI));

maxPts = 2000;
[tDs, vTrainDs, vMainDs] = hsplot.utils.downsample(tPlot, maxPts, vTrain, vMain);
[tIDs, iDs] = hsplot.utils.downsample(tI, maxPts, iRef);

if hasBattChannel
    [tIB, idxIB] = hsplot.utils.sliceTime(BattIrefBatt.Time, tStart, tStop);
    iBatt = double(BattIrefBatt.Data(idxIB));
    [tIBDs, iBDs] = hsplot.utils.downsample(tIB, maxPts, iBatt);
end

vNom = 800;
vBandHi = 840;
vBandLo = 760;

hasZoom = ~isempty(zoomRange);

fig = figure('Name', 'Breaker Ride-Through');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 1100 600]);
end

if hasZoom
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
else
    tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
end

% Top: Voltage comparison
nexttile;
hold on;
fill([tDs(1) tDs(end) tDs(end) tDs(1)], [vBandLo vBandLo vBandHi vBandHi], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs, vMainDs, 'LineWidth', 1, 'Color', [0.5 0.5 0.5], 'DisplayName', 'Main Bus (DAB)');
plot(tDs, vTrainDs, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10], 'DisplayName', 'Training Rack (Islanded)');
yline(vNom, '--', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Voltage (V)');
title('DC Bus Voltage: Main Bus vs Islanded Rack');
legend('Location', 'best');
xlim([tDs(1) tDs(end)]);
[yLo, yHi] = hsplot.utils.autoMargin([vTrainDs; vMainDs]);
ylim([min(yLo, vBandLo-10) max(yHi, vBandHi+10)]);
grid on; hold off;

% Top zoom
if hasZoom
    nexttile;
    hold on;
    [tZ, zIdx] = hsplot.utils.sliceTime(VdcTrain.Time, zoomRange(1), zoomRange(2));
    vZ = double(VdcTrain.Data(zIdx));
    vZM = interp1(Vdc_main.Time, double(Vdc_main.Data), tZ, 'linear', 'extrap');
    [tZd, vZd, vZMd] = hsplot.utils.downsample(tZ, maxPts, vZ, vZM);
    fill([tZd(1) tZd(end) tZd(end) tZd(1)], [vBandLo vBandLo vBandHi vBandHi], ...
        [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tZd, vZMd, 'LineWidth', 1, 'Color', [0.5 0.5 0.5], 'DisplayName', 'Main Bus');
    plot(tZd, vZd, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10], 'DisplayName', 'Training Rack');
    yline(vNom, '--', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
    xlabel('Time (s)'); ylabel('Voltage (V)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    legend('Location', 'best');
    xlim(zoomRange);
    [yLo, yHi] = hsplot.utils.autoMargin([vZd; vZMd]);
    ylim([min(yLo, vBandLo-10) max(yHi, vBandHi+10)]);
    grid on; hold off;
end

% Bottom: BBU current (supercap + battery)
nexttile;
hold on;
fill([tIDs(1); tIDs(:); tIDs(end)], [0; iDs(:); 0], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tIDs, iDs, 'LineWidth', 1, 'Color', [0.85 0.33 0.10], 'DisplayName', 'Supercap');
if hasBattChannel
    fill([tIBDs(1); tIBDs(:); tIBDs(end)], [0; iBDs(:); 0], ...
        [0.00 0.45 0.74], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tIBDs, iBDs, 'LineWidth', 1, 'Color', [0.00 0.45 0.74], 'DisplayName', 'Battery');
end
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Current (A)');
title('Training Rack BBU Current');
legend('Location', 'best');
xlim([tIDs(1) tIDs(end)]);
grid on; hold off;

% Bottom zoom
if hasZoom
    nexttile;
    hold on;
    [tZI, zIdxI] = hsplot.utils.sliceTime(BattIref.Time, zoomRange(1), zoomRange(2));
    iZI = double(BattIref.Data(zIdxI));
    [tZId, iZId] = hsplot.utils.downsample(tZI, maxPts, iZI);
    fill([tZId(1); tZId(:); tZId(end)], [0; iZId(:); 0], ...
        [0.85 0.33 0.10], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tZId, iZId, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10], 'DisplayName', 'Supercap');
    if hasBattChannel
        [tZIB, zIdxIB] = hsplot.utils.sliceTime(BattIrefBatt.Time, zoomRange(1), zoomRange(2));
        iZIB = double(BattIrefBatt.Data(zIdxIB));
        [tZIBd, iZIBd] = hsplot.utils.downsample(tZIB, maxPts, iZIB);
        fill([tZIBd(1); tZIBd(:); tZIBd(end)], [0; iZIBd(:); 0], ...
            [0.00 0.45 0.74], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        plot(tZIBd, iZIBd, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74], 'DisplayName', 'Battery');
    end
    yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
    xlabel('Time (s)'); ylabel('Current (A)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    legend('Location', 'best');
    xlim(zoomRange);
    grid on; hold off;
end

sgtitle('Breaker Trip: Training Rack BBU Island Ride-Through', 'FontSize', 14);
end
