function set24HrRoomDataSystemModel(NameValueArgs)
% Set 24hr data in System Model
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel string {mustBeNonempty}
        NameValueArgs.DayScheduleHeatSrc (:,28) table {mustBeNonempty}
    end

    if bdIsLoaded(NameValueArgs.BuildingModel)
        listOfLibBlocks = libinfo(NameValueArgs.BuildingModel);
        blkDayScheduler = false;
        for i = 1:size(listOfLibBlocks,1)
            if listOfLibBlocks(i,1).Library == "DayScheduler_lib"
                blkDayScheduler = true;
                blkPath = listOfLibBlocks(i,1).Block;
                val = getParamStr(num2str(size(NameValueArgs.DayScheduleHeatSrc,1)));
                set_param(blkPath,"numRoom",val);
                val = getParamStr(mat2str(NameValueArgs.DayScheduleHeatSrc.Index'));
                set_param(blkPath,"roomIndex",val);
                val = getParamStr(mat2str(table2array(NameValueArgs.DayScheduleHeatSrc(:,5:28))));
                set_param(blkPath,"heatSource",val);
                disp(strcat("*** Set daily schedule in block ",listOfLibBlocks(i,1).Block));
            end
        end
        if ~blkDayScheduler
            disp("*** DailyScheduler block not found.")
        end
    end

end