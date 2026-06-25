function powerFlow(logsout,zoomRange,timeRange)
% powerFlow  Plot active power flow in the data center microgrid.
%
%   plot.powerFlow(logsout) plots active power for Grid, Load, UPS, and
%   Generator with shaded fills under each trace and dark-mode-friendly
%   colors. Y-axes are auto-scaled with 10% margin.
%
%   plot.powerFlow(logsout, zoomRange) adds a side-by-side zoomed
%   subplot (1x2 layout). zoomRange = [tStart tStop] specifies the zoom
%   window. A dashed rectangle on the full-range plot marks the region.
%
%   plot.powerFlow(logsout, zoomRange, 'tStart', val, 'tStop', val)
%   overrides the default full-range plotting limits.
%
%   Required logsout signals: 'gridActivePower', 'loadActivePower',
%   'VdcUPS1', 'IDCDC1', 'generatorActivePower'
%
%   Examples:
%     plot.powerFlow(logsout)
%     plot.powerFlow(logsout, [2 4])
%     plot.powerFlow(logsout, [2 4], 'tStart', 0.5, 'tStop', 10)

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    zoomRange double = [];
    timeRange.tStart double = 0.5;
    timeRange.tStop double = 10;
end

fig = figure('Name', 'Power flow in microgrid');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 900 300]);
end

maxPts = 2000;
powerMeasurement = {'grid','load','battery','generator'};
legendLabels = {'Grid','Load','Battery','Generator'};
colors = [
    0.00 0.45 0.74;
    0.85 0.33 0.10;
    0.47 0.67 0.19;
    0.93 0.69 0.13;
];

timeData = logsout.get('gridActivePower').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, timeRange.tStart, timeRange.tStop);
tStart = tPlot(1);
tStop = tPlot(end);

hasZoom = ~isempty(zoomRange);
if hasZoom
    numCols = 2;
else
    numCols = 1;
end

%% Pre-fetch all power data
nIdx = sum(timeIdx);
powerData = zeros(length(powerMeasurement), nIdx);
for plotIdx = 1:length(powerMeasurement)
    if strcmp(powerMeasurement{plotIdx}, 'battery')
        vdc = logsout.get('VdcUPS1').Values.Data * 800;
        idcdc = logsout.get('IDCDC1').Values.Data;
        raw = abs(vdc .* idcdc) / 1e6;
    else
        powerVar = strcat(powerMeasurement{plotIdx},'ActivePower');
        raw = logsout.get(powerVar).Values.Data;
    end
    powerData(plotIdx,:) = reshape(raw(timeIdx), 1, []);
end

[tPd, pPd] = plot.utils.downsample(tPlot, maxPts, powerData);

[pMin, pMax] = plot.utils.autoMargin(pPd);

%% Layout
tiledlayout(1, numCols, 'TileSpacing', 'compact', 'Padding', 'compact');

%% Full-range Active Power
nexttile
hold on
if hasZoom
    shadeMask = tPd >= zoomRange(1) & tPd <= zoomRange(2);
    tShade = tPd(shadeMask);
else
    tShade = tPd;
    shadeMask = true(size(tPd));
end
for plotIdx = 1:length(powerMeasurement)
    pData = pPd(plotIdx,:);
    pShade = pData(shadeMask);
    fill([tShade(1); tShade(:); tShade(end)], [0; pShade(:); 0], ...
        colors(plotIdx,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tPd, pData, 'LineWidth', 1.5, 'Color', colors(plotIdx,:));
end
title('Active Power')
ylabel('Power (MW)')
xlabel('Time (s)')
xlim([tStart,tStop]);
ylim([pMin, pMax]);
grid on;

if hasZoom
    plot.utils.highlightZoom(gca, zoomRange);
end
hold off;
if hasZoom

    %% Zoomed Active Power
    nexttile
    hold on
    zoomMask = tPlot > zoomRange(1) & tPlot < zoomRange(2);
    tZoom = tPlot(zoomMask);
    pZoomData = powerData(:, zoomMask);
    [tZd, pZd] = plot.utils.downsample(tZoom, maxPts, pZoomData);

    for plotIdx = 1:length(powerMeasurement)
        plot(tZd, pZd(plotIdx,:), 'LineWidth', 1.5, 'Color', colors(plotIdx,:));
    end

    [zpMin, zpMax] = plot.utils.autoMargin(pZd);
    title(sprintf('Active Power (%.1fs - %.1fs)', zoomRange(1), zoomRange(2)))
    ylabel('Power (MW)')
    xlabel('Time (s)')
    xlim([zoomRange(1), zoomRange(2)]);
    ylim([zpMin, zpMax]);
    grid on;
    hold off;
end

lgd = legend(legendLabels, 'Orientation', 'horizontal');
lgd.Layout.Tile = 'north';

sgtitle('Power Flow in Data Center','Fontsize',15);
end
