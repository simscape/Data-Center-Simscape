function powerVsUtilization(simOut, timeRange)
%POWERVSUTILIZATION Scatter plot of power vs utilization with expected curve.
%
%   hsplot.powerVsUtilization(simOut) creates scatter plot with Fan/Barroso curve.
%
%   hsplot.powerVsUtilization(simOut, timeRange) limits data to [tStart tStop].

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    timeRange (1,2) double = [1 inf]
end

P_train = simOut.logsout.get('PtrainW').Values;
P_infer = simOut.logsout.get('PinferW').Values;
uTrain = simOut.logsout.get('Utrain').Values;
uInfer = simOut.logsout.get('Uinfer').Values;

tStart = max(timeRange(1), P_train.Time(1));
tStop = min(timeRange(2), P_train.Time(end));

t_common = linspace(tStart, tStop, 2000)';
uTr = interp1(uTrain.Time, double(uTrain.Data), t_common, 'previous');
uIn = interp1(uInfer.Time, double(uInfer.Data), t_common, 'previous');
pTr = interp1(P_train.Time, double(P_train.Data), t_common);
pIn = interp1(P_infer.Time, double(P_infer.Data), t_common);

rTr = corrcoef(uTr, pTr); rTr = rTr(1,2);
rIn = corrcoef(uIn, pIn); rIn = rIn(1,2);

nGPU = 576;
nTrays = 4;
TDP = 2500;
idle = 375;
P_aux = 72000 + 10000;
eta = 0.983 * 0.92;

U_vec = linspace(0, 1, 200);
P_gpu = idle + (TDP - idle) * (2*U_vec - U_vec.^1.4);
P_rack = nTrays * (nGPU * P_gpu + P_aux) / eta / 1e6;

P_idle = nTrays * (nGPU * idle + P_aux) / eta / 1e6;
P_tdp = nTrays * (nGPU * TDP + P_aux) / eta / 1e6;
P_linear = nTrays * (nGPU * (idle + (TDP-idle)*U_vec) + P_aux) / eta / 1e6;

fig = figure('Name', 'Power vs Utilization');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 850 550]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Left: Main scatter + model
nexttile;
hold on;

fill([U_vec fliplr(U_vec)], [P_linear fliplr(P_rack)], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');

plot(U_vec, P_linear, ':', 'LineWidth', 1, 'Color', [0.6 0.6 0.6]);
plot(U_vec, P_rack, 'k-', 'LineWidth', 2.5);

scatter(uTr, pTr/1e6, 12, [0.85 0.33 0.10], 'filled', 'MarkerFaceAlpha', 0.5);
scatter(uIn, pIn/1e6, 12, [0.00 0.45 0.74], 'filled', 'MarkerFaceAlpha', 0.5);

yline(P_idle, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
yline(P_tdp, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');

text(0.02, P_idle+0.02, sprintf('Idle: %.2f MW', P_idle), 'FontSize', 8, 'Color', [0.4 0.4 0.4]);
text(0.02, P_tdp+0.02, sprintf('TDP: %.2f MW', P_tdp), 'FontSize', 8, 'Color', [0.4 0.4 0.4]);

xlabel('GPU Utilization');
ylabel('Rack Power (MW)');
title('Power vs Utilization — Fan/Barroso Model');
legend('Linear (reference)', 'Fan/Barroso (nonlinear)', ...
    sprintf('Training (r=%.3f)', rTr), sprintf('Inference (r=%.3f)', rIn), ...
    'Location', 'southeast');
xlim([0 1.05]);
ylim([0 P_tdp*1.08]);
grid on;
hold off;

% Right: Per-GPU breakdown
nexttile;
hold on;

P_gpu_W = idle + (TDP - idle) * (2*U_vec - U_vec.^1.4);
P_gpu_linear = idle + (TDP - idle) * U_vec;
P_gpu_excess = P_gpu_W - P_gpu_linear;

fill([U_vec fliplr(U_vec)], [P_gpu_linear fliplr(P_gpu_W)], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.12, 'EdgeColor', 'none');
plot(U_vec, P_gpu_linear, ':', 'LineWidth', 1, 'Color', [0.6 0.6 0.6]);
plot(U_vec, P_gpu_W, 'k-', 'LineWidth', 2);

yline(idle, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
yline(TDP, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');

text(0.02, idle+30, sprintf('Idle: %dW', idle), 'FontSize', 8, 'Color', [0.4 0.4 0.4]);
text(0.02, TDP+30, sprintf('TDP: %dW', TDP), 'FontSize', 8, 'Color', [0.4 0.4 0.4]);

[~, iMax] = max(P_gpu_excess);
plot(U_vec(iMax), P_gpu_W(iMax), 'rv', 'MarkerSize', 8, 'MarkerFaceColor', [0.85 0.33 0.10]);
text(U_vec(iMax)+0.03, P_gpu_W(iMax), ...
    sprintf('Max excess: +%dW\n@ U=%.0f%%', round(P_gpu_excess(iMax)), U_vec(iMax)*100), ...
    'FontSize', 8, 'Color', [0.85 0.33 0.10]);

xlabel('GPU Utilization');
ylabel('Per-GPU Power (W)');
title('P_{gpu} = 375 + 2125 \times (2U - U^{1.4})');
legend('Nonlinear excess', 'Linear model', 'Fan/Barroso', 'Location', 'southeast');
xlim([0 1.05]);
ylim([0 TDP*1.1]);
grid on;
hold off;

sgtitle(sprintf('Fan/Barroso Power Model (%d trays \\times %d GPUs, Rubin Ultra %dW TDP)', nTrays, nGPU, TDP), 'FontSize', 13);
end
