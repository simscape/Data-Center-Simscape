function newApartment = updateApartmentRoomConnectivity(NameValueArgs)
% Function to edit room to room connectivity data in an apartment.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.ConnectionTable (:,5) table {mustBeNonempty}
    end

    aptRooms = fieldnames(NameValueArgs.Apartment);
    nRooms = numel(aptRooms);
    
    dataError = false;
    for i = 1:nRooms
        if aptRooms{i,1}(1:4) ~= "room"
            dataError = true;
        end
    end
    
    if ~dataError
        newApartment = NameValueArgs.Apartment;
        tblSize = size(NameValueArgs.ConnectionTable,1);
        for i = 1:tblSize
            roomA = NameValueArgs.ConnectionTable.("#A")(i,1);
            roomB = NameValueArgs.ConnectionTable.("#B")(i,1);
            newApartment.("room"+roomA).geometry.connectivity.("room"+roomB).wallFrac = ...
                NameValueArgs.ConnectionTable.("Solid Wall Fraction")(i,1);
            newApartment.("room"+roomB).geometry.connectivity.("room"+roomA).wallFrac = ...
                NameValueArgs.ConnectionTable.("Solid Wall Fraction")(i,1);
        end
    else
        disp("Error in Apartment definition. Also check size of input data. Room name lists and new value vector must be of same size. Exiting !!");
        newApartment = NameValueArgs.Apartment;
    end
end