function kbalPhaseShift(simOut_kbal, simOut_nokbal)
%KBALPHASESHIFT DAB phase-shift comparison: per-phase corrections during fault (2x2 layout).
%
%   Top-left: Total phase shift per phase (d_PID + delta_d) with balancing
%   Top-right: Total phase shift per phase without balancing (d_PID only)
%   Bottom-left: DAB balancing corrections (deltaDa/B/C) — shows controller action
%   Bottom-right: CHB DC bus voltages (context for why corrections occur)

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_kbal
    simOut_nokbal
end

maxPts = 3000;
faultTime = 4.0;
clearTime = 4.1;
tRange = [3.5 8];

% --- Extract signals (with balancing) ---
d_total_A = simOut_kbal.logsout.get('dTotalA1').Values;
d_total_B = simOut_kbal.logsout.get('dTotalB1').Values;
d_total_C = simOut_kbal.logsout.get('dTotalC1').Values;
deltaDa = simOut_kbal.logsout.get('deltaDa').Values;
deltaDb = simOut_kbal.logsout.get('deltaDb').Values;
deltaDc = simOut_kbal.logsout.get('deltaDc').Values;
VdcA1 = simOut_kbal.logsout.get('VdcA').Values;
VdcB1 = simOut_kbal.logsout.get('VdcB').Values;
VdcC1 = simOut_kbal.logsout.get('VdcC').Values;

% --- Extract signals (without balancing) ---
d_total_A_nk = simOut_nokbal.logsout.get('dTotalA1').Values;
d_total_B_nk = simOut_nokbal.logsout.get('dTotalB1').Values;
d_total_C_nk = simOut_nokbal.logsout.get('dTotalC1').Values;
VdcA2 = simOut_nokbal.logsout.get('VdcA').Values;
VdcB2 = simOut_nokbal.logsout.get('VdcB').Values;
VdcC2 = simOut_nokbal.logsout.get('VdcC').Values;

% --- Downsample: total phase shift (with balancing) ---
[t1, idx1] = hsplot.utils.sliceTime(d_total_A.Time, tRange(1), tRange(2));
[tDs1, dA1, dB1, dC1] = hsplot.utils.downsample(t1, maxPts, ...
    double(d_total_A.Data(idx1)), double(d_total_B.Data(idx1)), double(d_total_C.Data(idx1)));

% --- Downsample: total phase shift (without balancing) ---
[t2, idx2] = hsplot.utils.sliceTime(d_total_A_nk.Time, tRange(1), tRange(2));
[tDs2, dA2, dB2, dC2] = hsplot.utils.downsample(t2, maxPts, ...
    double(d_total_A_nk.Data(idx2)), double(d_total_B_nk.Data(idx2)), double(d_total_C_nk.Data(idx2)));

% --- Downsample: delta_d corrections ---
[tDd, idxDd] = hsplot.utils.sliceTime(deltaDa.Time, tRange(1), tRange(2));
[tDsDd, ddA, ddB, ddC] = hsplot.utils.downsample(tDd, maxPts, ...
    double(deltaDa.Data(idxDd)), double(deltaDb.Data(idxDd)), double(deltaDc.Data(idxDd)));

% --- Downsample: CHB voltages (cycle-averaged, with balancing, for context) ---
dt = VdcA1.Time(2) - VdcA1.Time(1);
nAvg = max(1, round(1/(120*dt)));
[tV, idxV] = hsplot.utils.sliceTime(VdcA1.Time, tRange(1), tRange(2));
[tDsV, vA1, vB1, vC1] = hsplot.utils.downsample(tV, maxPts, ...
    movmean(double(VdcA1.Data(idxV)), nAvg), ...
    movmean(double(VdcB1.Data(idxV)), nAvg), ...
    movmean(double(VdcC1.Data(idxV)), nAvg));

% --- Figure ---
fig = figure('Name', 'DAB Phase-Shift Balancing');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [80 60 1400 700]);
end
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

colors = {[0.85 0.33 0.10], [0.00 0.45 0.74], [0.47 0.67 0.19]};

% --- Top-left: Total phase shift WITH balancing ---
nexttile;
hold on;
fill([faultTime clearTime clearTime faultTime], [-0.5 -0.5 0.5 0.5], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs1, dA1, 'LineWidth', 1.5, 'Color', colors{1});
plot(tDs1, dB1, 'LineWidth', 1.5, 'Color', colors{2});
plot(tDs1, dC1, 'LineWidth', 1.5, 'Color', colors{3});
yline(0.45, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(-0.45, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Phase Shift (d)');
title('DAB Phase Shift — WITH Balancing');
xlim(tRange); ylim([-0.5 0.5]);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'southeast');
grid on; hold off;

% --- Top-right: Total phase shift WITHOUT balancing ---
nexttile;
hold on;
fill([faultTime clearTime clearTime faultTime], [-0.5 -0.5 0.5 0.5], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs2, dA2, 'LineWidth', 1.5, 'Color', colors{1});
plot(tDs2, dB2, 'LineWidth', 1.5, 'Color', colors{2});
plot(tDs2, dC2, 'LineWidth', 1.5, 'Color', colors{3});
yline(0.45, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(-0.45, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Phase Shift (d)');
title('DAB Phase Shift — WITHOUT Balancing');
xlim(tRange); ylim([-0.5 0.5]);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'southeast');
grid on; hold off;

% --- Bottom-left: delta_d corrections (balancing action) ---
nexttile;
hold on;
fill([faultTime clearTime clearTime faultTime], [-0.2 -0.2 0.2 0.2], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsDd, ddA, 'LineWidth', 2, 'Color', colors{1});
plot(tDsDd, ddB, 'LineWidth', 2, 'Color', colors{2});
plot(tDsDd, ddC, 'LineWidth', 2, 'Color', colors{3});
yline(0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('\Delta d');
title('DAB Balancing Correction (\Delta d = K_{p,bal} \cdot (V_{dc,phase} - V_{dc,avg}))');
xlim(tRange);
[yLo, yHi] = hsplot.utils.autoMargin([ddA; ddB; ddC]);
ylim([min(yLo, -0.02) max(yHi, 0.02)]);
legend('\Delta d_A', '\Delta d_B', '\Delta d_C', 'Location', 'northeast');
grid on; hold off;

% --- Bottom-right: CHB DC voltages (context) ---
nexttile;
hold on;
fill([faultTime clearTime clearTime faultTime], [0 0 9000 9000], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsV, vA1, 'LineWidth', 1.5, 'Color', colors{1});
plot(tDsV, vB1, 'LineWidth', 1.5, 'Color', colors{2});
plot(tDsV, vC1, 'LineWidth', 1.5, 'Color', colors{3});
yline(4400, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('CHB DC Bus Voltages (with balancing)');
xlim(tRange);
[yLo, yHi] = hsplot.utils.autoMargin([vA1; vB1; vC1]);
ylim([max(yLo, 0) yHi]);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'northeast');
grid on; hold off;

sgtitle('DAB Inter-Phase Balancing — Phase-Shift Corrections During L-G Fault', 'FontSize', 13);
end
