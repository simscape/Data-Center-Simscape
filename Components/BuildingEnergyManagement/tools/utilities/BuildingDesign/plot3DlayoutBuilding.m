function plot3DlayoutBuilding(NameValueArgs)
% Wrapper function to plot building data based on availibility of external
% wall list. If the wall list has been created, a faster method is used for
% plot.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
        NameValueArgs.PlotViewDirection (1,3) {mustBeNonempty,mustBeReal}
        NameValueArgs.ColorScheme (1,1) string {mustBeNonempty,mustBeMember(NameValueArgs.ColorScheme,["random","wallsAndRoof","walls","roof","simple"])}
        NameValueArgs.Transparency (1,1) {mustBeLessThanOrEqual(NameValueArgs.Transparency,1),mustBeGreaterThanOrEqual(NameValueArgs.Transparency,0)} = 1
        NameValueArgs.Hour (1,1) {mustBeNumeric} = 0
        NameValueArgs.InternalWalls {mustBeNumericOrLogical} = false
        NameValueArgs.DebugMode {mustBeNumericOrLogical} = false
    end

    if isfield(NameValueArgs.Building.apartment1.room1.geometry.dim,"buildingExtBoundaryWallData")
        % disp('Wall data exists as separate list');
        if NameValueArgs.InternalWalls
            NameValueArgs.Transparency = min(0.5,NameValueArgs.Transparency);
        end
        plotBuildingData(NameValueArgs.Building,...
                         NameValueArgs.PlotViewDirection,...
                         NameValueArgs.ColorScheme,...
                         NameValueArgs.Transparency,...
                         NameValueArgs.Hour,...
                         NameValueArgs.InternalWalls,...
                         NameValueArgs.DebugMode);
    else
        % disp('Separate wall data has not been collated yet');
        plotWallsRoofFloorForBuilding(NameValueArgs.Building,...
                                      NameValueArgs.PlotViewDirection,...
                                      NameValueArgs.ColorScheme,...
                                      NameValueArgs.Hour);
    end
end