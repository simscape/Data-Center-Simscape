function connTable = getBuildingRoomConnectivity(NameValueArgs)
% Function to get room to room connectivity data in a building.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
    end
    
    [nApt, ~] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.Building);

    for i = 1:nApt
        roomConnectivityTbl = getApartmentRoomConnectivity(Apartment=NameValueArgs.Building.("apartment"+i));
        numEntries = size(roomConnectivityTbl,1);
        FlrA = ones(numEntries,1)*NameValueArgs.Building.("apartment"+i).room1.geometry.dim.floorLevel;
        FlrB = ones(numEntries,1)*NameValueArgs.Building.("apartment"+i).room1.geometry.dim.floorLevel;
        AptA = ones(numEntries,1)*i;
        AptB = ones(numEntries,1)*i;
        roomConnectivityTbl = addvars(roomConnectivityTbl,FlrA,'Before',"#A");
        roomConnectivityTbl.FlrA = FlrA;
        roomConnectivityTbl = addvars(roomConnectivityTbl,FlrB,'Before',"#B");
        roomConnectivityTbl.FlrB = FlrB;
        roomConnectivityTbl = addvars(roomConnectivityTbl,AptA,'Before',"#A");
        roomConnectivityTbl.AptA = AptA;
        roomConnectivityTbl = addvars(roomConnectivityTbl,AptB,'Before',"#B");
        roomConnectivityTbl.AptB = AptB;
        if i == 1
            connTable = roomConnectivityTbl;
        else
            connTable = [connTable;roomConnectivityTbl];
        end
    end

    floorConnMat = NameValueArgs.Building.apartment1.room1.geometry.dim.floorConnMat;
    numEntries = size(floorConnMat,1);
    for i = 1:numEntries
        % Table Data format
        % [#FloorA, #AptA, #RoomA, RoomNameA, #FloorB, #AptB, #RoomB,
        % RoomNameB, Value]
        aptA = floorConnMat(i,1);
        roomA = floorConnMat(i,2);
        aptB = floorConnMat(i,3);
        roomB = floorConnMat(i,4);
        flrA = NameValueArgs.Building.("apartment"+aptA).room1.geometry.dim.floorLevel;
        flrB = NameValueArgs.Building.("apartment"+aptB).room1.geometry.dim.floorLevel;
        roomNameA = NameValueArgs.Building.("apartment"+aptA).("room"+roomA).name;
        roomNameB = NameValueArgs.Building.("apartment"+aptB).("room"+roomB).name;
        value = floorConnMat(i,6);
        tbl = table(flrA,aptA,roomA,roomNameA,flrB,aptB,roomB,roomNameB,value,...
            'VariableNames',{'FlrA','AptA','#A','RoomA','FlrB','AptB','#B','RoomB','Solid Wall Fraction'});
        connTable = [connTable;tbl];
    end
end