function specifyEnclosureSizeAndOrientation(NameValueArgs)
% Specify datacenter room size and orientation.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.DatacenterMatrixSize (1,2) {mustBeNonnegative}
        NameValueArgs.RoomModel struct
        NameValueArgs.RoomLength (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomLength, "m")}
        NameValueArgs.RoomWidth (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomWidth, "m")}
        NameValueArgs.RoomHeight (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomHeight, "m")}
        NameValueArgs.WallThickness (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.WallThickness, "m")}
        NameValueArgs.RoomRotate (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomRotate, "deg")}
        NameValueArgs.PercentAirVolInRoom (1,1) {mustBeBetween(NameValueArgs.PercentAirVolInRoom,0,100)} = 10
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    X = NameValueArgs.DatacenterMatrixSize(1,1);
    Y = NameValueArgs.DatacenterMatrixSize(1,2);
    roomLenX = value(NameValueArgs.RoomLength,"m");
    roomLenY = value(NameValueArgs.RoomWidth,"m");
    roomLenZ = value(NameValueArgs.RoomHeight,"m");
    dX = roomLenX/X;
    dY = roomLenY/Y;
    dZ = roomLenZ;
    percentRoomAirVol = NameValueArgs.PercentAirVolInRoom;
    wallThickness_m = value(NameValueArgs.WallThickness,"m");
    roomRotate = value(NameValueArgs.RoomRotate,"deg");
    
    airVol = roomLenX*roomLenY*roomLenZ*percentRoomAirVol/100;
    airThick = airVol/(2*(roomLenX+roomLenY)*roomLenZ+roomLenX*roomLenY);
    
    if NameValueArgs.Diagnostics, disp(strcat("*** Air volume layer thickness calculated = ",num2str(airThick)," m.")); end

    wallSide = ["ToRoof","ToWall_X1X2Y1","ToWall_X2Y1Y2","ToWall_X2X1Y2","ToWall_X1Y2Y1"];
    
    % Parameterize air volume blocks
    wallArea = [dX*dY, dX*dZ, dY*dZ, dX*dZ, dY*dZ];
    totWallArea = [roomLenX*roomLenY, roomLenX*roomLenZ, roomLenY*roomLenZ, roomLenX*roomLenZ, roomLenY*roomLenZ];
    totAirVolLen = [roomLenX, roomLenX, roomLenY, roomLenX, roomLenY];
    totAirVolWid = [roomLenY, airThick, airThick, airThick, airThick];
    totAirVolHgt = [airThick, roomLenY, roomLenZ, roomLenZ, roomLenZ];
    for i = 1:length(wallSide)
        numElem = length(fieldnames(NameValueArgs.RoomModel.(wallSide(1,i)).HeatConv))/2;
        for j = 1:numElem
            blkName = NameValueArgs.RoomModel.(wallSide(1,i)).HeatConv.("Name"+j);
            set_param(blkName,"area",num2str(wallArea(1,i)));
        end
        blkName = NameValueArgs.RoomModel.(wallSide(1,i)).WallConv.Name;
        set_param(blkName,"area",num2str(totWallArea(1,i)));
        blkName = NameValueArgs.RoomModel.(wallSide(1,i)).AirMass.Name;
        set_param(blkName,"length",num2str(totAirVolLen(1,i)));
        set_param(blkName,"width",num2str(totAirVolWid(1,i)));
        set_param(blkName,"height",num2str(totAirVolHgt(1,i)));
        blkName = NameValueArgs.RoomModel.(wallSide(1,i)).GainPS.Name;
        set_param(blkName,"gain",num2str(totWallArea(1,i)/sum(totWallArea)));
        if NameValueArgs.Diagnostics, disp(strcat("*** Updated solid surface '",wallSide(1,i),"'.")); end
    end
    % Floor model
    numElem = length(fieldnames(NameValueArgs.RoomModel.FloorThermalRes.HeatConv))/2;
    for i = 1:numElem
        blkName = NameValueArgs.RoomModel.FloorThermalRes.HeatConv.("Name"+i);
        set_param(blkName,"area",num2str(dX*dY));
    end
    
    wallSide = ["ToRoof","ToWall_X1X2Y1","ToWall_X2Y1Y2","ToWall_X2X1Y2","ToWall_X1Y2Y1"];
    wallLen = [roomLenX roomLenX roomLenY roomLenX roomLenY];
    wallHgt = [roomLenY roomLenZ roomLenZ roomLenZ roomLenZ];
    roomOrigAngleOnXYplane = [270; 270; 0; 90; 180];
    roomWallAngleDeg = [0 90 90 90 90];

    newAngles = mod(roomOrigAngleOnXYplane+roomRotate,360);
    unitNormalVectorWall = [cos(deg2rad(newAngles)),sin(deg2rad(newAngles))];
    for i = 1:length(wallSide)
        blkName = NameValueArgs.RoomModel.Walls.(wallSide(1,i)).Name;
        set_param(blkName,"wallLength",num2str(wallLen(1,i)));
        set_param(blkName,"wallHeight",num2str(wallHgt(1,i)));
        set_param(blkName,"wallThickness",num2str(wallThickness_m));
        set_param(blkName,"surfUnitV",strcat("[",num2str(unitNormalVectorWall(i,:)),"]"));
        set_param(blkName,"surfAngle",num2str(roomWallAngleDeg(1,i)));
    end
    blkName = NameValueArgs.RoomModel.Walls.Ground.Name;
    set_param(blkName,"wallLength",num2str(wallLen(1,1)));
    set_param(blkName,"wallHeight",num2str(wallHgt(1,1)));
    set_param(blkName,"wallThickness",num2str(wallThickness_m));

    if NameValueArgs.Diagnostics, disp(strcat("*** Updated floor data.")); end
end