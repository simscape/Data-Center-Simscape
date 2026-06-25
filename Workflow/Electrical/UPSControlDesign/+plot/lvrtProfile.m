function lvrtProfile(operatorIdx, operatorName)
% lvrtProfile  Plot the LVRT voltage-time boundary for a single grid operator.
%
%   plot.lvrtProfile(operatorIdx, operatorName) generates the ride-through
%   voltage profile for the specified operator with shaded area and annotations.
%
%   Operator indices: 1=ERCOT, 2=RTE France, 3=Eir Grid, 4=ATC, 5=AESO
%
%   Examples:
%     plot.lvrtProfile(1, "ERCOT")
%     plot.lvrtProfile(4, "ATC")

% Copyright 2026 The MathWorks, Inc.

arguments
    operatorIdx (1,1) double
    operatorName (1,1) string
end

timeStep = 0.001;
timeVector = 0:timeStep:3.999;
numPoints = numel(timeVector);
voltageProfile = ones(1, numPoints);

for pointIdx = 1:numPoints
    currentTime = timeVector(pointIdx);
    switch operatorIdx
        case 1 % ERCOT
            if currentTime < 0.15
                voltageProfile(pointIdx) = 0.11;
            elseif currentTime < 0.5
                voltageProfile(pointIdx) = 0.50;
            elseif currentTime < 2.00
                voltageProfile(pointIdx) = 0.8;
            elseif currentTime < 4
                voltageProfile(pointIdx) = 0.9;
            end
        case 2 % RTE France
            if currentTime < 0.15
                voltageProfile(pointIdx) = 0.00;
            elseif currentTime < 1.2
                voltageProfile(pointIdx) = 0.9 * (currentTime - 0.15) / (1.2 - 0.15);
            elseif currentTime < 4
                voltageProfile(pointIdx) = 0.9;
            end
        case 3 % Eir Grid
            if currentTime < 0.15
                voltageProfile(pointIdx) = 0.00;
            elseif currentTime < 0.50
                voltageProfile(pointIdx) = 0.5;
            elseif currentTime < 2
                voltageProfile(pointIdx) = 0.8;
            elseif currentTime < 4
                voltageProfile(pointIdx) = 0.9;
            end
        case 4 % ATC
            if currentTime < 0.15
                voltageProfile(pointIdx) = 0.00;
            elseif currentTime < 1.2
                voltageProfile(pointIdx) = 0.25;
            elseif currentTime < 2.5
                voltageProfile(pointIdx) = 0.5;
            elseif currentTime < 3
                voltageProfile(pointIdx) = 0.7;
            elseif currentTime < 4
                voltageProfile(pointIdx) = 0.9;
            end
        case 5 % AESO
            if currentTime < 0.15
                voltageProfile(pointIdx) = 0.00;
            elseif currentTime < 0.3
                voltageProfile(pointIdx) = 0.45;
            elseif currentTime < 2
                voltageProfile(pointIdx) = 0.65;
            elseif currentTime < 3
                voltageProfile(pointIdx) = 0.75;
            elseif currentTime < 4
                voltageProfile(pointIdx) = 0.9;
            end
    end
end

figure('Name', sprintf('LVRT Profile — %s', operatorName));
hold on
fill([timeVector fliplr(timeVector)], [voltageProfile zeros(1, numPoints)], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
plot(timeVector, voltageProfile, 'LineWidth', 2.5, 'Color', [0.85 0.33 0.10]);
yline(0.9, '--', 'Nominal Lower Limit', 'Color', [0 0.5 0], 'LineWidth', 1.5, ...
    'LabelHorizontalAlignment', 'left');
text(2.5, 0.08, 'May Disconnect', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.5 0.5 0.5]);
text(2.5, 0.97, 'Ride Through', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.5 0.5 0.5]);
grid on
axis([0 4 0 1.1])
title(sprintf('LVRT Profile — %s', operatorName), 'FontSize', 10)
xlabel('Time Since Fault Onset (s)')
ylabel('Voltage (pu)')
end
