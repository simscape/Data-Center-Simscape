function connTable = getApartmentRoomConnectivity(NameValueArgs)
% Function to get room to room connectivity data in an apartment.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
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
        count = 0;
        for i = 1:nRooms-1
            for j = i:nRooms
                if isfield(NameValueArgs.Apartment.("room"+i).geometry.connectivity,strcat("room",num2str(j)))
                    count = count+1;
                end
            end
        end
        FirstRoomName = strings(count,1);
        FirstRoomNum = zeros(count,1);
        SecondRoomName = strings(count,1);
        SecondRoomNum = zeros(count,1);
        SolidWallFraction = ones(count,1);
        count = 0;
        for i = 1:nRooms-1
            for j = i:nRooms
                if isfield(NameValueArgs.Apartment.("room"+i).geometry.connectivity,strcat("room",num2str(j)))
                    count = count+1;
                    FirstRoomName(count,1) = NameValueArgs.Apartment.("room"+i).name;
                    FirstRoomNum(count,1) = i;
                    SecondRoomName(count,1) = NameValueArgs.Apartment.("room"+j).name;
                    SecondRoomNum(count,1) = j;
                    SolidWallFraction(count,1) = NameValueArgs.Apartment.("room"+i).geometry.connectivity.("room"+j).wallFrac;
                end
            end
        end
        connTable = table(FirstRoomNum,FirstRoomName,SecondRoomNum,SecondRoomName,SolidWallFraction,'VariableNames',{'#A','RoomA','#B','RoomB','Solid Wall Fraction'});
    else
        disp("Error in Apartment definition. Exiting !!");
        connTable = [];
    end
end