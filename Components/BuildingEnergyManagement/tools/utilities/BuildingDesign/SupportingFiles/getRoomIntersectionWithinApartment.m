% Function to find if rooms overlap - which is not allowed.

% Copyright 2024 The MathWorks, Inc.

function [result, errMsg] = getRoomIntersectionWithinApartment(apartmentUnit)
    nRooms = numel(fieldnames(apartmentUnit));
    result = false;
    errMsg = "";
    for j = 1:nRooms-1
        for k = j+1:nRooms
            intersectionPoly = intersect(apartmentUnit.("room"+num2str(j)).floorPlan,apartmentUnit.("room"+num2str(k)).floorPlan);
            if intersectionPoly.area > 0
                result = true;
                errMsg = strcat(apartmentUnit.("room"+num2str(j)).name," & ",apartmentUnit.("room"+num2str(k)).name);
            end
        end
    end
end