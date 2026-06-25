% Function to add room to a floor plan.

% Copyright 2024 The MathWorks, Inc.

function roomModel = addNewRoomToFloorPlan(vertex,wid,len,theta,name)
    vertices = [vertex(1,1), vertex(1,2);...
                vertex(1,1)+wid, vertex(1,2);...
                vertex(1,1)+wid, vertex(1,2)+len;...
                vertex(1,1), vertex(1,2)+len];
    polyOrig = polyshape(vertices(:,1)',vertices(:,2)');
    % Data Struct
    roomModel.floorPlan           = rotate(polyOrig,theta,vertices(1,:));
    roomModel.physics.radiator    = 0.25;
    roomModel.physics.underfloor  = 1;
    roomModel.name                = name;
    roomModel.geometry.dim.length = len;
    roomModel.geometry.dim.width  = wid;
    roomModel.geometry.dim.vertex = vertex;
    roomModel.geometry.dim.theta  = theta;
end
