function indxAptRoom = getAptRoomNumForGivenFloor(NameValueArgs)
% Get room and apartment number
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingData struct {mustBeNonempty}
    end
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.BuildingData);
    topFloorLevelNum = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.topFloorLevelNum;
    numRoomPerFloor = zeros(topFloorLevelNum,1);
    for i = 1:nApt
        fLvl = NameValueArgs.BuildingData.("apartment"+i).("room1").geometry.dim.floorLevel;
        numRoomPerFloor(fLvl,1) = numRoomPerFloor(fLvl,1)+nRooms(i,1);
    end
    indxAptRoom = zeros(topFloorLevelNum,2*max(numRoomPerFloor(:,1)));

    count = zeros(topFloorLevelNum,1);
    for i = 1:nApt
        fLvl = NameValueArgs.BuildingData.("apartment"+i).("room1").geometry.dim.floorLevel;
        for j = 1:nRooms(i,1)
            count(fLvl,1) = count(fLvl,1)+2;
            indxAptRoom(fLvl,count(fLvl,1)-1) = i;
            indxAptRoom(fLvl,count(fLvl,1)) = j;
        end
    end
end