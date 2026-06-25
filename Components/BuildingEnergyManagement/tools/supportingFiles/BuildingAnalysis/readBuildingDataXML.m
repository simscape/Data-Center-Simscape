function dataStruct = readBuildingDataXML(NameValueArgs)
% Function to read building XML data.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.FileName string {mustBeNonempty}
    end

    xmlFilename=NameValueArgs.FileName;
    loadFilename = fullfile(matlab.project.rootProject().RootFolder,'ScriptsData','Parts',xmlFilename);
    fileContent = readstruct(loadFilename);
    dataStruct = fileContent.DATA;

    nApt = fileContent.README.nApt;
    nRooms = fileContent.README.nRooms';
    % Read back (and reshape) data into matrix form, as is expected by PLOT
    % function for buildings.
    for i = 1:nApt
        for j = 1:nRooms(i,1)
            nWalls = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.numWalls;
            % Recover wall vertices data from vector array
            for k = 1:nWalls
                r = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).verticesMATsize(1,1);
                c = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).verticesMATsize(1,2); 
                vertVec = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices;
                dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices = reshape(vertVec,[r,c]);
            end
            % Recover roof vertices data from vector array
            roofVert = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.vertices;
            r = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.verticesMATsize(1,1);
            c = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.verticesMATsize(1,2);
            dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.vertices = reshape(roofVert,[r,c]);
            
            % Recover floor vertices data from vector array
            floorVert = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.floor.vertices;
            r = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.floor.verticesMATsize(1,1);
            c = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.floor.verticesMATsize(1,2);
            dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.floor.vertices = reshape(floorVert,[r,c]);
           
            % Recover allExtWallVertices data stored in each room 
            allExtVert = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVertices;
            r = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVerticesMATsize(1,1);
            c = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVerticesMATsize(1,2);
            dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVertices = reshape(allExtVert,[r,c]);
        end
    end

    r = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wallMATsize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wallMATsize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wall;
    dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wall = reshape(reshapeData,[r,c]);

    r = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roofMATsize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roofMATsize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roof;
    dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roof = reshape(reshapeData,[r,c]);

    r = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floorMATsize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floorMATsize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floor;
    dataStruct.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floor = reshape(reshapeData,[r,c]);

    r = dataStruct.apartment1.room1.geometry.dim.floorConnMatSize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.floorConnMatSize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.floorConnMat;
    dataStruct.apartment1.room1.geometry.dim.floorConnMat = reshape(reshapeData,[r,c]);

    r = dataStruct.apartment1.room1.geometry.dim.plotWallVert2DMatSize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.plotWallVert2DMatSize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.plotWallVert2D;
    dataStruct.apartment1.room1.geometry.dim.plotWallVert2D = reshape(reshapeData,[r,c]);

    r = dataStruct.apartment1.room1.geometry.dim.plotInternalWallVert2DMatSize(1,1);
    c = dataStruct.apartment1.room1.geometry.dim.plotInternalWallVert2DMatSize(1,2);
    reshapeData = dataStruct.apartment1.room1.geometry.dim.plotInternalWallVert2D;
    dataStruct.apartment1.room1.geometry.dim.plotInternalWallVert2D = reshape(reshapeData,[r,c]);

    if isfield(dataStruct.apartment1.room1.geometry.dim,"inclinedRoof")
        % Inclined Roof related data
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.unitVecNormalMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.unitVecNormalMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.unitVecNormal;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.unitVecNormal = reshape(reshapeData,[r,c]);
    
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.roofRoomConnectivityMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.roofRoomConnectivityMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.roofRoomConnectivity;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.roofRoomConnectivity = reshape(reshapeData,[r,c]);
    
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.topFloorAdditionalHtMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.topFloorAdditionalHtMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.topFloorAdditionalHt;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.topFloorAdditionalHt = reshape(reshapeData,[r,c]);
    
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclXMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclXMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclX;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclX = reshape(reshapeData,[r,c]);
        
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclYMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclYMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclY;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclY = reshape(reshapeData,[r,c]);
    
        r = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclZMatSize(1,1);
        c = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclZMatSize(1,2);
        reshapeData = dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclZ;
        dataStruct.apartment1.room1.geometry.dim.inclinedRoof.inclZ = reshape(reshapeData,[r,c]);
    end

    % Add back polyshape to datastruct
    for i = 1:nApt
        for j = 1:nRooms(i,1)
            dataStruct = addBackFloorPlanToRoom(dataStruct,i,j);
        end
    end

    % % re-construct geoLocation()
    % location = fileContent.README.Location;
    % degLatitude = fileContent.README.Latitude;
    % degLongitude = fileContent.README.Longitude;
    % stdTimeZone = fileContent.README.StdTimeZone;
    % geoLocation = table(degLatitude,degLongitude,stdTimeZone,...
    %     'VariableNames',{'Latitude','Longitude','Meredian (Time Zone)'},...
    %     'RowNames',location);
    % 
    % t1 = fileContent.README.StartTime;
    % t2 = fileContent.README.EndTime;
    % datetimeVec = t1:hours(1):t2;
    % 
    % disp(strcat('Location:',geoLocation.Row));
    % disp('Simulation Duration:');
    % disp(strcat('*** Start Time : ',string(datetimeVec(1,1))));
    % disp(strcat('*** End Time   : ',string(datetimeVec(1,end))));
    % % dateStringDisp = strcat(': ',string(datetimeVec(1,1)),' --> ',string(datetimeVec(1,end)));

    % roomNameList = [];
    % for j = 1:nRooms(1,1)
    %     if j>1
    %         roomNameList = strcat(dataStruct.apartment1.("room"+j).name,', ',roomNameList);
    %     else
    %         roomNameList = dataStruct.apartment1.("room"+j).name;
    %     end
    % end
    % roomNameList = strcat("*** Room Names in Building : ",roomNameList);
    % disp(roomNameList);
end