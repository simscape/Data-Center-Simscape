function powerFlowUPS(logsout,zoomRange,timeRange)
% powerFlowUPS  Plot active power flow for each UPS unit.
%
%   plot.powerFlowUPS(logsout) plots active power for UPS1, UPS2, and
%   UPS3 with shaded fills under each trace and dark-mode-friendly colors.
%   Y-axes are auto-scaled with 10% margin.
%
%   plot.powerFlowUPS(logsout, zoomRange) adds a side-by-side zoomed
%   subplot (1x2 layout). zoomRange = [tStart tStop] specifies the zoom
%   window. A dashed rectangle on the full-range plot marks the region.
%
%   plot.powerFlowUPS(logsout, zoomRange, 'tStart', val, 'tStop', val)
%   overrides the default full-range plotting limits.
%
%   Required logsout signals: 'activePowerUPS1', 'activePowerUPS2',
%   'activePowerUPS3'
%
%   Examples:
%     plot.powerFlowUPS(logsout)
%     plot.powerFlowUPS(logsout, [2 4])
%     plot.powerFlowUPS(logsout, [2 4], 'tStart', 0.1, 'tStop', 10)

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    zoomRange double = [];
    timeRange.tStart double = 0.1;
    timeRange.tStop double = 10;
end

fig = figure('Name', 'UPS Power Flow');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 1200 500]);
end

maxPts = 2000;
upsNames = {'UPS1','UPS2','UPS3'};
colors = [
    0.00 0.45 0.74;
    0.85 0.33 0.10;
    0.47 0.67 0.19;
];

timeData = logsout.get('activePowerUPS1').Values.Time;
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
powerData = zeros(length(upsNames), nIdx);
for unitIdx = 1:length(upsNames)
    powerVar = strcat('activePower', upsNames{unitIdx});
    raw = logsout.get(powerVar).Values.Data;
    powerData(unitIdx,:) = reshape(raw(timeIdx), 1, []);
end

[tPd, pPd] = plot.utils.downsample(tPlot, maxPts, powerData);

[pMin, pMax] = plot.utils.autoMargin(pPd);

%% Full-range Active Power
subplot(1, numCols, 1);
hold on
if hasZoom
    shadeMask = tPd >= zoomRange(1) & tPd <= zoomRange(2);
    tShade = tPd(shadeMask);
else
    tShade = tPd;
    shadeMask = true(size(tPd));
end
for unitIdx = 1:length(upsNames)
    pData = pPd(unitIdx,:);
    pShade = pData(shadeMask);
    fill([tShade(1); tShade(:); tShade(end)], [0; pShade(:); 0], ...
        colors(unitIdx,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tPd, pData, 'LineWidth', 1.5, 'Color', colors(unitIdx,:));
end
title('Active Power')
ylabel('Power (pu)')
xlabel('Time (s)')
legend(upsNames, 'Location', 'best');
xlim([tStart, tStop]);
ylim([pMin, pMax]);
grid on;

if hasZoom
    plot.utils.highlightZoom(gca, zoomRange);

    %% Zoomed Active Power
    subplot(1, numCols, 2);
    hold on
    zoomMask = tPlot > zoomRange(1) & tPlot < zoomRange(2);
    tZoom = tPlot(zoomMask);
    pZoomData = powerData(:, zoomMask);
    [tZd, pZd] = plot.utils.downsample(tZoom, maxPts, pZoomData);

    for unitIdx = 1:length(upsNames)
        plot(tZd, pZd(unitIdx,:), 'LineWidth', 1.5, 'Color', colors(unitIdx,:));
    end

    [zpMin, zpMax] = plot.utils.autoMargin(pZd);
    title(sprintf('Active Power (%.1fs - %.1fs)', zoomRange(1), zoomRange(2)))
    ylabel('Power (pu)')
    xlabel('Time (s)')
    legend(upsNames, 'Location', 'best');
    xlim([zoomRange(1), zoomRange(2)]);
    ylim([zpMin, zpMax]);
    grid on;
end

sgtitle('UPS Power Flow','Fontsize',15);
end
