% Function to merge floor plans together.

% Copyright 2024 The MathWorks, Inc.

function updatedFloorPlan = mergeFloorPlanTogether(floorPlan,plotOption)
    updatedFloorPlan = floorPlan;
    nApts = numel(fieldnames(floorPlan));
    roomList = [];
    for i = 1:nApts
        nRooms = numel(fieldnames(floorPlan.("apartment"+num2str(i))));
        for j = 1:nRooms
            roomList = [roomList floorPlan.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan];
        end
    end
    mergedShape = union(roomList);
    for i = 1:nApts
        nRooms = numel(fieldnames(updatedFloorPlan.("apartment"+num2str(i))));
        for j = 1:nRooms
            updatedFloorPlan.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVertices = mergedShape.Vertices;
        end
    end

    if anynan(mergedShape.Vertices)
        disp("ERROR: Failed to create external walls of the building. Error in mergeFloorPlanTogether()");
    end
    

    if plotOption
        figure('Name','Merged Floor Plan Representation')
        plotFloorPlanLayout(PlotData=floorPlan,Type="floorplan");
        hold on;
        for nVertices = 1:size(mergedShape.Vertices,1)
            plot(mergedShape.Vertices(nVertices,1),mergedShape.Vertices(nVertices,2),"o"); hold on;
            text(mergedShape.Vertices(nVertices,1),mergedShape.Vertices(nVertices,2),num2str(nVertices)); hold on;
        end
        hold off
    end
end