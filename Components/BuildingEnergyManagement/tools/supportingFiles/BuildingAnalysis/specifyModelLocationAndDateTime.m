function specifyModelLocationAndDateTime(NameValueArgs)
% Specify location and datetime values requried by all blocks used in a
% Simscape model.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.ModelName string {mustBeNonempty}
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.EndTime datetime {mustBeNonempty}
        NameValueArgs.Location table {mustBeNonempty}
        NameValueArgs.DayLightSavingHrs (1,1) {mustBeNonnegative}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    libdata = libinfo(NameValueArgs.ModelName);
    libdata_path = {libdata(:).Block}';
    libdata_libr = {libdata(:).ReferenceBlock}';
    
    customLibList = ["buildingEnergy_lib/Temperature Source"+newline+"(LUT)", "buildingEnergy_lib/Solar Radiation On"+newline+"Surface", "buildingEnergy_lib/Solar Radiation"+newline+"(LUT)", "buildingEnergy_lib/Wall External"];
    for idx = 1:length(customLibList)
        data = libdata_libr==customLibList(1,idx);
        if sum(data) > 0
            if NameValueArgs.Diagnostics, disp(strcat("Number of '",customLibList(1,idx),"' = ",num2str(sum(data)))); end
            libDataPath = string(libdata_path(data));
            for i = 1:size(libDataPath,1)
                thisLibData = libDataPath(i,1);
                specifyGeoLocationOnLibBlk(Location=NameValueArgs.Location,...
                                           CustomLibBlkPath=thisLibData,...
                                           DayLightSavingHrs=0);
                specifyDateTimeOnLibBlk(CustomLibBlkPath=thisLibData,...
                                        CustomLibBlkName=customLibList(1,idx),...
                                        StartTime=NameValueArgs.StartTime,...
                                        EndTime=NameValueArgs.EndTime);
                if NameValueArgs.Diagnostics, disp(strcat("*** Parameterized '",thisLibData,"'.")); end
            end
        end
    end
end