function [listOfRoomNames,listOfFloorLvls] = getAllRoomNameForBuilding(NameValueArgs)
% Function to find list of all rooms in a building.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
    end
    
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.Building);
    listOfRoomNames = strings(1,sum(nRooms));
    listOfFloorLvls = zeros(1,sum(nRooms));
    count = 0;
    for i = 1:nApt
        for j = 1:nRooms(i,1)
            count = count+1;
            listOfRoomNames(1,count) = NameValueArgs.Building.("apartment"+i).("room"+j).name;
            listOfFloorLvls(1,count) = NameValueArgs.Building.("apartment"+i).("room"+j).geometry.dim.floorLevel;
        end
    end
end