function msgNum = setBuildingBlockInitialTemperature(NameValueArgs)
% Set building initial temperature
% 
% Copyright 2025 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.LibinfoLibrary string {mustBeNonempty}
        NameValueArgs.LibinfoBlock string {mustBeNonempty}
        NameValueArgs.InitialTemperature (1,1) {mustBeNonnegative}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.MessageCount (1,1) {mustBeNonnegative} = 0
    end

    bldgBlocksTemperatureInit = ["WallSelector_lib",...
                                 "ExternalWall_lib",...
                                 "RoomWithRadiatorAndUFP",...
                                 "RoomWithRadiator",...
                                 "RoomWithUFP",...
                                 "RoomWithAirVolume"];
    msgNum = 0;
    [success,~] = ismember(NameValueArgs.LibinfoLibrary,bldgBlocksTemperatureInit);
    if success
        val = getParamStr(num2str(NameValueArgs.InitialTemperature));
        set_param(NameValueArgs.LibinfoBlock,"iniT",val);
        if NameValueArgs.Diagnostics
            if NameValueArgs.MessageCount > 0
                msgNum = NameValueArgs.MessageCount;
                disp(strcat("(",num2str(NameValueArgs.MessageCount),")Parameterize Block ",NameValueArgs.LibinfoLibrary," for initial temperature value of ",num2str(NameValueArgs.InitialTemperature),"K."));
            else
                disp(strcat("Parameterize Block ",NameValueArgs.LibinfoLibrary," for initial temperature value of ",num2str(NameValueArgs.InitialTemperature),"K."));
            end
        end
    end
end