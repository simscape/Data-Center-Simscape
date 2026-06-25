% Function to add back floor plan to room data when reading XML file.

% Copyright 2024 The MathWorks, Inc.

function updatedStruct = addBackFloorPlanToRoom(dataStruct,i,j)
    arguments
        dataStruct struct {mustBeNonempty}
        i (1,1) {mustBeNumeric,mustBeGreaterThan(i,0)}
        j (1,1) {mustBeNumeric,mustBeGreaterThan(j,0)}
    end
    updatedStruct = dataStruct;
    vertex = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.vertex;
    len = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.length;
    wid = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.width;
    theta = dataStruct.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.theta;

    vertices = [vertex(1,1), vertex(1,2);...
                vertex(1,1)+wid, vertex(1,2);...
                vertex(1,1)+wid, vertex(1,2)+len;...
                vertex(1,1), vertex(1,2)+len];
    polyOrig = polyshape(vertices(:,1)',vertices(:,2)');
    updatedStruct.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan = rotate(polyOrig,theta,vertices(1,:));
end
