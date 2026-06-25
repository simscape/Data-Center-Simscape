function lvrtSummary(testResults)
% lvrtSummary  Visual summary of LVRT compliance across all grid codes.
%
%   plot.lvrtSummary(testResults) creates a heatmap-style grid showing
%   pass/fail status for each grid code and test criterion with color
%   coding (green = PASS, red = FAIL).
%
%   testResults is the table returned by lvrtTest.evaluate().
%
%   Example:
%     results = lvrtTest.evaluate(simResults, gridCodeNames);
%     plot.lvrtSummary(results)

% Copyright 2026 The MathWorks, Inc.

arguments
    testResults table
end

gridCodes = testResults.GridCode;
criteria = {'LoadVoltage', 'DCBusVoltage', 'ContinuousPower'};
criteriaLabels = {'Load Voltage', 'DC Bus Voltage', 'Continuous Power'};
numCodes = numel(gridCodes);
numCriteria = numel(criteria);

passMatrix = zeros(numCodes, numCriteria);
for codeIdx = 1:numCodes
    for critIdx = 1:numCriteria
        passMatrix(codeIdx, critIdx) = testResults.(criteria{critIdx})(codeIdx) == "PASS";
    end
end

passColor = [0.30 0.75 0.40];
failColor = [0.90 0.25 0.20];

figure('Name', 'LVRT Compliance Summary');
hold on

cellWidth = 1;
cellHeight = 1;
padding = 0.05;

for codeIdx = 1:numCodes
    for critIdx = 1:numCriteria
        xPos = (critIdx - 1) * cellWidth;
        yPos = (numCodes - codeIdx) * cellHeight;

        if passMatrix(codeIdx, critIdx)
            cellColor = passColor;
            label = "PASS";
        else
            cellColor = failColor;
            label = "FAIL";
        end

        rectangle('Position', [xPos + padding, yPos + padding, ...
            cellWidth - 2*padding, cellHeight - 2*padding], ...
            'Curvature', 0.2, 'FaceColor', cellColor, 'EdgeColor', 'w', 'LineWidth', 2);
        text(xPos + cellWidth/2, yPos + cellHeight/2, label, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    end

    % Overall result indicator
    xPos = numCriteria * cellWidth + 0.3;
    yPos = (numCodes - codeIdx) * cellHeight;
    overallPass = testResults.OverallResult(codeIdx) == "PASS";
    if overallPass
        marker = char(9679);
        markerColor = passColor;
    else
        marker = char(9679);
        markerColor = failColor;
    end
    text(xPos + 0.3, yPos + cellHeight/2, marker, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FontSize', 20, 'Color', markerColor);
end

% Y-axis labels (grid code names)
for codeIdx = 1:numCodes
    yPos = (numCodes - codeIdx) * cellHeight + cellHeight/2;
    text(-0.15, yPos, gridCodes(codeIdx), ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
        'FontSize', 12, 'FontWeight', 'bold');
end

% X-axis labels (criteria)
for critIdx = 1:numCriteria
    xPos = (critIdx - 1) * cellWidth + cellWidth/2;
    text(xPos, numCodes * cellHeight + 0.2, criteriaLabels{critIdx}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 11, 'FontWeight', 'bold');
end

% Overall column header
text(numCriteria * cellWidth + 0.6, numCodes * cellHeight + 0.2, 'Overall', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
    'FontSize', 11, 'FontWeight', 'bold');

axis equal
axis off
xlim([-1.5 numCriteria * cellWidth + 1.2]);
ylim([-0.5 numCodes * cellHeight + 0.8]);
title('LVRT Compliance Summary', 'FontSize', 15)
hold off;
end
