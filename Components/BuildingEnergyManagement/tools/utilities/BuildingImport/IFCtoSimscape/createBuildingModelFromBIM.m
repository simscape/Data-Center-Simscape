function [building,modelData] = createBuildingModelFromBIM(NameValueArgs)
% Create Simscape building from the BIM data imported using function
% getBuildingDataFromBIM()
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DataBuilding struct {mustBeNonempty}
        NameValueArgs.DataBIM struct {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.Tol (1,1) {mustBeNonnegative} = 0.01
        NameValueArgs.BuildingName string {mustBeText} = "BuildingModel"
    end

    %% Create Floor Plan
    floorPlanStruct = [];
    modelData = NameValueArgs.DataBuilding;

    for i = 1:size(modelData.Room,1)
        floorPlanStruct = addRoomToFloorPlan(FloorPlan=floorPlanStruct,...
            Vertex=modelData.Room{i,1}.vertex,...
            Length=modelData.Room{i,1}.len,...
            Width=modelData.Room{i,1}.wid,...
            Angle=modelData.Room{i,1}.rotateByDeg,...
            NewRoom=modelData.Room{i,1}.name,...
            Plot=NameValueArgs.Debug);
    end
    
    modelApt = defineSingleApartmentUnit(Apartment=floorPlanStruct,Tol=NameValueArgs.Tol);
    
    % Break Non-rectangular Rooms to Multiple Rectangles
    apartment = checkForNonRectangularRooms(Apartment=modelApt,...
                                            Debug=NameValueArgs.Debug);
    %% Get Window Data
    % Collate Data for Wall Openings
    modelData.Opening = getOpeningForMultipleBuildingWalls(WallList=modelData.WallMaterial.Listing.Wall,...
                                                           ModelData=NameValueArgs.DataBIM,...
                                                           Debug=NameValueArgs.Debug,...
                                                           PhysUnitLen=modelData.UnitLength);
    %% Apply Internal Window Data
    modelData.Opening.IntTbl = getApartmentRoomConnectivity(Apartment=apartment);
    
    modelData.Opening.IntTbl = updateInternalWallOpeningData(Apartment=apartment,...
        TableData=modelData.Opening.IntTbl,WallData=modelData.Opening.InteriorWall,...
        ModelDataUnit=modelData.UnitLength,Tol=NameValueArgs.Tol);
    
    apartment = updateApartmentRoomConnectivity(Apartment=apartment,...
                                                ConnectionTable=modelData.Opening.IntTbl);
    
    floorPlan = defineBuildingFloorPlan(Apartments={apartment});
    
    if NameValueArgs.Debug
        figure('Name','Floor Plan Consolidated');
        plotFloorPlanLayout(PlotData=floorPlan,Type="floorplan");
    end
    
    %% Apply External Window Data
    modelData.Opening.ExtTbl = visualizeBuildingWallsToAddWindowsVents(FloorPlan=floorPlan,Plot=NameValueArgs.Debug);
    
    modelData.Opening.ExtTbl = updateWindowVentTableData(FloorPlan=floorPlan,...
        WallData=modelData.Opening.ExteriorWall,TableData=modelData.Opening.ExtTbl,...
        ModelDataUnit=modelData.UnitLength,Tol=NameValueArgs.Tol);
    
    if NameValueArgs.Debug, disp(modelData.Opening.ExtTbl); end
    
    modelData.Opening.ExtTbl.("Overlap Vertices") = [];

    updatedFloorPlan = addOpeningOnWallSection(FloorPlan=floorPlan,...
                                               Data=modelData.Opening.ExtTbl);

    building = generateBuilding3Dlayout(BuildingName=NameValueArgs.BuildingName,...
                                        BuildingFloorPlan=updatedFloorPlan,...
                                        NumberOfLevels=modelData.NumLevels,...
                                        LevelHeight=modelData.Height,...
                                        Tol=NameValueArgs.Tol);
end