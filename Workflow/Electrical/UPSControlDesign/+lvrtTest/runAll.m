function simResults = runAll(gridCodeNames)
% runAll  Run UPSControl simulation for all specified LVRT grid codes.
%
%   simResults = lvrtTest.runAll(gridCodeNames) loads the model,
%   initializes parameters, and runs the simulation for each grid code.
%   Returns a cell array of SimulationOutput objects.
%
%   Pass the result to lvrtTest.evaluate to get the pass/fail table.
%
%   Example:
%     simResults = lvrtTest.runAll({'ERCOT', 'RTE France', 'Eir Grid'})
%     testResults = lvrtTest.evaluate(simResults, {"ERCOT","RTE France","Eir Grid"})

% Copyright 2026 The MathWorks, Inc.

arguments
    gridCodeNames cell
end

numGridCodes = numel(gridCodeNames);
simResults = cell(numGridCodes, 1);

load_system('UPSControl');
DataCenterParam;

for codeIdx = 1:numGridCodes
    lvrtProfileName = char(gridCodeNames{codeIdx}); %#ok<*NASGU>
    LVRT;
    simResults{codeIdx} = sim('UPSControl', 'SrcWorkspace', 'current');
end

end
