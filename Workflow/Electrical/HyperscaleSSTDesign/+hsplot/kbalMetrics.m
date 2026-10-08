function kbalMetrics(simOut_kbal, simOut_nokbal)
%KBALMETRICS Post-fault recovery quality: phase spread + 800V bus (1x2 layout).
%
%   Left: Phase voltage spread (max-min) over time with settling annotation.
%   Right: 800V DC bus with +-5% tolerance band.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_kbal
    simOut_nokbal
end

maxPts = 3000;
faultTime = 4.0;
clearTime = 4.1;
spreadThresh = 50;

% --- Extract signals ---
VdcA1 = simOut_kbal.logsout.get('VdcA').Values;
VdcB1 = simOut_kbal.logsout.get('VdcB').Values;
VdcC1 = simOut_kbal.logsout.get('VdcC').Values;
Vdc1 = simOut_kbal.logsout.get('Vdc800V').Values;

VdcA2 = simOut_nokbal.logsout.get('VdcA').Values;
VdcB2 = simOut_nokbal.logsout.get('VdcB').Values;
VdcC2 = simOut_nokbal.logsout.get('VdcC').Values;
Vdc2 = simOut_nokbal.logsout.get('Vdc800V').Values;

% --- Phase spread data (cycle-averaged to remove 120Hz ripple offset) ---
tRange = [3.5 8];
dt1 = VdcA1.Time(2) - VdcA1.Time(1);
nAvg1 = max(1, round(1/(120*dt1)));
dt2 = VdcA2.Time(2) - VdcA2.Time(1);
nAvg2 = max(1, round(1/(120*dt2)));

[t1, idx1] = hsplot.utils.sliceTime(VdcA1.Time, tRange(1), tRange(2));
vA1 = movmean(double(VdcA1.Data(idx1)), nAvg1);
vB1 = movmean(double(VdcB1.Data(idx1)), nAvg1);
vC1 = movmean(double(VdcC1.Data(idx1)), nAvg1);
spread1 = max([vA1, vB1, vC1], [], 2) - min([vA1, vB1, vC1], [], 2);
[tDs1, spreadDs1] = hsplot.utils.downsample(t1, maxPts, spread1);

[t2, idx2] = hsplot.utils.sliceTime(VdcA2.Time, tRange(1), tRange(2));
vA2 = movmean(double(VdcA2.Data(idx2)), nAvg2);
vB2 = movmean(double(VdcB2.Data(idx2)), nAvg2);
vC2 = movmean(double(VdcC2.Data(idx2)), nAvg2);
spread2 = max([vA2, vB2, vC2], [], 2) - min([vA2, vB2, vC2], [], 2);
[tDs2, spreadDs2] = hsplot.utils.downsample(t2, maxPts, spread2);

% --- Settling time for Kbal case ---
settledIdx1 = find(t1 > clearTime & spread1 < spreadThresh, 1, 'first');
if ~isempty(settledIdx1)
    tSettled1 = t1(settledIdx1);
    settlingTime1 = tSettled1 - clearTime;
else
    tSettled1 = [];
    settlingTime1 = NaN;
end

% --- 800V bus data ---
[tDc1, idxDc1] = hsplot.utils.sliceTime(Vdc1.Time, tRange(1), tRange(2));
[tDc2, idxDc2] = hsplot.utils.sliceTime(Vdc2.Time, tRange(1), tRange(2));
vDc1 = double(Vdc1.Data(idxDc1));
vDc2 = double(Vdc2.Data(idxDc2));
[tDsDc1, vDsDc1] = hsplot.utils.downsample(tDc1, maxPts, vDc1);
[tDsDc2, vDsDc2] = hsplot.utils.downsample(tDc2, maxPts, vDc2);

% --- Figure ---
fig = figure('Name', 'Balancing Controller — Recovery Quality');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 120 1300 450]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- Left: Phase voltage spread over time ---
nexttile;
hold on;
fill([faultTime clearTime clearTime faultTime], ...
    [0 0 max([spreadDs1; spreadDs2])*1.1 max([spreadDs1; spreadDs2])*1.1], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([clearTime tRange(2) tRange(2) clearTime], ...
    [0 0 max([spreadDs1; spreadDs2])*1.1 max([spreadDs1; spreadDs2])*1.1], ...
    [0.85 1.0 0.85], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
yline(spreadThresh, '--', sprintf('Threshold (%dV)', spreadThresh), ...
    'Color', [0.5 0.5 0.5], 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
plot(tDs1, spreadDs1, 'LineWidth', 2, 'Color', [0.00 0.45 0.74]);
plot(tDs2, spreadDs2, 'LineWidth', 2, 'Color', [0.85 0.33 0.10]);
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
if ~isempty(tSettled1)
    plot(tSettled1, spreadThresh, 'v', 'MarkerSize', 10, 'MarkerFaceColor', [0.00 0.45 0.74], ...
        'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
    text(tSettled1+0.05, spreadThresh+100, sprintf('Settled: %.2fs', settlingTime1), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.00 0.45 0.74]);
end
xlabel('Time (s)'); ylabel('Phase Spread (V)');
title('CHB Phase Voltage Imbalance (max - min)');
xlim(tRange);
legend('With Balancing', 'Without Balancing', 'Location', 'northeast');
grid on; hold off;

% --- Right: 800V DC bus with tolerance band ---
nexttile;
hold on;
fill([tRange(1) tRange(2) tRange(2) tRange(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.10, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([faultTime clearTime clearTime faultTime], ...
    [700 700 900 900], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
plot(tDsDc1, vDsDc1, 'LineWidth', 2, 'Color', [0.00 0.45 0.74]);
plot(tDsDc2, vDsDc2, 'LineWidth', 2, 'Color', [0.85 0.33 0.10]);
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('800V DC Bus (green = \\pm5%% band)'));
xlim(tRange);
[yLo, yHi] = hsplot.utils.autoMargin([vDsDc1; vDsDc2]);
ylim([min(yLo, 740) max(yHi, 860)]);
legend('With Balancing', 'Without Balancing', 'Location', 'southeast');
grid on; hold off;

sgtitle('Post-Fault Recovery — CHB + DAB Balancing Controller Impact', 'FontSize', 13);
end
