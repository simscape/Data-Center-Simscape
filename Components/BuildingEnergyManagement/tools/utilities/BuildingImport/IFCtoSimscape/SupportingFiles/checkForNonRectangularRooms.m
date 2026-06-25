function apartment = checkForNonRectangularRooms(NameValueArgs)
% Function to to check if the imported room is rectangular or not.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
    end

    aptTbl = getApartmentRoomConnectivity(Apartment=NameValueArgs.Apartment);
    if NameValueArgs.Debug, disp(aptTbl); end
    nonRectRoomUpdate = false;
    for i = 1:size(aptTbl,1)
        r1 = convertStringsToChars(aptTbl.RoomA(i,1));
        rn1 = str2double(convertCharsToStrings(r1(regexp(r1,"[0-9]"))));
        r2 = convertStringsToChars(aptTbl.RoomB(i,1));
        rn2 = str2double(convertCharsToStrings(r2(regexp(r2,"[0-9]"))));
        % Rooms having same number are a part of the same larger room. For
        % example, room4a, room4b, room4c are in reality, a single large
        % room number 4, with three parts - a,b,c. Here, each room name is
        % checked, and if the number is same, then the solid wall between
        % them is removed. This is done by specifying Solid Wall Fraction
        % as a very small value (tending to zero). The room connectivity
        % table is updated for all such non-rectangular rooms.
        if rn1 == rn2
            aptTbl.("Solid Wall Fraction")(i,1) = 0.001;
            nonRectRoomUpdate = true;
        end
    end
    if nonRectRoomUpdate && NameValueArgs.Debug
        disp("*** Updated room connectivity table data");
        disp(aptTbl);
    end
    apartment = updateApartmentRoomConnectivity(Apartment=NameValueArgs.Apartment,ConnectionTable=aptTbl);
end