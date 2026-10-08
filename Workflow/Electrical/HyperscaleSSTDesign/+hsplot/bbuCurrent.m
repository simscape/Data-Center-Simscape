function bbuCurrent(simOut, zoomRange, timeRange)
%BBUCURRENT Plot BBU current injection for both racks.
%
%   hsplot.bbuCurrent(simOut) plots BBU current reference (supercap+battery)
%   for training and inference racks as subplots.
%
%   hsplot.bbuCurrent(simOut, zoomRange) adds zoomed subplots.
%
%   hsplot.bbuCurrent(simOut, zoomRange, [tStart tStop]) sets time limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

BattIref = simOut.logsout.get('BattIrefTrain').Values;
BattIrefInfer = simOut.logsout.get('BattIrefInfer').Values;

tStart = max(timeRange(1), BattIref.Time(1));
tStop = min(timeRange(2), BattIref.Time(end));

[tPlot1, idx1] = hsplot.utils.sliceTime(BattIref.Time, tStart, tStop);
i1 = double(BattIref.Data(idx1));

[tPlot2, idx2] = hsplot.utils.sliceTime(BattIrefInfer.Time, tStart, tStop);
i2 = double(BattIrefInfer.Data(idx2));

maxPts = 2000;
[tDs1, iDs1] = hsplot.utils.downsample(tPlot1, maxPts, i1);
[tDs2, iDs2] = hsplot.utils.downsample(tPlot2, maxPts, i2);

hasZoom = ~isempty(zoomRange);

fig = figure('Name', 'BBU Current');
if hasZoom
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 100 1200 500]);
    end
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
else
    if length(dbstack) > 1
        set(fig, 'Units', 'pixels', 'Position', [100 100 1200 400]);
    end
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
end

% Training BBU - full
nexttile;
hold on;
fill([tDs1(1); tDs1(:); tDs1(end)], [0; iDs1(:); 0], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs1, iDs1, 'LineWidth', 1, 'Color', [0.85 0.33 0.10]);
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Current (A)');
title('Training Rack BBU');
xlim([tDs1(1) tDs1(end)]);
grid on;
hold off;

% Training BBU - zoom
if hasZoom
    nexttile;
    hold on;
    [tZ, zIdx] = hsplot.utils.sliceTime(BattIref.Time, zoomRange(1), zoomRange(2));
    iZ = double(BattIref.Data(zIdx));
    [tZd, iZd] = hsplot.utils.downsample(tZ, maxPts, iZ);
    fill([tZd(1); tZd(:); tZd(end)], [0; iZd(:); 0], ...
        [0.85 0.33 0.10], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    plot(tZd, iZd, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
    yline(0, '-', 'Color', [0.7 0.7 0.7]);
    xlabel('Time (s)'); ylabel('Current (A)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on;
    hold off;
end

% Inference BBU - full
nexttile;
hold on;
fill([tDs2(1); tDs2(:); tDs2(end)], [0; iDs2(:); 0], ...
    [0.00 0.45 0.74], 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs2, iDs2, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
if hasZoom, hsplot.utils.highlightZoom(gca, zoomRange); end
xlabel('Time (s)'); ylabel('Current (A)');
title('Inference Rack BBU');
xlim([tDs2(1) tDs2(end)]);
grid on;
hold off;

% Inference BBU - zoom
if hasZoom
    nexttile;
    hold on;
    [tZ2, zIdx2] = hsplot.utils.sliceTime(BattIrefInfer.Time, zoomRange(1), zoomRange(2));
    iZ2 = double(BattIrefInfer.Data(zIdx2));
    [tZd2, iZd2] = hsplot.utils.downsample(tZ2, maxPts, iZ2);
    fill([tZd2(1); tZd2(:); tZd2(end)], [0; iZd2(:); 0], ...
        [0.00 0.45 0.74], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    plot(tZd2, iZd2, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
    yline(0, '-', 'Color', [0.7 0.7 0.7]);
    xlabel('Time (s)'); ylabel('Current (A)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange); grid on;
    hold off;
end

sgtitle('BBU Current Injection (positive = discharging into bus)', 'FontSize', 14);
end
