% Function to find total number of apartments and rooms in a floorplan.

% Copyright 2024 The MathWorks, Inc.

function [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(floorPlan)
    nApt = numel(fieldnames(floorPlan));
    nRooms = zeros(nApt,1);
    for i = 1:nApt
        nRooms(i,1) = numel(fieldnames(floorPlan.("apartment"+num2str(i))));
    end
end