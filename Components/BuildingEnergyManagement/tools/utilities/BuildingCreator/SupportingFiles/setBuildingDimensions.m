function msgDisplayCount = setBuildingDimensions(NameValueArgs)
% Set building dimensions.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingBlockPathData struct {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.InternalWallThickness simscape.Value {mustBeNonempty}
        NameValueArgs.ExternalWallThickness simscape.Value {mustBeNonempty}
        NameValueArgs.RoofThickness simscape.Value {mustBeNonempty}
        NameValueArgs.FloorThickness simscape.Value {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.DiagnosticMsgStart (1,1) {mustBeNonnegative} = 0
    end

    setLibraryPathReferences;

    fieldsToExpect = {'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding', 'blkNameRoofsAndGround', 'namePipeInletBldg', 'namePipeOutletBldg'};
    fieldsUserData = fieldnames(NameValueArgs.BuildingBlockPathData);
    
    if all(ismember(fieldsToExpect, fieldsUserData)) && bdIsLoaded(NameValueArgs.BuildingLibraryName)
        msgDisplayCount = NameValueArgs.DiagnosticMsgStart+1;
        msgDisplayCount = displayDiagnostics(ErrorMsg="Setting building dimensions from the part-file.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        % Parameterize rooms
        [nApt,nRooms] = size(NameValueArgs.BuildingBlockPathData.blkNameBldg);
        for i = 1:nApt
            for j = 1:nRooms
                if NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j) == ""
                    disp(strcat("*** Warning: Skipping Apt/Room ",num2str(i),"/",num2str(j)," for room size parameterization."));
                else
                    setParametersForBuilding(BlockPath=NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j),...
                                             BlockType=NameValueArgs.BuildingBlockPathData.blkNameBldgLibType(i,j),...
                                             BuildingAptNum=i,...
                                             BuildingRoomNum=j,...
                                             BuildingData=NameValueArgs.BuildingBlockPathData.partFileBuilding);
                end
            end
        end

        numIntWalls = size(NameValueArgs.BuildingBlockPathData.partFileBuilding.apartment1.room1.geometry.dim.plotInternalWallVert2D,1);
        numExtWalls = size(NameValueArgs.BuildingBlockPathData.partFileBuilding.apartment1.room1.geometry.dim.plotWallVert2D,1);
        
        msgDisplayCount = displayDiagnostics(ErrorMsg="Completed room size parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        % Parameterize external walls
        for i = 1:numExtWalls
            setParametersForBuilding(BlockPath=NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),...
                                     BlockType="External Wall", BuildingAptNum=i,...
                                     BuildingData=NameValueArgs.BuildingBlockPathData.partFileBuilding,...
                                     ExternalWallThickness=NameValueArgs.ExternalWallThickness);
        end
        msgDisplayCount = displayDiagnostics(ErrorMsg="Completed external wall size parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        % Parameterize internal walls
        for i = 1:numIntWalls
            setParametersForBuilding(BlockPath=NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),...
                                     BlockType="Internal Wall",BuildingAptNum=i,...
                                     BuildingData=NameValueArgs.BuildingBlockPathData.partFileBuilding,...
                                     InternalWallThickness=NameValueArgs.InternalWallThickness);
        end
        msgDisplayCount = displayDiagnostics(ErrorMsg="Completed internal wall size parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        
        % Parameterize roof of all levels.
        for i = 1:size(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround,1)
            blkName = NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,1);
            roomRef = NameValueArgs.BuildingBlockPathData.partFileBuilding.(strcat("apartment",NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,4))).(strcat("room",NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,5)));
            len = getParamStr(num2str(roomRef.geometry.dim.length));
            wid = getParamStr(num2str(roomRef.geometry.dim.width));
            set_param(blkName,"wallLength",len);
            set_param(blkName,"wallHeight",wid);
            if NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2) == "WallOpen"
                thk = value(NameValueArgs.FloorThickness,"m");
                thk = getParamStr(num2str(thk));
                set_param(blkName,"wallThickness",thk);
                fracVal = str2double(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,3));
                len = getParamStr(num2str(sqrt(fracVal)*roomRef.geometry.dim.length));
                wid = getParamStr(num2str(sqrt(fracVal)*roomRef.geometry.dim.width));
                set_param(blkName,"ventLength",len);
                set_param(blkName,"ventHeight",wid);
            end
            if NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2) == "Wall"
                thk = value(NameValueArgs.FloorThickness,"m");
                thk = getParamStr(num2str(thk));
                set_param(blkName,"wallThickness",thk);
            end
            if NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2) == "WallSolar"
                thk = value(NameValueArgs.RoofThickness,"m");
                thk = getParamStr(num2str(thk));
                set_param(blkName,"wallThickness",thk);
                surfAngle = getParamStr(num2str(0));
                surfUnitV = getParamStr("[0,-1]");
                set_param(blkName,"surfAngle",surfAngle);
                set_param(blkName,"surfUnitV",surfUnitV);
            end
        end
        msgDisplayCount = displayDiagnostics(ErrorMsg="Completed floor and roof size parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    else
        disp(strcat("*** Error: exiting. Block (",BuildingBlockPathData,") struct must contain fields 'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding' and the model (",NameValueArgs.BuildingLibraryName,") must be loaded."));
    end
end