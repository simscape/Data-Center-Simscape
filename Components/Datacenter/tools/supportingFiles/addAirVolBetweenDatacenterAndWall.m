function roomModel = addAirVolBetweenDatacenterAndWall(NameValueArgs)
% Add air volumein datacenter room or enclosure.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.CustomBlkPath struct {mustBeNonempty}
        NameValueArgs.ReferenceLocation (1,4) {mustBeNonempty}
        NameValueArgs.TowardsWall string {mustBeNonempty}
        NameValueArgs.SubsysName string {mustBeNonempty}
        NameValueArgs.ConnectNodeArrayElem (1,:) {mustBeNonempty}
    end

    N = NameValueArgs.X*NameValueArgs.Y;
    delLen1 = NameValueArgs.ReferenceLocation(1,3)-NameValueArgs.ReferenceLocation(1,1);
    delLen2 = NameValueArgs.ReferenceLocation(1,4)-NameValueArgs.ReferenceLocation(1,2);

    roomModel.(NameValueArgs.TowardsWall).Name = strcat(NameValueArgs.SubsysName,'/',NameValueArgs.TowardsWall);
    roomModel.(NameValueArgs.TowardsWall).Location = NameValueArgs.ReferenceLocation;
    add_block("built-in/Subsystem",roomModel.(NameValueArgs.TowardsWall).Name,"Position",roomModel.(NameValueArgs.TowardsWall).Location);

    roomModel.(NameValueArgs.TowardsWall).PortH.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/H');
    roomModel.(NameValueArgs.TowardsWall).PortH.Loc = NameValueArgs.ReferenceLocation+[-10 0 -10-round(delLen1*0.75) -round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.(NameValueArgs.TowardsWall).PortH.Name,'Position',roomModel.(NameValueArgs.TowardsWall).PortH.Loc);
    set_param(roomModel.(NameValueArgs.TowardsWall).PortH.Name,'Orientation','right');
    set_param(roomModel.(NameValueArgs.TowardsWall).PortH.Name,'Side','left');

    roomModel.(NameValueArgs.TowardsWall).PortQ.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Q');
    %roomModel.(NameValueArgs.TowardsWall).PortQ.Loc = NameValueArgs.ReferenceLocation+[100 delLen2*N/10 100-round(delLen1*0.75) delLen2*N/10-round(delLen2*0.75)];
    roomModel.(NameValueArgs.TowardsWall).PortQ.Loc = NameValueArgs.ReferenceLocation+[delLen1*4 delLen2*N/10 delLen1*4-round(delLen1*0.75) delLen2*N/10-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.(NameValueArgs.TowardsWall).PortQ.Name,'Position',roomModel.(NameValueArgs.TowardsWall).PortQ.Loc);
    set_param(roomModel.(NameValueArgs.TowardsWall).PortQ.Name,'Orientation','right');
    set_param(roomModel.(NameValueArgs.TowardsWall).PortQ.Name,'Side','left');

    distFromLeftSide = 10;
    
    roomModel.(NameValueArgs.TowardsWall).PortW.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/W');
    roomModel.(NameValueArgs.TowardsWall).PortW.Loc = NameValueArgs.ReferenceLocation+[distFromLeftSide*delLen1 0 distFromLeftSide*delLen1-round(delLen1*0.75) 0-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.(NameValueArgs.TowardsWall).PortW.Name,'Position',roomModel.(NameValueArgs.TowardsWall).PortW.Loc);
    set_param(roomModel.(NameValueArgs.TowardsWall).PortW.Name,'Orientation','left');
    set_param(roomModel.(NameValueArgs.TowardsWall).PortW.Name,'Side','right');

    roomModel.(NameValueArgs.TowardsWall).PortT.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/T');
    roomModel.(NameValueArgs.TowardsWall).PortT.Loc = NameValueArgs.ReferenceLocation+[distFromLeftSide*delLen1 delLen2 distFromLeftSide*delLen1-round(delLen1*0.75) delLen2-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.connPort,roomModel.(NameValueArgs.TowardsWall).PortT.Name,'Position',roomModel.(NameValueArgs.TowardsWall).PortT.Loc);
    set_param(roomModel.(NameValueArgs.TowardsWall).PortT.Name,'Orientation','left');
    set_param(roomModel.(NameValueArgs.TowardsWall).PortT.Name,'Side','right');

    % Add array of thermal node to enclosure
    blkNameArray = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Array of Thermal Nodes');
    blkNameArrayLoc = NameValueArgs.ReferenceLocation+[delLen1 0 delLen1-round(delLen1*0.75) 0-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.arrayConn,blkNameArray,'Position',blkNameArrayLoc);
    set_param(blkNameArray,'ConcatenateDimension','1');
    set_param(blkNameArray,'NumScalarElements',num2str(NameValueArgs.X*NameValueArgs.Y));
    set_param(blkNameArray,'Domain','foundation.thermal.thermal');
    set_param(blkNameArray,'Orientation','left');
    simscape.addConnection(blkNameArray,"arrayNode",roomModel.(NameValueArgs.TowardsWall).PortH.Name,"port");

    roomModel.(NameValueArgs.TowardsWall).GainPS.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Qfrac');
    roomModel.(NameValueArgs.TowardsWall).GainPS.Loc = roomModel.(NameValueArgs.TowardsWall).PortQ.Loc+[50 0 50 0];
    add_block(NameValueArgs.LibBlkPath.gainBlock,roomModel.(NameValueArgs.TowardsWall).GainPS.Name,'Position',roomModel.(NameValueArgs.TowardsWall).GainPS.Loc);
    simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).GainPS.Name,"I",roomModel.(NameValueArgs.TowardsWall).PortQ.Name,"port");

    roomModel.(NameValueArgs.TowardsWall).AirMass.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/AirMass');
    roomModel.(NameValueArgs.TowardsWall).AirMass.Loc = roomModel.(NameValueArgs.TowardsWall).PortQ.Loc+[150 0 150+80 80];
    add_block(NameValueArgs.CustomBlkPath.roomVol,roomModel.(NameValueArgs.TowardsWall).AirMass.Name,'Position',roomModel.(NameValueArgs.TowardsWall).AirMass.Loc);

    roomModel.(NameValueArgs.TowardsWall).WallConv.Name = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Wconv');
    roomModel.(NameValueArgs.TowardsWall).WallConv.Loc = roomModel.(NameValueArgs.TowardsWall).AirMass.Loc + [delLen1 -delLen2 delLen1-round(delLen1*0.75) -delLen2-round(delLen2*0.75)];
    add_block(NameValueArgs.LibBlkPath.convHeatTransfer,roomModel.(NameValueArgs.TowardsWall).WallConv.Name,'Position',roomModel.(NameValueArgs.TowardsWall).WallConv.Loc);
    set_param(roomModel.(NameValueArgs.TowardsWall).WallConv.Name,'Orientation','up');

    simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).GainPS.Name,"O",roomModel.(NameValueArgs.TowardsWall).AirMass.Name,"S");
    simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).AirMass.Name,"M2",roomModel.(NameValueArgs.TowardsWall).WallConv.Name,"A");
    simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).WallConv.Name,"B",roomModel.(NameValueArgs.TowardsWall).PortW.Name,"port");
    simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).AirMass.Name,"T",roomModel.(NameValueArgs.TowardsWall).PortT.Name,"port");

    connectThermalNodes = NameValueArgs.ConnectNodeArrayElem;
    totalList = 1:NameValueArgs.X*NameValueArgs.Y;
    idx = ~ismember(totalList,connectThermalNodes);
    if isempty(idx)
        otherThermalNodes = [];
    else
        otherThermalNodes = totalList(1,idx);
    end
    % Connect convection block
    % ***DEACTIVATED*** % set_param(roomModel.(NameValueArgs.TowardsWall).AirMass.Name,'N1',num2str(length(connectThermalNodes)));
    
    refLoc = blkNameArrayLoc + [1.5*delLen1 -3*delLen2 1.5*delLen1 -3*delLen2];%[xyVal(1,1) 0 xyVal(1,3) blkNameArrayLoc(1,4)-blkNameArrayLoc(1,2)];
    for i = 1:length(connectThermalNodes)
        roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Name',num2str(i))) = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Qconv',num2str(i));
        roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Loc',num2str(i))) = refLoc +[0 20*(i-1) 0 20*(i-1)];
        add_block(NameValueArgs.LibBlkPath.convHeatTransfer,roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Name',num2str(i))),'Position',roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Loc',num2str(i))));
        simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Name',num2str(i))),"A",blkNameArray,strcat('elementNode',num2str(connectThermalNodes(1,i))),"autorouting","smart");
        simscape.addConnection(roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Name',num2str(i))),"B",roomModel.(NameValueArgs.TowardsWall).AirMass.Name,'M1',"autorouting","smart");
    end
    if ~isempty(otherThermalNodes)
        insulatorName = strcat(roomModel.(NameValueArgs.TowardsWall).Name,'/Ins');
        insulatorLoc = roomModel.(NameValueArgs.TowardsWall).HeatConv.(strcat('Loc',num2str(length(connectThermalNodes))))+[0 50 0 50];
        add_block(NameValueArgs.LibBlkPath.insulator,insulatorName,'Position',insulatorLoc);
        set_param(insulatorName,'Orientation','up');
        for i = 1:length(otherThermalNodes)
            simscape.addConnection(insulatorName,"A",blkNameArray,strcat('elementNode',num2str(otherThermalNodes(1,i))),"autorouting","smart");
        end
    end
end