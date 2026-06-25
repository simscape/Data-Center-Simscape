function roomJvert = getNonRotatedRoomVertices(NameValueArgs)
% Find building room vertices, non-rotated
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.NumberApartment (1,1) {mustBeNonnegative}
        NameValueArgs.NumberRoom (1,1) {mustBeNonnegative}
    end

    theta = NameValueArgs.Apartment.("apartment"+NameValueArgs.NumberApartment).("room"+NameValueArgs.NumberRoom (1,1)).geometry.dim.theta;
    if theta == 0
        roomJvert = NameValueArgs.Apartment.("apartment"+NameValueArgs.NumberApartment).("room"+NameValueArgs.NumberRoom (1,1)).floorPlan.Vertices;
    else
        roomJvert = NameValueArgs.Apartment.("apartment"+NameValueArgs.NumberApartment).("room"+NameValueArgs.NumberRoom (1,1)).floorPlan.rotate(-theta).Vertices;
    end
end