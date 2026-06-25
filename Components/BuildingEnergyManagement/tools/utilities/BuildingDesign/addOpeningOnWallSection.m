function updatedFloorPlan = addOpeningOnWallSection(NameValueArgs)
% Function to add a window or vent information to the building walls.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.FloorPlan struct {mustBeNonempty}
        NameValueArgs.Data (:,6) table {mustBeNonempty}
    end
    
    if isfield(NameValueArgs.FloorPlan.("apartment"+num2str(1)).("room"+num2str(1)).geometry.dim,'allExtWallVertices')
        updatedFloorPlan = NameValueArgs.FloorPlan;
    else
        updatedFloorPlan = mergeFloorPlanTogether(NameValueArgs.FloorPlan,false);
    end
    numWindows = size(NameValueArgs.Data,1);
    nApts = numel(fieldnames(NameValueArgs.FloorPlan));
    for i = 1:nApts
        nRooms = numel(fieldnames(NameValueArgs.FloorPlan.("apartment"+num2str(i))));
        for j = 1:nRooms
            allExtWallWindowFracValue = [];
            allExtWallVentFracValue = [];
            for k = 1:numWindows
                wallIndx = str2num(NameValueArgs.Data.("Wall Index")(k,1));
                if and(wallIndx(1,1)==i,wallIndx(1,2)==j)
                    allExtWallWindowFracValue = [allExtWallWindowFracValue,[wallIndx,NameValueArgs.Data.("Window (0-1)")(k,1)]];
                    allExtWallVentFracValue = [allExtWallVentFracValue,[wallIndx,NameValueArgs.Data.("Vent (0-1)")(k,1)]];
                end
            end
            if ~isempty(allExtWallWindowFracValue), updatedFloorPlan.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.("allExtWallWindowFrac") = allExtWallWindowFracValue; end
            if ~isempty(allExtWallVentFracValue), updatedFloorPlan.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.("allExtWallVentFrac") = allExtWallVentFracValue; end
        end
    end
end