function breakerStatus(simResults, gridCodeNames, timeRange)
% breakerStatus  Plot UPS breaker status for all grid codes.
%
%   plot.breakerStatus(simResults, gridCodeNames, timeRange) creates a
%   stacked plot showing the UPS1BrK signal for each grid code. A value
%   of 0 means the breaker is closed (grid connected), 1 means open
%   (disconnected).
%
%   Example:
%     plot.breakerStatus(simResults, gridCodeNames, [2.9 8])

% Copyright 2026 The MathWorks, Inc.

arguments
    simResults cell
    gridCodeNames cell
    timeRange (1,2) double
end

numCodes = numel(gridCodeNames);

figure('Name', 'UPS Breaker Status');
tiledlayout(numCodes, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

for codeIdx = 1:numCodes
    logsout = simResults{codeIdx}.logsout;
    brk = logsout.get('UPS1BrK').Values;
    brkTime = brk.Time;
    brkData = brk.Data;

    [tPlot, timeIdx] = plot.utils.sliceTime(brkTime, timeRange(1), timeRange(2));
    brkPlot = brkData(timeIdx);

    nexttile
    area(tPlot, brkPlot, 'FaceColor', [0.90 0.25 0.20], 'FaceAlpha', 0.4, ...
        'EdgeColor', [0.90 0.25 0.20], 'LineWidth', 1.5);
    hold on
    plot(tPlot, brkPlot, 'LineWidth', 1.5, 'Color', [0.90 0.25 0.20]);

    ylim([-0.1 1.1]);
    yticks([0 1]);
    yticklabels({'Closed', 'Open'});
    xlim(timeRange);
    ylabel(gridCodeNames{codeIdx}, 'FontWeight', 'bold');
    grid on

    if codeIdx < numCodes
        xticklabels([]);
    else
        xlabel('Time (s)');
    end
end

sgtitle('UPS Breaker Status During LVRT', 'FontSize', 14);
end
