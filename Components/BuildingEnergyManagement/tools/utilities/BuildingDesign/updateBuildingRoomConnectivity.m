function bldg = updateBuildingRoomConnectivity(NameValueArgs)
% Function to edit room to room connectivity data in a Building.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
        NameValueArgs.ConnectionTable (:,9) table {mustBeNonempty}
    end

    bldg = NameValueArgs.Building;
    aptList = fieldnames(bldg);
    nApts = numel(aptList);
    
    dataError = false;
    for i = 1:nApts
        if aptList{i,1}(1:9) ~= "apartment"
            dataError = true;
        end
    end
    
    if ~dataError
        tbl = NameValueArgs.ConnectionTable;
        roomConnSameFloor = tbl(tbl.FlrA==tbl.FlrB,:);
        numConnSameFloor = size(roomConnSameFloor,1);
        if numConnSameFloor > 0
            listOfApartments = unique(roomConnSameFloor.FlrA);
            for i = 1:length(listOfApartments)
                roomConnSameAptTbl = roomConnSameFloor(roomConnSameFloor.FlrA==listOfApartments(i,1),:);
                bldg.("apartment"+listOfApartments(i,1)) = ...
                    updateApartmentRoomConnectivity(Apartment=bldg.("apartment"+listOfApartments(i,1)),...
                    ConnectionTable=roomConnSameAptTbl(:,[3,4,7,8,9])); % ConnectionTable in updateApartmentRoomConnectivity requires shorter table
            end
        end
        roomConnDiffFloor = tbl(tbl.FlrA~=tbl.FlrB,:);
        numConnDiffFloor = size(roomConnDiffFloor,1);
        if numConnDiffFloor > 0
            floorConnMatOrig = bldg.apartment1.room1.geometry.dim.floorConnMat;
            for i = 1:size(floorConnMatOrig,1)
                A1 = floorConnMatOrig(i,1);
                R1 = floorConnMatOrig(i,2);
                A2 = floorConnMatOrig(i,3);
                R2 = floorConnMatOrig(i,4);
                editedData = roomConnDiffFloor(and(and(roomConnDiffFloor.AptA==A1,roomConnDiffFloor.('#A')==R1),...
                                                   and(roomConnDiffFloor.AptB==A2,roomConnDiffFloor.("#B")==R2)),:);
                if size(editedData,1) > 0
                    floorConnMatOrig(i,6) = editedData.("Solid Wall Fraction");
                else
                    disp("Error - new data entry for apartment and room combinations found in the Table.");
                    dispMsg = strcat("*** Data For Apt#",num2str(A1),"-Room#",num2str(R1)," <-> Apt#",num2str(A2),"-Room#",num2str(R2)," Not Found");
                    disp(dispMsg);
                end
            end
            bldg.apartment1.room1.geometry.dim.floorConnMat = floorConnMatOrig;
        end
    else
        disp("Error in Building definition. Exiting !!");
    end
end