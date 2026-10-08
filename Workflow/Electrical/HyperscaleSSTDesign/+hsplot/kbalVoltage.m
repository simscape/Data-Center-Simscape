function kbalVoltage(simOut_kbal, simOut_nokbal, tRange, faultZoom)
%KBALVOLTAGE CHB voltage comparison: with vs without balancing (2x2 layout).
%
%   Row 1: Full timeline CHB per-phase voltages (with | without)
%   Row 2: Fault zoom with region shading

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_kbal
    simOut_nokbal
    tRange (1,2) double = [3.5 8]
    faultZoom (1,2) double = [3.9 4.8]
end

maxPts = 3000;
faultTime = 4.0;
clearTime = 4.1;

% --- Extract signals ---
VdcA1 = simOut_kbal.logsout.get('VdcA').Values;
VdcB1 = simOut_kbal.logsout.get('VdcB').Values;
VdcC1 = simOut_kbal.logsout.get('VdcC').Values;
VdcA2 = simOut_nokbal.logsout.get('VdcA').Values;
VdcB2 = simOut_nokbal.logsout.get('VdcB').Values;
VdcC2 = simOut_nokbal.logsout.get('VdcC').Values;

% --- Cycle-average filter (removes 120Hz ripple, shows true DC) ---
dt1 = VdcA1.Time(2) - VdcA1.Time(1);
nAvg1 = max(1, round(1/(120*dt1)));
dt2 = VdcA2.Time(2) - VdcA2.Time(1);
nAvg2 = max(1, round(1/(120*dt2)));

% --- Full-range data (cycle-averaged) ---
[t1, idx1] = hsplot.utils.sliceTime(VdcA1.Time, tRange(1), tRange(2));
vA1 = movmean(double(VdcA1.Data(idx1)), nAvg1);
vB1 = movmean(double(VdcB1.Data(idx1)), nAvg1);
vC1 = movmean(double(VdcC1.Data(idx1)), nAvg1);
[tDs1, vAds1, vBds1, vCds1] = hsplot.utils.downsample(t1, maxPts, vA1, vB1, vC1);

[t2, idx2] = hsplot.utils.sliceTime(VdcA2.Time, tRange(1), tRange(2));
vA2 = movmean(double(VdcA2.Data(idx2)), nAvg2);
vB2 = movmean(double(VdcB2.Data(idx2)), nAvg2);
vC2 = movmean(double(VdcC2.Data(idx2)), nAvg2);
[tDs2, vAds2, vBds2, vCds2] = hsplot.utils.downsample(t2, maxPts, vA2, vB2, vC2);

% --- Fault-zoom data (cycle-averaged) ---
[tZ1, idxZ1] = hsplot.utils.sliceTime(VdcA1.Time, faultZoom(1), faultZoom(2));
vAz1 = movmean(double(VdcA1.Data(idxZ1)), nAvg1);
vBz1 = movmean(double(VdcB1.Data(idxZ1)), nAvg1);
vCz1 = movmean(double(VdcC1.Data(idxZ1)), nAvg1);
[tDsZ1, vAdsZ1, vBdsZ1, vCdsZ1] = hsplot.utils.downsample(tZ1, maxPts, vAz1, vBz1, vCz1);

[tZ2, idxZ2] = hsplot.utils.sliceTime(VdcA2.Time, faultZoom(1), faultZoom(2));
vAz2 = movmean(double(VdcA2.Data(idxZ2)), nAvg2);
vBz2 = movmean(double(VdcB2.Data(idxZ2)), nAvg2);
vCz2 = movmean(double(VdcC2.Data(idxZ2)), nAvg2);
[tDsZ2, vAdsZ2, vBdsZ2, vCdsZ2] = hsplot.utils.downsample(tZ2, maxPts, vAz2, vBz2, vCz2);

% --- Figure ---
fig = figure('Name', 'Balancing Controller — CHB Voltage');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 80 1400 650]);
end
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Row 1, Col 1: Full — WITH Kbal
nexttile;
hold on;
plot(tDs1, vAds1, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
plot(tDs1, vBds1, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
plot(tDs1, vCds1, 'LineWidth', 1.2, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, ':', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(clearTime, ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('CHB DC Bus — WITH Balancing (CHB + DAB)');
xlim(tRange); ylim([0 9000]);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'northeast');
grid on; hold off;

% Row 1, Col 2: Full — WITHOUT balancing
nexttile;
hold on;
plot(tDs2, vAds2, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
plot(tDs2, vBds2, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
plot(tDs2, vCds2, 'LineWidth', 1.2, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, ':', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(clearTime, ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('CHB DC Bus — WITHOUT Balancing');
xlim(tRange); ylim([0 9000]);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'northeast');
grid on; hold off;

% Row 2, Col 1: Fault zoom — WITH Kbal (recovers)
nexttile;
hold on;
yLims = [min([vAdsZ1; vBdsZ1; vCdsZ1])-200, max([vAdsZ1; vBdsZ1; vCdsZ1])+200];
fill([faultTime clearTime clearTime faultTime], ...
    [yLims(1) yLims(1) yLims(2) yLims(2)], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([clearTime faultZoom(2) faultZoom(2) clearTime], ...
    [yLims(1) yLims(1) yLims(2) yLims(2)], ...
    [0.85 1.0 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsZ1, vAdsZ1, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
plot(tDsZ1, vBdsZ1, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDsZ1, vCdsZ1, 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Fault Zoom — WITH Balancing (CHB + DAB)');
xlim(faultZoom); ylim(yLims);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'best');
grid on; hold off;

% Row 2, Col 2: Fault zoom — WITHOUT Kbal (diverges)
nexttile;
hold on;
yLims2 = [min([vAdsZ2; vBdsZ2; vCdsZ2])-200, max([vAdsZ2; vBdsZ2; vCdsZ2])+200];
fill([faultTime clearTime clearTime faultTime], ...
    [yLims2(1) yLims2(1) yLims2(2) yLims2(2)], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([clearTime faultZoom(2) faultZoom(2) clearTime], ...
    [yLims2(1) yLims2(1) yLims2(2) yLims2(2)], ...
    [0.85 1.0 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsZ2, vAdsZ2, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
plot(tDsZ2, vBdsZ2, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDsZ2, vCdsZ2, 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19]);
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Fault Zoom — WITHOUT Balancing');
xlim(faultZoom); ylim(yLims2);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'best');
grid on; hold off;

sgtitle('CHB + DAB Balancing — Voltage Response', 'FontSize', 14);
end
