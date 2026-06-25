function msgDisplayCount = setBuildingThermalData(NameValueArgs)
% Set building thermal data.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingBlockPathData struct {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.DiagnosticMsgStart (1,1) {mustBeNonnegative} = 0
        NameValueArgs.HeatTransferCoeffInt (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.HeatTransferCoeffInt, "W/(K*m^2)")}
        NameValueArgs.HeatTransferCoeffExt (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.HeatTransferCoeffExt, "W/(K*m^2)")}
        NameValueArgs.MaterialPropTable (6,5) table {mustBeNonempty}
        NameValueArgs.PipingDataTable table {mustBeNonempty} = table(1,1)
        NameValueArgs.GroundThermalRes (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.GroundThermalRes, "K/W")}
        NameValueArgs.IniBuildingTemperature (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.IniBuildingTemperature, "K")}
    end

    setLibraryPathReferences;

    fieldsToExpect = {'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding', 'blkNameRoofsAndGround', 'namePipeInletBldg', 'namePipeOutletBldg'};
    fieldsUserData = fieldnames(NameValueArgs.BuildingBlockPathData);
    
    if all(ismember(fieldsToExpect, fieldsUserData)) && bdIsLoaded(NameValueArgs.BuildingLibraryName)
        msgDisplayCount = NameValueArgs.DiagnosticMsgStart+1;
        [nApt,nRooms] = size(NameValueArgs.BuildingBlockPathData.blkNameBldg);
        
        % % Set initial temperature, HTC values for rooms
        for i = 1:nApt
            for j = 1:nRooms
                if NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j) == ""
                        disp(strcat("*** Warning: Skipping Apt/Room ",num2str(i),"/",num2str(j)," for room thermal parameterization."));
                else
                    val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffInt,"W/(K*m^2)")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j),"htc",val);
                    val = getParamStr(num2str(value(NameValueArgs.IniBuildingTemperature,"K")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j),"iniT",val);
                end
            end
        end
        msgDisplayCount = displayDiagnostics(ErrorMsg="Set initial temperature and heat transfer coefficient values for all rooms.",...
            ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        
        % Check if there is need and/or data to set Radiator + UnderFloor Piping model
        [a,b] = size(NameValueArgs.PipingDataTable);
        expectedTblFields = ["DistributorPipe","RadiatorPipe","UnderFloorPipe"];
        correctTable = all(ismember(NameValueArgs.PipingDataTable.Properties.VariableNames,expectedTblFields));
        nRoomTL = 0;
        if and(and(a==3,b==3),correctTable)
            % Parameterize rooms for radiator and UFP
            for i = 1:nApt
                for j = 1:nRooms
                    if or(NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j)=="", NameValueArgs.BuildingBlockPathData.blkNameBldgLibType(i,j)=="Room")
                        disp(strcat("*** Warning: Skipping Apt/Room ",num2str(i),"/",num2str(j)," for room radiator/under-floor-piping parameterization."));
                    else
                        setParamForRoomRadiatorUFP(BlockPath=NameValueArgs.BuildingBlockPathData.blkNameBldg(i,j),...
                                                   BlockType=NameValueArgs.BuildingBlockPathData.blkNameBldgLibType(i,j),...
                                                   BuildingAptNum=i,BuildingRoomNum=j,...
                                                   BuildingData=NameValueArgs.BuildingBlockPathData.partFileBuilding,...
                                                   PipingDataTable=NameValueArgs.PipingDataTable,...
                                                   FloorThermalRes=NameValueArgs.GroundThermalRes);
                        nRoomTL = nRoomTL+1;
                    end
                end
            end
            if nRoomTL > 0
                msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Parameterized ",num2str(nRoomTL)," rooms with Radiator and/or Underfloor Piping models."),...
                    ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
            end
        end
    else
        disp(strcat("*** Error: exiting. Block (",BuildingBlockPathData,") struct must contain fields 'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding' and the model (",NameValueArgs.BuildingLibraryName,") must be loaded."));
    end
end