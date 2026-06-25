function [aptn,room,wall,subSysLoc,connWall,fracWin,fracVen] = getCoordinatesExtWallSubsystem(NameValueArgs)
% Get external wall subsystem coordinates
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.IndexExtWallList (1,1) {mustBeNonnegative}
        NameValueArgs.FloorLevelNumber (1,1) {mustBeNonnegative}
        NameValueArgs.ScaleToPlot (1,1) {mustBeNonnegative}
    end

    extWallVert = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.allExtWallVertices;
    numExtWalls = size(extWallVert,1);
    id = (NameValueArgs.FloorLevelNumber-1)*numExtWalls+NameValueArgs.IndexExtWallList;
    
    aptn = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D(id,1);
    room = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D(id,2);
    wall = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D(id,3);
    fracWin = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D(id,4);
    fracVen = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D(id,5);
    
    if wall == 4
        wallNext = 1;
    else
        wallNext = wall+1;
    end
    if NameValueArgs.IndexExtWallList == numExtWalls
        wVec1 = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.allExtWallVertices(NameValueArgs.IndexExtWallList,:);
        wVec2 = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.allExtWallVertices(1,:);
    else
        wVec1 = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.allExtWallVertices(NameValueArgs.IndexExtWallList,:);
        wVec2 = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.allExtWallVertices(NameValueArgs.IndexExtWallList+1,:);
    end
      
    foundIt = [wall,sqrt(sum((wVec1-wVec2).^2))];
    roomVert = getNonRotatedRoomVertices(Apartment=NameValueArgs.BuildingData,NumberApartment=aptn,NumberRoom=room);
    if foundIt(1,1) == 4
        if wallNext == 4
            pt2 = roomVert(4,:);
            pt1 = roomVert(1,:);
        else
            pt1 = roomVert(4,:);
            pt2 = roomVert(1,:);
        end
    else
        if wallNext == wall
            pt2 = roomVert(foundIt(1,1),:);
            pt1 = roomVert(foundIt(1,1)+1,:);
        else
            pt1 = roomVert(foundIt(1,1),:);
            pt2 = roomVert(foundIt(1,1)+1,:);
        end
    end
    moveBy = max(0,min(1,foundIt(1,2)/sqrt(sum((pt1-pt2).^2))));
    pt3 = pt1+(pt2-pt1)*moveBy;
    subSysLoc = 0.5*(pt3+pt1)*NameValueArgs.ScaleToPlot;
    if wall == 1
        connWall = 4;
    else
        connWall = wall-1;
    end
end