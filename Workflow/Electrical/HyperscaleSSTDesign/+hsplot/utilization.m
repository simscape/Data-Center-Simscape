function utilization(simOut, timeRange)
%UTILIZATION Plot GPU utilization profiles for training and inference racks.
%
%   hsplot.utilization(simOut) plots utilization from simulation output.
%
%   hsplot.utilization(simOut, timeRange) limits to [tStart tStop].

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    timeRange (1,2) double = [1 inf]
end

uTrain = simOut.logsout.get('Utrain').Values;
uInfer = simOut.logsout.get('Uinfer').Values;

tStart = max(timeRange(1), uTrain.Time(1));
tStop = min(timeRange(2), uTrain.Time(end));

[tPlot, idx] = hsplot.utils.sliceTime(uTrain.Time, tStart, tStop);
uTr = double(uTrain.Data(idx));

[~, idx2] = hsplot.utils.sliceTime(uInfer.Time, tStart, tStop);
uIn = double(uInfer.Data(idx2));

maxPts = 2000;
[tDs, uTrDs, uInDs] = hsplot.utils.downsample(tPlot, maxPts, uTr, uIn);

fig = figure('Name', 'GPU Utilization');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 1000 350]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
hold on;
fill([tDs(1); tDs(:); tDs(end)], [0; uTrDs(:); 0], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs, uTrDs, 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
xlabel('Time (s)'); ylabel('Utilization');
title('Training Rack');
ylim([0 1.1]); xlim([tDs(1) tDs(end)]);
grid on; hold off;

nexttile;
hold on;
fill([tDs(1); tDs(:); tDs(end)], [0; uInDs(:); 0], ...
    [0.00 0.45 0.74], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs, uInDs, 'Color', [0.00 0.45 0.74], 'LineWidth', 1);
xlabel('Time (s)'); ylabel('Utilization');
title('Inference Rack');
ylim([0 1.1]); xlim([tDs(1) tDs(end)]);
grid on; hold off;

sgtitle('GPU Utilization Profiles', 'FontSize', 14);
end
