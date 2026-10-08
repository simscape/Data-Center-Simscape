function sstPerformance(simOut, zoomRange, timeRange, eventLabels)
%SSTPERFORMANCE Plot SST regulation quality in 4x2 layout.
%
%   hsplot.sstPerformance(simOut, zoomRange) shows a 4x2 grid:
%     Left column: full simulation timeline
%     Right column: zoomed to the event window
%
%   Row 1: Grid voltage RMS in per-unit (regulation quality)
%   Row 2: Power tracking — grid vs individual rack loads
%   Row 3: 800V DC bus voltage with +-5% band
%   Row 4: Reactive power Q (left), CHB per-phase DC voltages (right)

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange (1,2) double
    timeRange (1,2) double = [1 inf]
    eventLabels (1,2) string = ["Start", "End"]
end

gridV = simOut.logsout.get('gridVoltage').Values;
gridV_phA = squeeze(gridV.Data(1,1,:));
Vdc = simOut.logsout.get('Vdc800V').Values;
P_grid = simOut.logsout.get('pGrid').Values;
P_load = simOut.logsout.get('pLoad').Values;
P_train = simOut.logsout.get('PtrainW').Values;
P_infer = simOut.logsout.get('PinferW').Values;
Q_grid = simOut.logsout.get('qGrid').Values;
VdcA = simOut.logsout.get('VdcA').Values;
VdcB = simOut.logsout.get('VdcB').Values;
VdcC = simOut.logsout.get('VdcC').Values;

maxPts = 2000;
tStart = max(timeRange(1), gridV.Time(1));
tStop = min(timeRange(2), gridV.Time(end));

% --- Full-range data ---
[tVf, idxVf] = hsplot.utils.sliceTime(gridV.Time, tStart, tStop);
vRawF = double(gridV_phA(idxVf));
vPUf = hsplot.utils.rmsEnvelope(tVf, vRawF, 1/60) * sqrt(2);
[tDsVf, vDsVf] = hsplot.utils.downsample(tVf, maxPts, vPUf);

[tPf, idxPf] = hsplot.utils.sliceTime(P_grid.Time, tStart, tStop);
pGridF = double(P_grid.Data(idxPf));
pLoadF = double(P_load.Data(idxPf));
[~, idxTf] = hsplot.utils.sliceTime(P_train.Time, tStart, tStop);
pTrF = 4 * double(P_train.Data(idxTf)) / 1e6;
pInF = 4 * double(P_infer.Data(idxTf)) / 1e6;
[tDsPf, pGridDsF, pLoadDsF, pTrDsF, pInDsF] = hsplot.utils.downsample(tPf, maxPts, pGridF, pLoadF, pTrF, pInF);

[tDcF, idxDcF] = hsplot.utils.sliceTime(Vdc.Time, tStart, tStop);
vDcF = double(Vdc.Data(idxDcF));
[tDsDcF, vDsDcF] = hsplot.utils.downsample(tDcF, maxPts, vDcF);

% --- Zoomed data ---
[tVz, idxVz] = hsplot.utils.sliceTime(gridV.Time, zoomRange(1), zoomRange(2));
vRawZ = double(gridV_phA(idxVz));
vPUz = hsplot.utils.rmsEnvelope(tVz, vRawZ, 1/60) * sqrt(2);
[tDsVz, vDsVz] = hsplot.utils.downsample(tVz, maxPts, vPUz);

[tPz, idxPz] = hsplot.utils.sliceTime(P_grid.Time, zoomRange(1), zoomRange(2));
pGridZ = double(P_grid.Data(idxPz));
pLoadZ = double(P_load.Data(idxPz));
[~, idxTz] = hsplot.utils.sliceTime(P_train.Time, zoomRange(1), zoomRange(2));
pTrZ = 4 * double(P_train.Data(idxTz)) / 1e6;
pInZ = 4 * double(P_infer.Data(idxTz)) / 1e6;
[tDsPz, pGridDsZ, pLoadDsZ, pTrDsZ, pInDsZ] = hsplot.utils.downsample(tPz, maxPts, pGridZ, pLoadZ, pTrZ, pInZ);

[tDcZ, idxDcZ] = hsplot.utils.sliceTime(Vdc.Time, zoomRange(1), zoomRange(2));
vDcZ = double(Vdc.Data(idxDcZ));
[tDsDcZ, vDsDcZ] = hsplot.utils.downsample(tDcZ, maxPts, vDcZ);

% --- Reactive power data ---
[tQf, idxQf] = hsplot.utils.sliceTime(Q_grid.Time, tStart, tStop);
qF = double(Q_grid.Data(idxQf));
[tDsQf, qDsF] = hsplot.utils.downsample(tQf, maxPts, qF);

% --- CHB per-phase DC voltage data (zoom only) ---
[tChbZ, idxChbZ] = hsplot.utils.sliceTime(VdcA.Time, zoomRange(1), zoomRange(2));
vAz = double(VdcA.Data(idxChbZ));
vBz = double(VdcB.Data(idxChbZ));
vCz = double(VdcC.Data(idxChbZ));
[tDsChbZ, vAdsZ, vBdsZ, vCdsZ] = hsplot.utils.downsample(tChbZ, maxPts, vAz, vBz, vCz);

% --- Figure ---
fig = figure('Name', 'SST Performance');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 30 1300 950]);
end
tiledlayout(4, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Row 1, Col 1: Grid voltage - full
nexttile;
hold on;
fill([tDsVf(1) tDsVf(end) tDsVf(end) tDsVf(1)], [0.95 0.95 1.05 1.05], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsVf, vDsVf, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(1.0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, zoomRange);
xline(zoomRange(1), ':', eventLabels(1), 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(zoomRange(2), ':', eventLabels(2), 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (pu)');
title('Grid Voltage RMS (full)');
xlim([tDsVf(1) tDsVf(end)]);
ylim([min(min(vDsVf)-0.02, 0.94) max(max(vDsVf)+0.02, 1.06)]);
grid on; hold off;

% Row 1, Col 2: Grid voltage - zoom
nexttile;
hold on;
fill([tDsVz(1) tDsVz(end) tDsVz(end) tDsVz(1)], [0.95 0.95 1.05 1.05], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsVz, vDsVz, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
yline(1.0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (pu)');
vMinZ = min(vDsVz);
vMaxZ = max(vDsVz);
title(sprintf('Grid Voltage Zoom: %.1f%% - %.1f%%', vMinZ*100, vMaxZ*100));
xlim(zoomRange);
ylim([min(vMinZ-0.02, 0.94) max(vMaxZ+0.02, 1.06)]);
grid on; hold off;

% Row 2, Col 1: Power tracking - full
nexttile;
hold on;
fill([tDsPf(1); tDsPf(:); tDsPf(end)], [0; pGridDsF(:); 0], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([tDsPf(1); tDsPf(:); tDsPf(end)], [0; pLoadDsF(:); 0], ...
    [0.64 0.08 0.18], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsPf, pGridDsF, 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19]);
plot(tDsPf, pLoadDsF, 'LineWidth', 1.5, 'Color', [0.64 0.08 0.18]);
plot(tDsPf, pTrDsF, 'LineWidth', 1, 'Color', [0.85 0.33 0.10]);
plot(tDsPf, pInDsF, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
hsplot.utils.highlightZoom(gca, zoomRange);
xline(zoomRange(1), ':', eventLabels(1), 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(zoomRange(2), ':', eventLabels(2), 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Power (MW)');
title('Power Flow (full)');
xlim([tDsPf(1) tDsPf(end)]);
[yLo, yHi] = hsplot.utils.autoMargin([pGridDsF; pLoadDsF; pTrDsF; pInDsF]);
ylim([max(yLo,0) yHi]);
grid on; hold off;

% Row 2, Col 2: Power tracking - zoom
nexttile;
hold on;
fill([tDsPz(1); tDsPz(:); tDsPz(end)], [0; pGridDsZ(:); 0], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([tDsPz(1); tDsPz(:); tDsPz(end)], [0; pLoadDsZ(:); 0], ...
    [0.64 0.08 0.18], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsPz, pGridDsZ, 'LineWidth', 1.8, 'Color', [0.47 0.67 0.19]);
plot(tDsPz, pLoadDsZ, 'LineWidth', 1.8, 'Color', [0.64 0.08 0.18]);
plot(tDsPz, pTrDsZ, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
plot(tDsPz, pInDsZ, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
legend('Grid Power', 'Total Load', 'Training', 'Inference', ...
    'Orientation', 'horizontal', 'Location', 'north');
xlabel('Time (s)'); ylabel('Power (MW)');
title('Power Tracking Zoom: grid matches load demand');
xlim(zoomRange);
[yLo, yHi] = hsplot.utils.autoMargin([pGridDsZ; pLoadDsZ; pTrDsZ; pInDsZ]);
ylim([max(yLo,0) yHi]);
grid on; hold off;

% Row 3, Col 1: DC bus voltage - full
nexttile;
hold on;
fill([tDsDcF(1) tDsDcF(end) tDsDcF(end) tDsDcF(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsDcF, vDsDcF, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, zoomRange);
xline(zoomRange(1), ':', eventLabels(1), 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(zoomRange(2), ':', eventLabels(2), 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('DC Bus Voltage (full, \\sigma=%.1fV)', std(vDcF)));
xlim([tDsDcF(1) tDsDcF(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(vDsDcF);
ylim([min(yLo, 755) max(yHi, 845)]);
grid on; hold off;

% Row 3, Col 2: DC bus voltage - zoom
nexttile;
hold on;
fill([tDsDcZ(1) tDsDcZ(end) tDsDcZ(end) tDsDcZ(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsDcZ, vDsDcZ, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('DC Bus Zoom: pp=%.1fV during ramp', max(vDcZ)-min(vDcZ)));
xlim(zoomRange);
[yLo, yHi] = hsplot.utils.autoMargin(vDsDcZ);
ylim([min(yLo, 755) max(yHi, 845)]);
grid on; hold off;

% Row 4, Col 1: Reactive power - full
nexttile;
hold on;
yline(0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
plot(tDsQf, qDsF, 'LineWidth', 1, 'Color', [0.49 0.18 0.56]);
hsplot.utils.highlightZoom(gca, zoomRange);
xline(zoomRange(1), ':', eventLabels(1), 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(zoomRange(2), ':', eventLabels(2), 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Q (MVAr)');
title(sprintf('Reactive Power (full, mean=%.3f MVAr)', mean(qF)));
xlim([tDsQf(1) tDsQf(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(qDsF);
ylim([min(yLo, -0.5) max(yHi, 0.5)]);
grid on; hold off;

% Row 4, Col 2: CHB per-phase DC voltages - zoom
nexttile;
hold on;
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
plot(tDsChbZ, vAdsZ, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
plot(tDsChbZ, vBdsZ, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
plot(tDsChbZ, vCdsZ, 'LineWidth', 1.2, 'Color', [0.47 0.67 0.19]);
legend('Phase A', 'Phase B', 'Phase C', 'Orientation', 'horizontal', 'Location', 'north');
xlabel('Time (s)'); ylabel('Voltage (V)');
maxImbal = max(abs([vAz; vBz; vCz] - 4400));
title(sprintf('CHB DC Bus Zoom: max imbalance = %.0fV', maxImbal));
xlim(zoomRange);
[yLo, yHi] = hsplot.utils.autoMargin([vAdsZ; vBdsZ; vCdsZ]);
ylim([min(yLo, 4200) max(yHi, 4600)]);
grid on; hold off;

sgtitle('SST Dynamic Regulation Performance', 'FontSize', 14);
end
