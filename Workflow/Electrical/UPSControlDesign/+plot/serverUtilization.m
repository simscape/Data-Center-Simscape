function serverUtilization()
% serverUtilization  Plot server utilization over time (10-second window).
%
%   plot.serverUtilization() generates and plots the server CPU utilization
%   profile (%) vs time for a 10-second simulation window, with shaded area
%   under the curve.
%
%   Example:
%     plot.serverUtilization()

% Copyright 2026 The MathWorks, Inc.

simulationTime = 10.0;
timeStep = 1e-3;
timeData = (0:timeStep:simulationTime)';

utilizationData = arrayfun(@computeServerUtil, timeData) * 100;

figHandle = figure('Name', 'Server Utilization');
if length(dbstack) > 1
    set(figHandle, 'Units', 'pixels', 'Position', [100 100 900 400]);
end

hold on
fill([timeData(1); timeData; timeData(end)], [0; utilizationData; 0], ...
    [0 0.45 0.74], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
plot(timeData, utilizationData, 'LineWidth', 2, 'Color', [0 0.45 0.74]);

grid on
xlim([0 simulationTime]);
ylim([0 100]);
title('Server Utilization Profile', 'FontSize', 15)
ylabel('Utilization (%)')
xlabel('Time (s)')

end

function serverUtil = computeServerUtil(currentTime)
    simulationTime = 10.0;
    riseTime = 0.15;
    waypointFractions = [0.00, 0.05, 0.20, 0.35, 0.50, 0.65, 0.80, 0.92, 1.00];
    waypointUtilizations = [0.00, 0.55, 0.80, 0.35, 0.90, 0.60, 0.25, 0.70, 0.70];

    waypointTimes = waypointFractions * simulationTime;
    numWaypoints = length(waypointTimes);

    serverUtil = waypointUtilizations(numWaypoints);

    for segIdx = 1 : numWaypoints - 1
        segStart = waypointTimes(segIdx);
        segEnd   = waypointTimes(segIdx + 1);
        utilFrom = waypointUtilizations(segIdx);
        utilTo   = waypointUtilizations(segIdx + 1);
        transitionStart = segEnd - riseTime;

        if currentTime >= segStart && currentTime < segEnd
            if currentTime < transitionStart
                serverUtil = utilFrom;
            else
                blendFactor = (currentTime - transitionStart) / riseTime;
                blendFactor = max(0.0, min(1.0, blendFactor));
                serverUtil = utilFrom + (utilTo - utilFrom) * 0.5 * (1.0 - cos(pi * blendFactor));
            end
            break;
        end
    end

    serverUtil = max(0.0, min(1.0, serverUtil));
end
