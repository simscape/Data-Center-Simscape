function [fullPathWall,coordWallStr] = addInternalWallBetweenRooms(NameValueArgs)
% Add internal room walls, common walls with or without windows/doors
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.RoomIndices (2,2) {mustBeNonnegative}
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockPathRoomA string {mustBeNonempty}
        NameValueArgs.BlockPathRoomB string {mustBeNonempty}
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.ScaleToPlot (1,1) {mustBeNonnegative} = 100
        NameValueArgs.WallSubsystemDim (1,1) {mustBeNonnegative} = 10
        NameValueArgs.WallType string {mustBeMember(NameValueArgs.WallType,["Solid Wall","Wall with Opening"])}
    end

    setLibraryPathReferences;
    aptA = NameValueArgs.RoomIndices(1,1);
    aptB = NameValueArgs.RoomIndices(2,1);
    roomA = NameValueArgs.RoomIndices(1,2);
    roomB = NameValueArgs.RoomIndices(2,2);
    [connWportA,connWportB,coordWall,orient] = getWallNumberForInternalContact(...
        Apartment=NameValueArgs.Apartment,RoomIndices=[aptA,roomA;aptB,roomB],ScaleToPlot=NameValueArgs.ScaleToPlot,...
        WallSubsystemDim=NameValueArgs.WallSubsystemDim);
    fullPathWall = strcat(NameValueArgs.BlockPath,"/W_A",num2str(aptA),"R",num2str(roomA),"_A",num2str(aptB),"R",num2str(roomB));
    add_block(customBlkPath.selectWall,fullPathWall,"Position",coordWall);
    if NameValueArgs.WallType == "Solid Wall"
        set_param(fullPathWall,"optWall",int32(1));
    else
        set_param(fullPathWall,"optWall",int32(2));
    end
    set_param(fullPathWall,"ShowName","off");
    coordWallStr = num2str(coordWall);
    set_param(fullPathWall,"Orientation",orient);
    simscape.addConnection(NameValueArgs.BlockPathRoomA,("W"+num2str(connWportA)),fullPathWall,"B");
    simscape.addConnection(NameValueArgs.BlockPathRoomB,("W"+num2str(connWportB)),fullPathWall,"A");
end