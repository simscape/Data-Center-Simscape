function apartmentUnit = defineSingleApartmentUnit(NameValueArgs)
% Define single apartment unit.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.Tol (1,1) {mustBeNonnegative, mustBeLessThan(NameValueArgs.Tol,100)}
    end
    
    numRooms = length(NameValueArgs.Apartment);
    for i = 1:numRooms
        apartment.("room"+num2str(i)).name      = NameValueArgs.Apartment(1,i).name;
        apartment.("room"+num2str(i)).physics   = NameValueArgs.Apartment(1,i).physics;
        apartment.("room"+num2str(i)).geometry  = NameValueArgs.Apartment(1,i).geometry;
        apartment.("room"+num2str(i)).floorPlan = NameValueArgs.Apartment(1,i).floorPlan;
    end
    
    [result, errMsg] = getRoomIntersectionWithinApartment(apartment);
    
    if ~result
        apartmentUnit = getRoomConnectivityWithinApartment(apartment,NameValueArgs.Tol/100);
    else
        apartmentUnit = [];
        disp(strcat("*** ERROR : Rooms cannot overlap with each other in an apartment. You must re-define rooms :",errMsg));
    end
end