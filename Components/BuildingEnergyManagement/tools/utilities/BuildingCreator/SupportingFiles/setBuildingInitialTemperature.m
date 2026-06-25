function setBuildingInitialTemperature(NameValueArgs)
% Set building initial temperature value.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel string {mustBeNonempty}
        NameValueArgs.InitialTemperature (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.InitialTemperature, "K")}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = true
    end

    if bdIsLoaded(NameValueArgs.BuildingModel)
        count = 0;
        listOfLibBlocks = libinfo(NameValueArgs.BuildingModel);
        for i = 1:size(listOfLibBlocks,1)
            count = setBuildingBlockInitialTemperature(LibinfoLibrary=listOfLibBlocks(i,1).Library,...
                                                       LibinfoBlock=listOfLibBlocks(i,1).Block,...
                                                       InitialTemperature=value(NameValueArgs.InitialTemperature,"K"),...
                                                       Diagnostics=NameValueArgs.Diagnostics,...
                                                       MessageCount=count+1);
            if or(contains(listOfLibBlocks(i,1).Block,"/TLinlet/VertPipe"),contains(listOfLibBlocks(i,1).Block,"/TLoutlet/VertPipe"))
                val = getParamStr(num2str(value(NameValueArgs.InitialTemperature,"K")));
                set_param(listOfLibBlocks(i,1).Block,"T0",val);
                if NameValueArgs.Diagnostics
                    count = count + 1;
                    disp(strcat("(",num2str(count),")Parameterize Block ",listOfLibBlocks(i,1).Library," for initial temperature value of ",num2str(value(NameValueArgs.InitialTemperature,"K")),"K."));
                end
            end
        end
    else
        disp(strcat("*** Error *** Cannot set building initial temperature. The model ",NameValueArgs.BuildingModel," must be loaded."));
    end
end