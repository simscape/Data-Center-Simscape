function lvrtRangeDefinition(gridCode, faultStartTime)
%LVRTRANGEDEFINITION Plot LVRT staircase with OCP SST range shading.
%
%   hsplot.lvrtRangeDefinition(gridCode, faultStartTime) plots the staircase
%   voltage profile on a logarithmic cycles axis with shaded zones above
%   the staircase indicating SST/storage ride-through requirements.

% Copyright 2026 The MathWorks, Inc.

arguments
    gridCode struct
    faultStartTime (1,1) double %#ok<INUSA> — kept for call-site compatibility
end

voltagePu = gridCode.voltagePu;
faultTime = gridCode.faultTime;

% Convert relative times to cycles (60 Hz)
cycles = faultTime * 60;
nBp = numel(cycles);

% Build cumulative cycle breakpoints and voltage levels for staircase
% Each segment holds its voltage from the start cycle to the next breakpoint
cyc_edges = cycles(:)';
cyc_edges(end+1) = cyc_edges(end) + 30; % extend past last point

% Build staircase vectors
cyc_stair = zeros(1, 2*nBp);
vol_stair = zeros(1, 2*nBp);
for k = 1:nBp
    cyc_stair(2*k-1) = cyc_edges(k);
    cyc_stair(2*k)   = cyc_edges(k+1);
    vol_stair(2*k-1) = voltagePu(k);
    vol_stair(2*k)   = voltagePu(k);
end

% Replace any zero cycles with small value for log scale
cyc_stair(cyc_stair <= 0) = 0.3;
cyc_edges(cyc_edges <= 0) = 0.3;

xLim = [0.3, cyc_edges(end)];
yMax = 1.2;

% Zone colors
colRange2 = [0.85 0.33 0.10]; % < 0.5 pu
colRange1 = [0.93 0.69 0.13]; % 0.5 - 0.9 pu
colNormal = [0.47 0.67 0.19]; % >= 0.9 pu

fig = figure('Name', 'OCP SST Range Definitions');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [80 60 1000 600]);
end
ax = axes(fig);
hold(ax, 'on');

% Shade ABOVE the staircase up to yMax with zone colors
for k = 1:nBp
    x1 = cyc_edges(k);
    x2 = cyc_edges(k+1);
    yBot = voltagePu(k);

    % Range 2 portion (yBot to 0.5)
    if yBot < 0.5
        fill(ax, [x1 x2 x2 x1], [yBot yBot 0.5 0.5], ...
            colRange2, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end

    % Range 1 portion (max(yBot,0.5) to 0.9)
    if yBot < 0.9
        yBot1 = max(yBot, 0.5);
        fill(ax, [x1 x2 x2 x1], [yBot1 yBot1 0.9 0.9], ...
            colRange1, 'FaceAlpha', 0.20, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end

    % Normal portion (max(yBot,0.9) to 1.2)
    yBotN = max(yBot, 0.9);
    fill(ax, [x1 x2 x2 x1], [yBotN yBotN yMax yMax], ...
        colNormal, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end

% Staircase profile
plot(ax, cyc_stair, vol_stair, '-', 'LineWidth', 3, 'Color', [0.00 0.45 0.74], ...
    'DisplayName', 'ERCOT Recovery Profile');

% Boundary lines
yline(ax, 0.5, '--', 'LineWidth', 1.2, 'Color', colRange2, 'HandleVisibility', 'off');
yline(ax, 0.9, '--', 'LineWidth', 1.2, 'Color', colNormal, 'HandleVisibility', 'off');
yline(ax, 1.2, '-', 'LineWidth', 2, 'Color', [0.64 0.08 0.18], ...
    'Label', '1.2 pu', 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');

% Annotate junction points with voltage and cycle count
for k = 2:nBp
    xPt = cyc_edges(k);
    yPt = voltagePu(k);
    label = sprintf('%.1f pu, %g cyc', yPt, cycles(k));
    text(ax, xPt, yPt - 0.04, label, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
end

% Zone labels inside shaded region
xGeo = sqrt(xLim(1)*xLim(2)); % geometric center on log scale
text(ax, xGeo*0.3, 0.35, {'Range 2'; 'SST Internal Storage Ride-Through'}, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.7 0.2 0]);
text(ax, xGeo*0.8, 0.70, {'Range 1'; 'SST + BESS'}, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.6 0.4 0]);
text(ax, xGeo*1.5, 1.05, {'SST Normal Operation'}, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.1 0.45 0.1]);

% Non-shaded region label (below staircase — large open area at high cycles, low voltage)
text(ax, xLim(2)*0.25, 0.15, {'Data Center Architecture'; 'Should Take Actions'}, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3], ...
    'FontAngle', 'italic');

set(ax, 'XScale', 'log');
set(ax, 'XGrid', 'on', 'YGrid', 'on');
set(ax, 'XTick', [1 2 5 9 15 24 30 54 100 174]);
xlabel(ax, 'Cycles (60 Hz)');
ylabel(ax, 'Grid Voltage (pu)');
title(ax, 'OCP SST Range Definitions');
legend(ax, 'Location', 'southeast', 'FontSize', 9);
xlim(ax, xLim);
ylim(ax, [0 1.3]);
hold(ax, 'off');
end
