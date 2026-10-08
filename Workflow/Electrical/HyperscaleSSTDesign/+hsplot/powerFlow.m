function powerFlow(simOut, zoomRange, timeRange)
%POWERFLOW Plot power flow: grid, training rack, inference rack, total load.
%
%   hsplot.powerFlow(simOut) plots all power traces with shaded fills.
%
%   hsplot.powerFlow(simOut, zoomRange) adds a zoomed subplot.
%
%   hsplot.powerFlow(simOut, zoomRange, [tStart tStop]) sets full-range limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

P_train = simOut.logsout.get('PtrainW').Values;
P_infer = simOut.logsout.get('PinferW').Values;
P_grid = simOut.logsout.get('pGrid').Values;

tStart = max(timeRange(1), P_train.Time(1));
tStop = min(timeRange(2), P_train.Time(end));

[tPlot, idx] = hsplot.utils.sliceTime(P_train.Time, tStart, tStop);
pTr = double(P_train.Data(idx)) / 1e6;
pIn = double(P_infer.Data(idx)) / 1e6;

[~, idxG] = hsplot.utils.sliceTime(P_grid.Time, tStart, tStop);
pGrid = double(P_grid.Data(idxG));

maxPts = 2000;
[tDs, pTrDs, pInDs, pGDs] = hsplot.utils.downsample(tPlot, maxPts, pTr, pIn, pGrid);

colors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19];
labels = {'Grid (total)', 'Training Rack', 'Inference Rack'};

hasZoom = ~isempty(zoomRange);
numCols = 1 + hasZoom;

fig = figure('Name', 'Power Flow');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 900 350]);
end
tiledlayout(1, numCols, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
hold on;
tCol = tDs(:);
allData = [pGDs(:)'; pTrDs(:)'; pInDs(:)'];
for k = 1:3
    yCol = allData(k,:)';
    fill([tCol(1); tCol; tCol(end)], [0; yCol; 0], ...
        colors(k,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tCol, yCol, 'LineWidth', 1.2, 'Color', colors(k,:));
end
xlabel('Time (s)'); ylabel('Power (MW)');
title('Active Power');
xlim([tDs(1) tDs(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(allData);
ylim([yLo yHi]);
if hasZoom
    hsplot.utils.highlightZoom(gca, zoomRange);
end
grid on;
hold off;

if hasZoom
    nexttile;
    hold on;
    [~, zIdx] = hsplot.utils.sliceTime(P_train.Time, zoomRange(1), zoomRange(2));
    pTrZ = double(P_train.Data(zIdx)) / 1e6;
    pInZ = double(P_infer.Data(zIdx)) / 1e6;
    tZ = P_train.Time(zIdx);
    [~, zIdxG] = hsplot.utils.sliceTime(P_grid.Time, zoomRange(1), zoomRange(2));
    pGZ = double(P_grid.Data(zIdxG));
    [tZd, pTrZd, pInZd, pGZd] = hsplot.utils.downsample(tZ, maxPts, pTrZ, pInZ, pGZ);
    allZoom = [pGZd(:)'; pTrZd(:)'; pInZd(:)'];
    for k = 1:3
        plot(tZd, allZoom(k,:), 'LineWidth', 1.2, 'Color', colors(k,:));
    end
    xlabel('Time (s)'); ylabel('Power (MW)');
    title(sprintf('Zoom: %.2f–%.2f s', zoomRange(1), zoomRange(2)));
    xlim(zoomRange);
    [yLo, yHi] = hsplot.utils.autoMargin(allZoom);
    ylim([yLo yHi]);
    grid on;
    hold off;
end

lgd = legend(labels, 'Orientation', 'horizontal');
lgd.Layout.Tile = 'north';
sgtitle('Power Flow', 'FontSize', 14);
end
