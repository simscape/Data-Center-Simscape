function updatedBuildingData = getBldgInternalWallCoordinates(NameValueArgs)
% Function to find all building internal wall vertices.

% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
    end

    updatedBuildingData = NameValueArgs.Building;

    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.Building);
    
    internalWallData = [];
    for i = 1:nApt
        for j = 1:nRooms(i,1)
            nameOfConnections = fieldnames(NameValueArgs.Building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.connectivity);
            roomNumList = getConnectedRoomNumber(nameOfConnections);
            avoidDoubleCount = roomNumList(roomNumList>j);
            if ~isempty(avoidDoubleCount)
                for k = 1:length(avoidDoubleCount)
                    conn = avoidDoubleCount(1,k);
                    wallFrac = NameValueArgs.Building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.connectivity.("room"+num2str(conn)).wallFrac;
                    pt1 = NameValueArgs.Building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.connectivity.("room"+num2str(conn)).commonWallPoint1;
                    pt2 = NameValueArgs.Building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.connectivity.("room"+num2str(conn)).commonWallPoint2;
                    storeData = [i,j,i,conn,wallFrac,pt1,pt2]; 
                    internalWallData = [internalWallData;storeData];
                end
            end
        end
    end
    updatedBuildingData.apartment1.room1.geometry.dim.plotInternalWallVert2D = internalWallData;
end