function setParamForRoomRadiatorUFP(NameValueArgs)
% Set parameters for room, raditator, and Underfloor piping.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockType string {mustBeMember(NameValueArgs.BlockType,["Room with Radiator","Room with UFP","Room with UFP & Radiator"])}
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.BuildingAptNum (1,1) {mustBeNonnegative}
        NameValueArgs.BuildingRoomNum (1,1) {mustBeNonnegative}
        NameValueArgs.PipingDataTable table {mustBeNonempty}
        NameValueArgs.FloorThermalRes (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.FloorThermalRes, "K/W")}
    end

    roomData = NameValueArgs.BuildingData.("apartment"+NameValueArgs.BuildingAptNum).("room"+NameValueArgs.BuildingRoomNum);
    if NameValueArgs.BlockType == "Room with Radiator" || NameValueArgs.BlockType == "Room with UFP & Radiator"
        % Add parameters for Radiator
        radLen = sqrt(roomData.physics.radiator)*max(roomData.geometry.dim.length,roomData.geometry.dim.width);
        radHgt = sqrt(roomData.physics.radiator)*roomData.geometry.dim.height;
        gap = NameValueArgs.PipingDataTable.RadiatorPipe("Inter-pipe gap (m)");
        nPipes = ceil(radLen/gap);
        % Parameterize
        val = getParamStr(num2str(NameValueArgs.PipingDataTable.RadiatorPipe("Hydraulic Diameter (m)")));
        set_param(NameValueArgs.BlockPath,"pipeHydrDiaR",val);
        val = getParamStr(num2str(radHgt*nPipes));
        set_param(NameValueArgs.BlockPath,"pipeLenR",val);
        val = getParamStr(num2str(NameValueArgs.PipingDataTable.RadiatorPipe("Crossectional area (m^2)")));
        set_param(NameValueArgs.BlockPath,"pipeCrossSectionalAreaR",val);
    end
    if NameValueArgs.BlockType == "Room with UFP" || NameValueArgs.BlockType == "Room with UFP & Radiator"
        % Add parameters for Under floor piping
        UFPLen = sqrt(roomData.physics.radiator)*max(roomData.geometry.dim.length,roomData.geometry.dim.width);
        UFPHgt = sqrt(roomData.physics.radiator)*roomData.geometry.dim.height;
        gap = NameValueArgs.PipingDataTable.UnderFloorPipe("Inter-pipe gap (m)");
        nPipes = ceil(UFPLen/gap);
        % Parameterize
        val = getParamStr(num2str(NameValueArgs.PipingDataTable.UnderFloorPipe("Hydraulic Diameter (m)")));
        set_param(NameValueArgs.BlockPath,"pipeHydrDiaUFP",val);
        val = getParamStr(num2str(UFPHgt*nPipes));
        set_param(NameValueArgs.BlockPath,"pipeLenUFP",val);
        val = getParamStr(num2str(NameValueArgs.PipingDataTable.UnderFloorPipe("Crossectional area (m^2)")));
        set_param(NameValueArgs.BlockPath,"pipeCrossSectionalAreaUFP",val);
        val = getParamStr(num2str(value(NameValueArgs.FloorThermalRes,"K/W")));
        set_param(NameValueArgs.BlockPath,"thermalResFloor",val);
    end
end