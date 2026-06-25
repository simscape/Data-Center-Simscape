function [connWportA,connWportB,coordWall,orientation] = getWallNumberForInternalContact(NameValueArgs)
% Get wall number of internal contact
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.RoomIndices (2,2) {mustBeNonnegative}
        NameValueArgs.ScaleToPlot (1,1) {mustBeNonnegative} = 100
        NameValueArgs.WallSubsystemDim (1,1) {mustBeNonnegative} = 10
    end

    aptA = NameValueArgs.RoomIndices(1,1);
    aptB = NameValueArgs.RoomIndices(2,1);
    roomA = NameValueArgs.RoomIndices(1,2);
    roomB = NameValueArgs.RoomIndices(2,2);
    % The rooms might have been rotated (in XML definition) and need to be brought back
    % to a orientation that aligns with X & Y axes. This is needed for wall to identify
    % new room wall locations and hence wall subsystem location.
    roomVertA = getNonRotatedRoomVertices(Apartment=NameValueArgs.Apartment,NumberApartment=aptA,NumberRoom=roomA);
    roomVertB = getNonRotatedRoomVertices(Apartment=NameValueArgs.Apartment,NumberApartment=aptB,NumberRoom=roomB);
    rectScale = 1.15;
    roomRectA = polyshape(roomVertA(:,1),roomVertA(:,2));
    roomRectA = roomRectA.scale(rectScale,mean(roomRectA.Vertices));
    roomRectB = polyshape(roomVertB(:,1),roomVertB(:,2));
    roomRectB = roomRectB.scale(rectScale,mean(roomRectB.Vertices));
    roomRectC = roomRectA.intersect(roomRectB);
    wallCenterXY = mean(roomRectC.Vertices,1)*NameValueArgs.ScaleToPlot;
    del_X = abs(max(max(roomRectC.Vertices(:,1))) - min(min(roomRectC.Vertices(:,1))));
    del_Y = abs(max(max(roomRectC.Vertices(:,2))) - min(min(roomRectC.Vertices(:,2))));
    coordWall = [wallCenterXY(1,1)-NameValueArgs.WallSubsystemDim, wallCenterXY(1,2)-NameValueArgs.WallSubsystemDim, wallCenterXY(1,1)+NameValueArgs.WallSubsystemDim, wallCenterXY(1,2)+NameValueArgs.WallSubsystemDim];
    % Intersection is a thin rectangle
    if del_X > del_Y
        if mean(roomVertA(:,2)) > mean(roomVertB(:,2))
            % A is below B
            connWportA = 3;
            connWportB = 1;
            orientation = "down";
        else
            % B is above A
            connWportA = 1;
            connWportB = 3;
            orientation = "up";
        end
    else
        if mean(roomVertA(:,1)) > mean(roomVertB(:,1))
            % A is on right side of B
            connWportA = 4;
            connWportB = 2;
            orientation = "right";
        else
            % B is on right side of A
            connWportA = 2;
            connWportB = 4;
            orientation = "left";
        end
    end
end