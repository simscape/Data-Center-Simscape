% Function to calculate common wall area between two rooms, required for
% thermal resistance calculations.

% Copyright 2024 The MathWorks, Inc.

function [overlapLength,overlapVert] = getCommonWallLenBetweenTwoRooms(apartmentUnit,id1,id2,dist,dir)
    arguments
        apartmentUnit struct {mustBeNonempty}
        id1 (1,1) {mustBeInteger}
        id2 (1,1) {mustBeInteger}
        dist (1,1) {mustBePositive}
        dir (1,1) string {mustBeMember(dir,["x+","x-","y+","y-"])}
    end

    arg1 = apartmentUnit.("room"+num2str(id1)).geometry.dim.vertex;
    arg2 = apartmentUnit.("room"+num2str(id1)).geometry.dim.width;
    arg3 = apartmentUnit.("room"+num2str(id1)).geometry.dim.length;
    arg4 = apartmentUnit.("room"+num2str(id1)).geometry.dim.theta;
    if strcmp(dir,"x-")
        arg1(1,1) = arg1(1,1) - dist*arg2;
    elseif strcmp(dir,"x+")
        arg1(1,1) = arg1(1,1) + dist*arg2;
    elseif strcmp(dir,"y-")
        arg1(1,2) = arg1(1,2) - dist*arg3;
    else % strcmp(dir,"y+")
        arg1(1,2) = arg1(1,2) + dist*arg3;
    end
    jRoom = addNewRoomToFloorPlan(arg1,arg2,arg3,arg4,"tempRoom");
    kRoom = apartmentUnit.("room"+num2str(id2));
    overlap = jRoom.floorPlan.intersect(kRoom.floorPlan);
    if strcmp(dir,"x-") || strcmp(dir,"x+")
        overlapLength = overlap.area/(dist*arg2);
    else
        overlapLength = overlap.area/(dist*arg3);
    end
    if overlapLength > 0
        vertices = getInternalCommonWallSectionVertices(kRoom,jRoom,dist);
        overlapVert = vertices(1:2,1:2);
    else
        overlapVert = zeros(2,2);
    end
end