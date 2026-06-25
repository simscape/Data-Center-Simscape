function mdlBlkPath = initializeModelBlockPathMatrices(NameValueArgs)
% Initialize model lib block path matrices
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel struct {mustBeNonempty}
    end

    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.BuildingModel);
    nFloorTotal = NameValueArgs.BuildingModel.apartment1.room1.geometry.dim.topFloorLevelNum;
    numIntWalls = size(NameValueArgs.BuildingModel.apartment1.room1.geometry.dim.plotInternalWallVert2D,1);
    numExtWalls = size(NameValueArgs.BuildingModel.apartment1.room1.geometry.dim.allExtWallVertices,1)*nFloorTotal;

    mdlBlkPath.blkNameBldg = strings(nApt,max(nRooms));
    mdlBlkPath.blkNameBldgLibType = strings(nApt,max(nRooms));
    mdlBlkPath.blkNameWallInternal = strings(numIntWalls,1);
    mdlBlkPath.blkNameWallExternal = strings(numExtWalls,1);

    mdlBlkPath.blkNameBldgPhys = zeros(nApt,max(nRooms));
    mdlBlkPath.blkNameBldgLoc = strings(nApt,max(nRooms));
    mdlBlkPath.areaNameRoom = strings(nApt,max(nRooms));
    mdlBlkPath.areaNameRoof = strings(nApt,max(nRooms));
    mdlBlkPath.areaNameGround = strings(nApt,max(nRooms));
    mdlBlkPath.areaNameRoomLoc = strings(nApt,max(nRooms));
    mdlBlkPath.blkNameFloorLevel = strings(nFloorTotal,1);
    mdlBlkPath.namePipeInletBldg = strings(nFloorTotal,1);
    mdlBlkPath.namePipeOutletBldg = strings(nFloorTotal,1);
    % Below, col. 1 stores number of rooms per floor level, col. 2 stores 
    % number of rooms with TL port per level. Later, this would be extended
    % to have a third column with number of MA ports.
    mdlBlkPath.nodesPerFloorLvl = zeros(nFloorTotal,2);
end