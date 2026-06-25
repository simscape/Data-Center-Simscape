% Generate floorplan 3D model.

% Copyright 2024 The MathWorks, Inc.

function apartment3D = generateFloor3Dlayout(floorPlan,height,maxFloors)
    apartment3D = floorPlan;
    numApartments = numel(fieldnames(floorPlan));
    
    for i = 1:numApartments
        numRooms = numel(fieldnames(floorPlan.("apartment"+num2str(i))));
        for j = 1:numRooms
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.topFloorLevelNum = maxFloors;
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.floorLevel = 1;
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.height = height;
            roomVerticesMat = floorPlan.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan.Vertices;
            numSidesRoom = size(roomVerticesMat,1);
            roomVerticesFloor = zeros(numSidesRoom,3);
            roomVerticesRoof  = zeros(numSidesRoom,3);
            roomVerticesFloor(:,1:2) = roomVerticesMat;
            roomVerticesRoof(:,1:2) = roomVerticesFloor(:,1:2);
            roomVerticesRoof(:,3) = height;
            for k = 1:numSidesRoom
                if k < numSidesRoom
                    wallPoints = [roomVerticesFloor(k,1) roomVerticesFloor(k+1,1) roomVerticesRoof(k+1,1) roomVerticesRoof(k,1); ...
                                  roomVerticesFloor(k,2) roomVerticesFloor(k+1,2) roomVerticesRoof(k+1,2) roomVerticesRoof(k,2); ...
                                  roomVerticesFloor(k,3) roomVerticesFloor(k+1,3) roomVerticesRoof(k+1,3) roomVerticesRoof(k,3)];
                else
                    wallPoints = [roomVerticesFloor(k,1) roomVerticesFloor(1,1) roomVerticesRoof(1,1) roomVerticesRoof(k,1); ...
                                  roomVerticesFloor(k,2) roomVerticesFloor(1,2) roomVerticesRoof(1,2) roomVerticesRoof(k,2); ...
                                  roomVerticesFloor(k,3) roomVerticesFloor(1,3) roomVerticesRoof(1,3) roomVerticesRoof(k,3)];
                end
                apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices = wallPoints;
                
                roomCenter = mean(roomVerticesMat);
                
                wallCenter = mean(wallPoints(1:2,1:2)'); % using only floor plan (x,y) values as direction of outward normal does not change with height

                [posX,posY] = getUnitVectorFromPointToLine(roomCenter,wallCenter);
                apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).unitvecDir = [posX,posY];
            end
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.numWalls = numSidesRoom;
            roofPoints  = [roomVerticesRoof(:,1)';roomVerticesRoof(:,2)';roomVerticesRoof(:,3)'];
            floorPoints = [roomVerticesFloor(:,1)';roomVerticesFloor(:,2)';roomVerticesFloor(:,3)'];
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("roof").vertices = roofPoints;
            apartment3D.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("floor").vertices = floorPoints;
        end
    end
end

