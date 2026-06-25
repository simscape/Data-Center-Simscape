function tbl24hr = initialize24HrRoomData(NameValueArgs)
% Initialize 24hr data required by Day Scheduler block
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingLibName string {mustBeNonempty}
    end
    
    prjRoot = currentProject().RootFolder;
    dirFullPath = fullfile(prjRoot, "ScriptsData","BuildingLib",NameValueArgs.BuildingLibName);
    libExists = isfolder(dirFullPath);
    if libExists
        libModelData = load(strcat(dirFullPath,"/lib_",NameValueArgs.BuildingLibName,".mat"));
        bldgPartFileDataStruct = libModelData.buildingBlockLayoutData.bldgBlockPath.partFileBuilding;
        data = getListOfAllRoomsBuilding(BuildingData=bldgPartFileDataStruct);
        n = size(data,1);
        % Find room names
        RoomName = strings(n,1);
        for i = 1:n
            RoomName(i,1) = bldgPartFileDataStruct.("apartment"+data(i,1)).("room"+data(i,2)).name;
        end
        tblName = table(RoomName);
        % Collate room data
        data24hr = [data,zeros(n,24)];
        strName = strings(1,24);
        for i = 1:24
            if i > 9 
                % strName(1,i) = strcat("hr",num2str(i));
                strName(1,i) = strcat(num2str(i),":00");
            else
                strName(1,i) = strcat("0",num2str(i),":00");
            end
        end
        tblData = array2table(data24hr,VariableNames=["Apartment","Room","Index",strName]);
        % Create output tables
        tbl24hr = [tblData(:,1:2),tblName,tblData(:,3:end)];
    else
        tbl24hr = [];
        error("Building library not found.");
    end
end