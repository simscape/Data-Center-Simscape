function [lvlSubsysName,flrSubsysName,libNameBldg,blkFloorLoc] = addFloorLevelSubsystem(NameValueArgs)
% Add floor subsystem to the building
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel struct {mustBeNonempty}
        NameValueArgs.ModelName string {mustBeNonempty}
        NameValueArgs.LocationStartX (1,1) {mustBeNonnegative} = 200
        NameValueArgs.GapBetweenFloors (1,1) {mustBeNonnegative} = 40
        NameValueArgs.FloorSubsystemSize (1,2) {mustBeNonnegative} = [100,80]
    end

    nFloorTotal = NameValueArgs.BuildingModel.("apartment1").("room1").geometry.dim.topFloorLevelNum;
    lvlSubsysDim.X = NameValueArgs.FloorSubsystemSize(1,1);
    lvlSubsysDim.Y = NameValueArgs.FloorSubsystemSize(1,2);
    lvlSubsysGap = NameValueArgs.GapBetweenFloors;
    lvlSubsysName = strings(nFloorTotal,1);
    maxCanvasHeight = (nFloorTotal+1)*lvlSubsysGap+lvlSubsysDim.Y*nFloorTotal+2*lvlSubsysGap;
    locBaselineBlk = [NameValueArgs.LocationStartX,maxCanvasHeight-lvlSubsysDim.Y,NameValueArgs.LocationStartX+lvlSubsysDim.X,maxCanvasHeight];
    locBaselineFlr = [NameValueArgs.LocationStartX,maxCanvasHeight-lvlSubsysDim.Y-0.65*lvlSubsysGap,NameValueArgs.LocationStartX+lvlSubsysDim.X,maxCanvasHeight-lvlSubsysDim.Y-0.3*lvlSubsysGap];

    libNameBldg = strcat(NameValueArgs.ModelName,"/",NameValueArgs.ModelName,"Lib");
    add_block("built-in/Subsystem",libNameBldg,"Position",[300 300 400 400]);
    set_param(libNameBldg,"ShowName","on");

    blkFloorLoc = zeros(nFloorTotal,4);
    for fLvl = 1:nFloorTotal
        blkFloorLoc(fLvl,:) = locBaselineBlk+[0 -fLvl*(lvlSubsysDim.Y+lvlSubsysGap) 0 -fLvl*(lvlSubsysDim.Y+lvlSubsysGap)];
        lvlSubsysName(fLvl,1) = strcat(libNameBldg,"/Level",num2str(fLvl-1));
        add_block("built-in/Subsystem",lvlSubsysName(fLvl,1),"Position",blkFloorLoc(fLvl,:));
        set_param(lvlSubsysName(fLvl,1),"ShowName","off");
    end
    flrSubsysName = strings(nFloorTotal+1,1);
    for fLvl = 1:nFloorTotal+1
        blkFloorRoofLoc = locBaselineFlr+[0,-(fLvl-1)*(lvlSubsysDim.Y+lvlSubsysGap)+0.25*lvlSubsysGap,0,-(fLvl-1)*(lvlSubsysDim.Y+lvlSubsysGap)+0.25*lvlSubsysGap];
        if fLvl == 1
            flrSubsysName(fLvl,1) = strcat(libNameBldg,"/Ground");
        elseif fLvl == nFloorTotal+1
            flrSubsysName(fLvl,1) = strcat(libNameBldg,"/Roof");
        else
            flrSubsysName(fLvl,1) = strcat(libNameBldg,"/ConnectLevel",num2str(fLvl-2),"and",num2str(fLvl-1));
        end
        add_block("built-in/Subsystem",flrSubsysName(fLvl,1),"Position",blkFloorRoofLoc);
        set_param(flrSubsysName(fLvl,1),"ShowName","off");
    end
end