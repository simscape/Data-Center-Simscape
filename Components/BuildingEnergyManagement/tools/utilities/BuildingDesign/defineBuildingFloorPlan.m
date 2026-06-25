function floorUnit = defineBuildingFloorPlan(NameValueArgs)
% Define building floorplan.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartments (1,:) cell {mustBeNonempty}
    end

    numApartments = length(NameValueArgs.Apartments);
    for i = 1:numApartments
        floorUnit.("apartment"+num2str(i)) = NameValueArgs.Apartments{1,i};
    end
end