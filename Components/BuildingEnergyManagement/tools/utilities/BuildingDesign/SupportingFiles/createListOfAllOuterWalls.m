% Create a list of outer walls in a building.

% Copyright 2024 The MathWorks, Inc.

function updatedBuildingData = createListOfAllOuterWalls(model3Dbuilding)
    % Store list of all outer walls in apartment1, room1 --- as this would
    % exist in any kind of simulation. This list would enable removal of
    % nested IF-loops during plotting stage and have information on which
    % walls are external and need to be plotted.
    
    updatedBuildingData = model3Dbuilding;
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(model3Dbuilding);
    
    grdFloorNumber = model3Dbuilding.("apartment"+num2str(1)).("room"+num2str(nRooms(1,1))).geometry.dim.floorLevel;
    
    aptRoomWallNumMat = [];
    aptRoomRoofNumMat = [];
    aptRoomFloorNumMat = [];
    
    for i = 1:nApt
        for j = 1:nRooms(i,1)
            topFloorNumber = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.topFloorLevelNum;
            roomVerticesMat = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan.Vertices;
            nWalls = size(roomVerticesMat,1);
            for k = 1:nWalls
                isThisOuterWall = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWallSurfFrac + ...
                                   model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWindowSurfFrac + ...
                                   model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientVentSurfFrac ...
                                   > 0);
                if isThisOuterWall
                    aptRoomWallNumMat = [aptRoomWallNumMat; [i,j,k]];
                end
            end

            topFloor = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.floorLevel==topFloorNumber);
            grdFloor = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.floorLevel==grdFloorNumber);
            if topFloor
                aptRoomRoofNumMat = [aptRoomRoofNumMat; [i,j]];
            end
            if grdFloor
                aptRoomFloorNumMat = [aptRoomFloorNumMat; [i,j]];
            end
        end
    end
    
    updatedBuildingData.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wall = aptRoomWallNumMat;
    updatedBuildingData.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roof = aptRoomRoofNumMat;
    updatedBuildingData.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floor = aptRoomFloorNumMat;
end