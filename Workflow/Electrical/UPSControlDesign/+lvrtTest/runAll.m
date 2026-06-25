function simResults = runAll(gridCodeNames)
% runAll  Run UPSControl simulation for all specified LVRT grid codes.
%
%   simResults = lvrtTest.runAll(gridCodeNames) loads the model,
%   initializes parameters, and runs the simulation for each grid code.
%   Returns a cell array of SimulationOutput objects.
%
%   Example:
%     simResults = lvrtTest.runAll({'ERCOT', 'RTEFrance', 'EirGrid', 'ATC', 'AESO'})

% Copyright 2026 The MathWorks, Inc.

arguments
    gridCodeNames cell
end

numGridCodes = numel(gridCodeNames);
simResults = cell(numGridCodes, 1);

load_system('UPSControl');
DataCenterParam;

for codeIdx = 1:numGridCodes
    lvrtProfileName = gridCodeNames{codeIdx}; %#ok<*NASGU>
    LVRT;
    simResults{codeIdx} = sim('UPSControl', 'SrcWorkspace', 'current');
end

end
