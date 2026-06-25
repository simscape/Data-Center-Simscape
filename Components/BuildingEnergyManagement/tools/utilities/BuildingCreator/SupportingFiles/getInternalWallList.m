function intWallVert = getInternalWallList(NameValueArgs)
% Get list of internal walls
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.FloorNumber (1,1) {mustBeNonnegative}
    end

    intWallVert = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotInternalWallVert2D;
    lastIndx = 0;
    firstIndx = 0;
    for i = 1:size(intWallVert,1)
        aptA = intWallVert(i,1);
        roomA = intWallVert(i,2);
        aptB = intWallVert(i,3);
        roomB = intWallVert(i,4);
        if NameValueArgs.BuildingData.("apartment"+num2str(aptA)).("room"+num2str(roomA)).geometry.dim.floorLevel == NameValueArgs.FloorNumber && ...
           NameValueArgs.BuildingData.("apartment"+num2str(aptB)).("room"+num2str(roomB)).geometry.dim.floorLevel == NameValueArgs.FloorNumber
            lastIndx = i;
            if firstIndx == 0
                firstIndx = i;
            end
        end
    end
    intWallVert = intWallVert(firstIndx:lastIndx,:);
end