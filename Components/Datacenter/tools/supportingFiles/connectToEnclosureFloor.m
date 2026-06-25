function roomModel = connectToEnclosureFloor(NameValueArgs)
% Connect to floor of the room.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.ReferenceLocation (1,4) {mustBeNonempty}
        NameValueArgs.SubsysName string {mustBeNonempty}
    end

    N = NameValueArgs.X*NameValueArgs.Y;
    delLen1 = NameValueArgs.ReferenceLocation(1,3)-NameValueArgs.ReferenceLocation(1,1);
    delLen2 = NameValueArgs.ReferenceLocation(1,4)-NameValueArgs.ReferenceLocation(1,2);

    roomModel.("FloorThermalRes").Name = strcat(NameValueArgs.SubsysName,'/',("FloorThermalRes"));
    roomModel.("FloorThermalRes").Location = NameValueArgs.ReferenceLocation;
    add_block("built-in/Subsystem",roomModel.("FloorThermalRes").Name,"Position",roomModel.("FloorThermalRes").Location);

    roomModel.("FloorThermalRes").PortH.Name = strcat(roomModel.("FloorThermalRes").Name,'/H');
    roomModel.("FloorThermalRes").PortH.Loc = NameValueArgs.ReferenceLocation+[-10 0 -10-round(delLen1*0.75) -round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.("FloorThermalRes").PortH.Name,'Position',roomModel.("FloorThermalRes").PortH.Loc);
    set_param(roomModel.("FloorThermalRes").PortH.Name,'Orientation','right');
    set_param(roomModel.("FloorThermalRes").PortH.Name,'Side','left');

    distFromLeftSide = 5;
    
    roomModel.("FloorThermalRes").PortW.Name = strcat(roomModel.("FloorThermalRes").Name,'/W');
    roomModel.("FloorThermalRes").PortW.Loc = NameValueArgs.ReferenceLocation+[distFromLeftSide*delLen1 0 distFromLeftSide*delLen1-round(delLen1*0.75) 0-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.("FloorThermalRes").PortW.Name,'Position',roomModel.("FloorThermalRes").PortW.Loc);
    set_param(roomModel.("FloorThermalRes").PortW.Name,'Orientation','left');
    set_param(roomModel.("FloorThermalRes").PortW.Name,'Side','right');

    % Add array of thermal node to enclosure
    blkNameArray = strcat(roomModel.("FloorThermalRes").Name,'/Array of Thermal Nodes');
    blkNameArrayLoc = NameValueArgs.ReferenceLocation+[delLen1 0 delLen1-round(delLen1*0.75) 0-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.arrayConn,blkNameArray,'Position',blkNameArrayLoc);
    set_param(blkNameArray,'ConcatenateDimension','1');
    set_param(blkNameArray,'NumScalarElements',num2str(NameValueArgs.X*NameValueArgs.Y));
    set_param(blkNameArray,'Domain','foundation.thermal.thermal');
    set_param(blkNameArray,'Orientation','left');
    simscape.addConnection(blkNameArray,"arrayNode",roomModel.("FloorThermalRes").PortH.Name,"port");

    refLoc = blkNameArrayLoc + [1.5*delLen1 -3*delLen2 1.5*delLen1 -3*delLen2];
    for i = 1:N
        roomModel.("FloorThermalRes").HeatConv.(strcat('Name',num2str(i))) = strcat(roomModel.("FloorThermalRes").Name,'/Qconv',num2str(i));
        roomModel.("FloorThermalRes").HeatConv.(strcat('Loc',num2str(i))) = refLoc +[0 20*(i-1) 0 20*(i-1)];
        add_block(NameValueArgs.LibBlkPath.convHeatTransfer,roomModel.("FloorThermalRes").HeatConv.(strcat('Name',num2str(i))),'Position',roomModel.("FloorThermalRes").HeatConv.(strcat('Loc',num2str(i))));
        simscape.addConnection(roomModel.("FloorThermalRes").HeatConv.(strcat('Name',num2str(i))),"A",blkNameArray,strcat('elementNode',num2str(i)),"autorouting","smart");
        simscape.addConnection(roomModel.("FloorThermalRes").HeatConv.(strcat('Name',num2str(i))),"B",roomModel.("FloorThermalRes").PortW.Name,"port","autorouting","smart");
    end
end