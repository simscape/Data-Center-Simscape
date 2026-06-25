function updatedBuildingData = getConnectivityAcrossBuildingFloors(NameValueArgs)
% Function to store room to room connection across the floors.

% Copyright 2024 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
    end

    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.Building);
    numAptsFloor = NameValueArgs.Building.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.floor(:,1); % Apt number vector
    numAptsRoof  = NameValueArgs.Building.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roof(:,1);  % Apt number vector
    chkNumFloor  = sum(abs(unique(numAptsFloor) - unique(numAptsRoof))); % Will be zero if Floor and Roof indices are same, implying 1 floor only
    % More connections are added only if there are more than one floor in
    % the building definition.
    solidFloorFrac = 1; % Assume all floors are solid wall, no staircase like thing or a duplex apartment permitted.
    floorConnMat = [];
    if chkNumFloor > 0 % more than 1 floor, connect roof of a room to the floor of the room above.
        aptsPerFloor = length(unique(numAptsFloor));
        numFloorBldg = nApt/aptsPerFloor;
        for i = 1:numFloorBldg-1
            for j = 1:aptsPerFloor
                apt1 = (i-1)*aptsPerFloor+j; % Apartment below
                apt2 = i*aptsPerFloor+j;     % Apartment above
                for k = 1:nRooms(apt1,1)
                    if k > 0 % 
                        contactArea = NameValueArgs.Building.("apartment"+num2str(apt1)).("room"+num2str(k)).floorPlan.area;
                        solidFloorFracVal = solidFloorFrac;
                        storeData = [apt1,k,apt2,k,contactArea,solidFloorFracVal];
                        floorConnMat = [floorConnMat;storeData];
                    end
                end
            end
        end
    end
    updatedBuildingData = NameValueArgs.Building;
    updatedBuildingData.apartment1.room1.geometry.dim.floorConnMat = floorConnMat;
end