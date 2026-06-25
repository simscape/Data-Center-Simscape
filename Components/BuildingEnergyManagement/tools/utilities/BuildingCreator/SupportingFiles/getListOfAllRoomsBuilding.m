function fullList = getListOfAllRoomsBuilding(NameValueArgs)
% Get list of all building rooms
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingData struct {mustBeNonempty}
    end

    indxAptRoom = getAptRoomNumForGivenFloor(BuildingData=NameValueArgs.BuildingData);
    topFloorLevelNum = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.topFloorLevelNum;
    [a,b] = size(indxAptRoom);
    totNumRooms = a*b/2;
    fullList = zeros(totNumRooms,3);
    numRoomsPerFloor = (totNumRooms/topFloorLevelNum);
    for i = 1:topFloorLevelNum
        % Find list of apartment and rooms to consider at the floor level
        fullList((i-1)*b/2+1:i*b/2,1:2) = reshape(indxAptRoom(i,:),[2,length(indxAptRoom(i,:))/2])';
        fullList((i-1)*b/2+1:i*b/2,3) = (i-1)*numRoomsPerFloor+[1:numRoomsPerFloor]';
    end
end