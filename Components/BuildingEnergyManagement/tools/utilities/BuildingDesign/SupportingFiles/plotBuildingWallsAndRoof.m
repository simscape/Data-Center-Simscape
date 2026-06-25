function plotBuildingWallsAndRoof(NameValueArgs)
% Function to plot building walls and roof separately.

% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Building struct {mustBeNonempty}
        NameValueArgs.PlotViewDirection (1,3) {mustBeNonempty}
        NameValueArgs.Transparency (1,1) {mustBeLessThanOrEqual(NameValueArgs.Transparency,1),mustBeGreaterThanOrEqual(NameValueArgs.Transparency,0)} = 1
    end

    strTitle = 'Plot Walls';
    figure('Name',strTitle);
    plot3DlayoutBuilding(Building=NameValueArgs.Building,...
                         PlotViewDirection=NameValueArgs.PlotViewDirection,...
                         Transparency=NameValueArgs.Transparency,...
                         ColorScheme="walls");
    title(strTitle);
    
    strTitle = 'Plot Roof';
    figure('Name',strTitle);
    plot3DlayoutBuilding(Building=NameValueArgs.Building,...
                         PlotViewDirection=NameValueArgs.PlotViewDirection,...
                         Transparency=NameValueArgs.Transparency,...
                         ColorScheme="roof");
    title(strTitle);
    
    strTitle = 'Plot Walls & Roof';
    figure('Name',strTitle);
    plot3DlayoutBuilding(Building=NameValueArgs.Building,...
                         PlotViewDirection=NameValueArgs.PlotViewDirection,...
                         Transparency=NameValueArgs.Transparency,...
                         ColorScheme="wallsAndRoof");
    title(strTitle);
end