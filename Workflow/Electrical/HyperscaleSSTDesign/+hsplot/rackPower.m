function rackPower(simOut, timeRange)
%RACKPOWER Plot training and inference rack power with expected bounds.
%
%   hsplot.rackPower(simOut) plots power for both racks.
%
%   hsplot.rackPower(simOut, timeRange) limits to [tStart tStop].

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    timeRange (1,2) double = [1 inf]
end

P_train = simOut.logsout.get('PtrainW').Values;
P_infer = simOut.logsout.get('PinferW').Values;

tStart = max(timeRange(1), P_train.Time(1));
tStop = min(timeRange(2), P_train.Time(end));

[tPlot, idx] = hsplot.utils.sliceTime(P_train.Time, tStart, tStop);
pTr = double(P_train.Data(idx)) / 1e6;

[~, idx2] = hsplot.utils.sliceTime(P_infer.Time, tStart, tStop);
pIn = double(P_infer.Data(idx2)) / 1e6;

maxPts = 2000;
[tDs, pTrDs, pInDs] = hsplot.utils.downsample(tPlot, maxPts, pTr, pIn);

fig = figure('Name', 'Rack Power');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 900 350]);
end

ax = axes(fig);
hold(ax, 'on');

plot(ax, tDs, pTrDs, 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
plot(ax, tDs, pInDs, 'Color', [0.00 0.45 0.74], 'LineWidth', 1);
yline(ax, 1.68, '--', 'U=1.0', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);
yline(ax, 0.33, '--', 'U=0.0', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);

xlabel(ax, 'Time (s)');
ylabel(ax, 'Power (MW)');
title(ax, 'IT Tray Power (1 of 4 trays per Kyber rack)');
legend(ax, 'Training', 'Inference', 'Location', 'best');
xlim(ax, [tDs(1) tDs(end)]);
hold(ax, 'off');
end
