function lvrtPerformance(simOut, sagRange, timeRange)
%LVRTPERFORMANCE Plot SST ride-through during grid voltage sag in 3x2 layout.
%
%   hsplot.lvrtPerformance(simOut, sagRange) shows a 3x2 grid:
%     Left column: full simulation timeline
%     Right column: zoomed to the sag event window
%
%   Row 1: Grid voltage amplitude (pu) with sag profile visible
%   Row 2: 800V DC bus voltage — demonstrates output stability during sag
%   Row 3: CHB intermediate bus (4400V) — shows energy buffer response

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    sagRange (1,2) double
    timeRange (1,2) double = [1 inf]
end

gridV = simOut.logsout.get('gridVoltage').Values;
gridV_phA = squeeze(gridV.Data(1,1,:));
Vdc = simOut.logsout.get('Vdc800V').Values;
VdcA = simOut.logsout.get('VdcA').Values;
VdcB = simOut.logsout.get('VdcB').Values;
VdcC = simOut.logsout.get('VdcC').Values;

maxPts = 2000;
tStart = max(timeRange(1), gridV.Time(1));
tStop = min(timeRange(2), gridV.Time(end));

% --- Grid voltage data ---
[tVf, idxVf] = hsplot.utils.sliceTime(gridV.Time, tStart, tStop);
vRawF = double(gridV_phA(idxVf));
vPUf = hsplot.utils.rmsEnvelope(tVf, vRawF, 1/60) * sqrt(2);
[tDsVf, vDsVf] = hsplot.utils.downsample(tVf, maxPts, vPUf);

[tVz, idxVz] = hsplot.utils.sliceTime(gridV.Time, sagRange(1), sagRange(2));
vRawZ = double(gridV_phA(idxVz));
vPUz = hsplot.utils.rmsEnvelope(tVz, vRawZ, 1/60) * sqrt(2);
[tDsVz, vDsVz] = hsplot.utils.downsample(tVz, maxPts, vPUz);

% --- 800V DC bus data ---
[tDcF, idxDcF] = hsplot.utils.sliceTime(Vdc.Time, tStart, tStop);
vDcF = double(Vdc.Data(idxDcF));
[tDsDcF, vDsDcF] = hsplot.utils.downsample(tDcF, maxPts, vDcF);

[tDcZ, idxDcZ] = hsplot.utils.sliceTime(Vdc.Time, sagRange(1), sagRange(2));
vDcZ = double(Vdc.Data(idxDcZ));
[tDsDcZ, vDsDcZ] = hsplot.utils.downsample(tDcZ, maxPts, vDcZ);

% --- CHB intermediate bus data ---
[tChbF, idxChbF] = hsplot.utils.sliceTime(VdcA.Time, tStart, tStop);
vAf = double(VdcA.Data(idxChbF));
vBf = double(VdcB.Data(idxChbF));
vCf = double(VdcC.Data(idxChbF));
[tDsChbF, vAdsF, vBdsF, vCdsF] = hsplot.utils.downsample(tChbF, maxPts, vAf, vBf, vCf);

[tChbZ, idxChbZ] = hsplot.utils.sliceTime(VdcA.Time, sagRange(1), sagRange(2));
vAz = double(VdcA.Data(idxChbZ));
vBz = double(VdcB.Data(idxChbZ));
vCz = double(VdcC.Data(idxChbZ));
[tDsChbZ, vAdsZ, vBdsZ, vCdsZ] = hsplot.utils.downsample(tChbZ, maxPts, vAz, vBz, vCz);

% --- Figure ---
fig = figure('Name', 'LVRT Performance');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 30 1300 750]);
end
tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Row 1, Col 1: Grid voltage - full
nexttile;
hold on;
fill([tDsVf(1) tDsVf(end) tDsVf(end) tDsVf(1)], [0.90 0.90 1.10 1.10], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsVf, vDsVf, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
yline(1.0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, sagRange);
xline(sagRange(1), ':', 'Sag', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(sagRange(2), ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (pu)');
title('Grid Voltage RMS (full)');
xlim([tDsVf(1) tDsVf(end)]); ylim([0.4 1.15]);
grid on; hold off;

% Row 1, Col 2: Grid voltage - zoom
nexttile;
hold on;
fill([tDsVz(1) tDsVz(end) tDsVz(end) tDsVz(1)], [0.90 0.90 1.10 1.10], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsVz, vDsVz, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
yline(1.0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (pu)');
sagMin = min(vDsVz);
title(sprintf('Grid Voltage Zoom: sag to %.0f%%', sagMin*100));
xlim(sagRange); ylim([0.4 1.15]);
grid on; hold off;

% Row 2, Col 1: 800V DC bus - full
nexttile;
hold on;
fill([tDsDcF(1) tDsDcF(end) tDsDcF(end) tDsDcF(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsDcF, vDsDcF, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, sagRange);
xline(sagRange(1), ':', 'Sag', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(sagRange(2), ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('800V DC Bus (full)');
xlim([tDsDcF(1) tDsDcF(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(vDsDcF);
ylim([min(yLo, 755) max(yHi, 845)]);
grid on; hold off;

% Row 2, Col 2: 800V DC bus - zoom
nexttile;
hold on;
fill([tDsDcZ(1) tDsDcZ(end) tDsDcZ(end) tDsDcZ(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsDcZ, vDsDcZ, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('800V Bus During Sag: pp=%.1fV', max(vDcZ)-min(vDcZ)));
xlim(sagRange);
[yLo, yHi] = hsplot.utils.autoMargin(vDsDcZ);
ylim([min(yLo, 755) max(yHi, 845)]);
grid on; hold off;

% Row 3, Col 1: CHB 4400V intermediate bus - full
nexttile;
hold on;
plot(tDsChbF, vAdsF, 'LineWidth', 1, 'Color', [0.85 0.33 0.10]);
plot(tDsChbF, vBdsF, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
plot(tDsChbF, vCdsF, 'LineWidth', 1, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, sagRange);
xline(sagRange(1), ':', 'Sag', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(sagRange(2), ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('CHB DC Bus 4400V (full)');
xlim([tDsChbF(1) tDsChbF(end)]);
[yLo, yHi] = hsplot.utils.autoMargin([vAdsF; vBdsF; vCdsF]);
ylim([min(yLo, 3800) max(yHi, 4800)]);
grid on; hold off;

% Row 3, Col 2: CHB 4400V intermediate bus - zoom
nexttile;
hold on;
plot(tDsChbZ, vAdsZ, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
plot(tDsChbZ, vBdsZ, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDsChbZ, vCdsZ, 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
legend('Phase A', 'Phase B', 'Phase C', 'Orientation', 'horizontal', 'Location', 'north');
xlabel('Time (s)'); ylabel('Voltage (V)');
minChb = min([vAz; vBz; vCz]);
title(sprintf('CHB Bus During Sag: min=%.0fV', minChb));
xlim(sagRange);
[yLo, yHi] = hsplot.utils.autoMargin([vAdsZ; vBdsZ; vCdsZ]);
ylim([min(yLo, 3800) max(yHi, 4800)]);
grid on; hold off;

sgtitle('SST Low Voltage Ride-Through Performance', 'FontSize', 14);
end
