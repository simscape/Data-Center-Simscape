% Copyright 2026 The MathWorks, Inc.

function [optimumOption,optimumPUE] = findBestSolution(NameValueArgs)
    arguments (Input)
        NameValueArgs.ListOfDesignOptions table {mustBeNonempty} 
        NameValueArgs.SimulationResults (1,:) cell {mustBeNonempty}
        NameValueArgs.MaxRoomTempPermissible simscape.Value {mustBeNonempty}
        NameValueArgs.MinRoomTempPermissible simscape.Value {mustBeNonempty}
        NameValueArgs.EnablePlot logical {mustBeNonempty} = false
    end
    
    nCase = size(NameValueArgs.ListOfDesignOptions,1);
    plotData = zeros(1,nCase);
    maxTemp = zeros(1,nCase);
    minTemp = zeros(1,nCase);
    for i = 1:nCase
        plotData(1,i) = mean(NameValueArgs.SimulationResults{1,i}.PUE);
        maxTemp(1,i) = max(NameValueArgs.SimulationResults{1,i}.("T (K).room"));
        minTemp(1,i) = min(NameValueArgs.SimulationResults{1,i}.("T (K).room"));
    end

    if NameValueArgs.EnablePlot
        figure("Name","PUE");plot(1:nCase,plotData,"-o");title("PUE");
        figure("Name","Temperature");plot(1:nCase,maxTemp,"-o");title("Max. Room Temperature");
    end
    
    idx = and(maxTemp<=value(NameValueArgs.MaxRoomTempPermissible,"K"), ...
              minTemp>=value(NameValueArgs.MinRoomTempPermissible,"K"));
    [~,id] = min(plotData(idx));
    optimumOption = [];
    optimumPUE = [];
    if ~isempty(id)
        indices = find(idx==1, id, 'first');
        if ~isempty(indices)
            optimumOption = NameValueArgs.ListOfDesignOptions(indices(end),:);
            optimumPUE = plotData(indices(end));
            disp(strcat("PUE number ~",num2str(round(optimumPUE,2))));
            disp(" ");
            disp(optimumOption);
        else
            disp("No solution that meets the requirements.");
        end
    else
        disp("No solution that meets the requirements.");
    end
end