function fullPathWall = addFloorOrRoofElement(NameValueArgs)
% Add floor or roof with wall of relevent option (enum).
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.WallType string {mustBeMember(NameValueArgs.WallType,["Solid Wall","Solid Wall with Window","Solid Wall with Solar"])} = "Solid Wall"
        NameValueArgs.WallSubsystemPath string {mustBeNonempty}
        NameValueArgs.WallName string {mustBeNonempty}
        NameValueArgs.WallLocation (1,4) {mustBeNonempty}
        NameValueArgs.WallBoundaryLocation (1,4) {mustBeNonempty}
        NameValueArgs.DisplayColor (1,4) {mustBeNonempty}
    end

    setLibraryPathReferences;
    pathName = strcat(NameValueArgs.WallSubsystemPath,"/",NameValueArgs.WallName);
    add_block("built-in/Area",pathName,"Position",NameValueArgs.WallBoundaryLocation,"BackgroundColor", mat2str(NameValueArgs.DisplayColor));
    fullPathWall = strcat(pathName,"Blk");
    if NameValueArgs.WallType == "Solid Wall"
        % Wall Selector library used
        add_block(customBlkPath.selectWall,fullPathWall,"Position",NameValueArgs.WallLocation);
        set_param(fullPathWall,"optWall",int32(1));
    elseif NameValueArgs.WallType == "Solid Wall with Solar"
        % External Wall library used
        add_block(customBlkPath.extWall,fullPathWall,"Position",NameValueArgs.WallLocation);
        set_param(fullPathWall,"extWallModel",int32(1));
    else
        % Wall Selector library used
        add_block(customBlkPath.selectWall,fullPathWall,"Position",NameValueArgs.WallLocation);
        set_param(fullPathWall,"optWall",int32(2));
    end
end