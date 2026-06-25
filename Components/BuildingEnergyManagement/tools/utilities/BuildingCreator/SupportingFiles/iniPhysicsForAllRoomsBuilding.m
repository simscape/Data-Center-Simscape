function fullListPhys = iniPhysicsForAllRoomsBuilding(NameValueArgs)
% Initialize physics model for all rooms.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.RoomList (:,3) {mustBeNonempty}
    end

    numRooms = size(NameValueArgs.RoomList,1);
    fullListPhys = zeros(numRooms,4);
    % Column 3 = 3 : Both radiator and underfloor piping
    % Column 3 = 2 : Underfloor piping only
    % Column 3 = 1 : Radiator only
    % Column 3 = 0 : No radiator or underfloor piping
    fullListPhys(:,1:2) = NameValueArgs.RoomList(:,1:2);
    fullListPhys(:,4) = NameValueArgs.RoomList(:,3);
end