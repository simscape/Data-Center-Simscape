% Function to create new 3D floor in a building.

% Copyright 2024 The MathWorks, Inc.

function floor3Dcopy = copyAndStackUpFloor3Dlayout(layout3Dfloor,floorNum,maxFloors)
    nAptPerFloor = numel(fieldnames(layout3Dfloor));
    for i = 1:nAptPerFloor
        nRooms = numel(fieldnames(layout3Dfloor.("apartment"+num2str(i))));
        newAptNum = i+floorNum*nAptPerFloor;
        floor3Dcopy.("apartment"+num2str(newAptNum)) = layout3Dfloor.("apartment"+num2str(i));
        for j = 1:nRooms
            roomLayout = layout3Dfloor.("apartment"+num2str(i)).("room"+num2str(j));
            levelHeight  = roomLayout.geometry.dim.height*floorNum;
            roomVerticesMat = roomLayout.floorPlan.Vertices;
            nSides = size(roomVerticesMat,1);
            for k = 1:nSides
                wallVertices = roomLayout.geometry.("wall"+num2str(k)).vertices;
                wallVertices(3,:) = wallVertices(3,:) + levelHeight;
                floor3Dcopy.("apartment"+num2str(newAptNum)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices = wallVertices;
            end
            wallVertices = roomLayout.geometry.("roof").vertices;
            wallVertices(3,:) = wallVertices(3,:) + levelHeight;
            floor3Dcopy.("apartment"+num2str(newAptNum)).("room"+num2str(j)).geometry.("roof").vertices = wallVertices;
            wallVertices = roomLayout.geometry.("floor").vertices;
            wallVertices(3,:) = wallVertices(3,:) + levelHeight;
            floor3Dcopy.("apartment"+num2str(newAptNum)).("room"+num2str(j)).geometry.("floor").vertices = wallVertices;
            floor3Dcopy.("apartment"+num2str(newAptNum)).("room"+num2str(j)).geometry.dim.floorLevel = floorNum+1;
            floor3Dcopy.("apartment"+num2str(newAptNum)).("room"+num2str(j)).geometry.dim.topFloorLevelNum = maxFloors;
        end
    end
end