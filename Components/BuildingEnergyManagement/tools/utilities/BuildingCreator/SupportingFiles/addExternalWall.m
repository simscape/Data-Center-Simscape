function [blkNameExtWall,blkNameExtWallLoc,connWall,aptn,room] = addExternalWall(NameValueArgs)
% Add external wall library
% 
% Copyright 2025 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.IndexExtWallList (1,1) {mustBeNonnegative}
        NameValueArgs.FloorLevelNumber (1,1) {mustBeNonnegative}
        NameValueArgs.ScaleToPlot (1,1) {mustBeNonnegative}
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.WallSubsystemDim (1,1) {mustBeNonnegative} = 10
        NameValueArgs.MinOpeningFraction (1,1) {mustBeNonnegative} = 0.01
    end

    setLibraryPathReferences;
    [aptn,room,wall,subSysLoc,connWall,fracWin,fracVen] = ...
            getCoordinatesExtWallSubsystem(BuildingData=NameValueArgs.BuildingData,...
            FloorLevelNumber=NameValueArgs.FloorLevelNumber,...
            IndexExtWallList=NameValueArgs.IndexExtWallList,ScaleToPlot=NameValueArgs.ScaleToPlot);
   
    blkNameExtWallLoc = [subSysLoc(1,1)-NameValueArgs.WallSubsystemDim, ...
                         subSysLoc(1,2)-NameValueArgs.WallSubsystemDim, ...
                         subSysLoc(1,1)+NameValueArgs.WallSubsystemDim, ...
                         subSysLoc(1,2)+NameValueArgs.WallSubsystemDim];
    blkNameExtWall = strcat(NameValueArgs.BlockPath,"/ExtWall (A",num2str(aptn),"R",num2str(room),"W",num2str(wall),")");
        
    add_block(customBlkPath.extWall,blkNameExtWall,"Position",blkNameExtWallLoc);
    set_param(blkNameExtWall,"ShowName","off");
    if fracWin > NameValueArgs.MinOpeningFraction && fracVen > NameValueArgs.MinOpeningFraction
        set_param(blkNameExtWall,"extWallModel",int32(3));
    elseif fracWin <= NameValueArgs.MinOpeningFraction && fracVen > NameValueArgs.MinOpeningFraction
        set_param(blkNameExtWall,"extWallModel",int32(4));
    elseif fracWin > NameValueArgs.MinOpeningFraction && fracVen <= NameValueArgs.MinOpeningFraction
        set_param(blkNameExtWall,"extWallModel",int32(2));
    else
        % Solid wall with solar load
        set_param(blkNameExtWall,"extWallModel",int32(1));
    end
end