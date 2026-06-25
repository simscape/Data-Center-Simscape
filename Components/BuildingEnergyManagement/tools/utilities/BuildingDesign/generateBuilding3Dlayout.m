function updatedBuildingData = generateBuilding3Dlayout(NameValueArgs)
% Function to generate building 3D layout.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingName string {mustBeNonempty}
        NameValueArgs.BuildingFloorPlan struct {mustBeNonempty}
        NameValueArgs.NumberOfLevels (1,1) {mustBeNumeric,mustBeGreaterThan(NameValueArgs.NumberOfLevels,0)}
        NameValueArgs.LevelHeight (1,1) simscape.Value
        NameValueArgs.Tol (1,1) {mustBeNonnegative, mustBeLessThan(NameValueArgs.Tol,100)}
    end
    
    floorHeight = value(NameValueArgs.LevelHeight,'m');
    % Add external wall vertices to each room geometry data
    if not(isfield(NameValueArgs.BuildingFloorPlan.("apartment"+num2str(1)).("room"+num2str(1)).geometry.dim,'allExtWallVertices'))
        updatedFloorPlan = mergeFloorPlanTogether(NameValueArgs.BuildingFloorPlan,true);
    else
        updatedFloorPlan = NameValueArgs.BuildingFloorPlan;
    end
    
    buildingDataGF = generateFloor3Dlayout(updatedFloorPlan,floorHeight,NameValueArgs.NumberOfLevels);
    nAptsPerFloor = numel(fieldnames(buildingDataGF));
    for i = 1:nAptsPerFloor
        building.("apartment"+num2str(i)) = buildingDataGF.("apartment"+num2str(i));
    end

    for i = 2:NameValueArgs.NumberOfLevels
        buildingData = copyAndStackUpFloor3Dlayout(buildingDataGF,i-1,NameValueArgs.NumberOfLevels);
        for j = 1:nAptsPerFloor
            aptNumber = j+(i-1)*nAptsPerFloor;
            building.("apartment"+num2str(aptNumber)) = buildingData.("apartment"+num2str(aptNumber));
        end
    end
    bldgWallWinVentSurfArea = estimateExtWallSurfAreaFracToAmbient(NameValueArgs.BuildingName,building,NameValueArgs.Tol/100);
    % The function below helps in plotting building more efficiently by
    % maintaining a list of outer walls, roof, and floor.
    update01 = createListOfAllOuterWalls(bldgWallWinVentSurfArea);
    % Find room connectivity data across different floors.
    update02 = getConnectivityAcrossBuildingFloors(Building=update01);
    % Find wall coordinates for internal overlapping walls.
    updatedBuildingData = getBldgInternalWallCoordinates(Building=update02);
end