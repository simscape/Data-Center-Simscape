function testResults = evaluate(simResults, gridCodeNames)
% evaluate  Evaluate LVRT simulation results against pass/fail criteria.
%
%   testResults = lvrtTest.evaluate(simResults, gridCodeNames) returns
%   a table with pass/fail results for each grid code. The primary
%   criterion is that the UPS breaker (UPS1BrK) remains closed (value = 0)
%   throughout the LVRT event, indicating the data center stays connected
%   to the grid.
%
%   Inputs:
%     simResults    - cell array of Simulink.SimulationOutput objects
%     gridCodeNames - cell array of grid code name strings
%
%   Example:
%     results = lvrtTest.evaluate(simResults, {"ERCOT","RTE France"})

% Copyright 2026 The MathWorks, Inc.

arguments
    simResults cell
    gridCodeNames
end

gridCodeNames = string(gridCodeNames);
numGridCodes = numel(gridCodeNames);
testResults = table('Size', [numGridCodes, 3], ...
    'VariableTypes', {'string','string','string'}, ...
    'VariableNames', {'LVRTProfile','UPSBreakerStatus','OverallResult'});

eventWindow = [2.9 10];

for codeIdx = 1:numGridCodes
    logsout = simResults{codeIdx}.logsout;

    % UPS Breaker check — must remain 0 (closed) during the event
    brk = logsout.get('UPS1BrK').Values;
    brkTime = brk.Time;
    brkData = brk.Data;
    eventMask = brkTime >= eventWindow(1) & brkTime <= eventWindow(2);
    breakerPass = all(brkData(eventMask) == 0);

    % Record results
    testResults.LVRTProfile(codeIdx) = gridCodeNames(codeIdx);
    testResults.UPSBreakerStatus(codeIdx) = formatResult(breakerPass);
    testResults.OverallResult(codeIdx) = formatResult(breakerPass);
end
end

function resultString = formatResult(passed)
    if passed
        resultString = "PASS";
    else
        resultString = "FAIL";
    end
end
