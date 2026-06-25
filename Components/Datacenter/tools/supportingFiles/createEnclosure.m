function roomModel = createEnclosure(NameValueArgs)
% Create room around datacenter.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.ModelName string {mustBeText}
        NameValueArgs.EnclosureName string {mustBeText} = "Enclosure"
        NameValueArgs.DatacenterModel struct {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    setDatacenterLibPathRef;

    datacenter = NameValueArgs.DatacenterModel;

    if datacenter.Datacenter.Type == "Electrical"
        disp(strcat("ERROR: Datacenter type '",datacenter.Datacenter.Type,"' is not supported for the function 'createEnclosure'."));
        roomModel = [];
    else
        if NameValueArgs.Diagnostics, disp(strcat("Starting to build '",NameValueArgs.EnclosureName,"' Subsystem block.")); end
    
        roomModel.Name = strcat(NameValueArgs.ModelName,'/',NameValueArgs.EnclosureName);
        delLen1 = datacenter.Servers.Location(1,3)-datacenter.Servers.Location(1,1);
        delLen2 = datacenter.Servers.Location(1,4)-datacenter.Servers.Location(1,2);
        roomModel.Location = datacenter.Servers.Location+[2*delLen1 0 2*delLen1 0];
        add_block("built-in/Subsystem",roomModel.Name,"Position",roomModel.Location);
    
        % Add thermal port to enclosure
        [X,Y] = size(datacenter.Servers.Name);
        addThermalPort = strcat(roomModel.Name,'/H');
        portThermalLoc = datacenter.Servers.Location+[-150 0 -150-round(delLen1*0.75) -round(delLen2*0.75)];
        add_block(libBlkPath.connPort,addThermalPort,'Position',portThermalLoc);
        set_param(addThermalPort,'Orientation','right');
        set_param(addThermalPort,'Side','left');
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created thermal node, H.")); end
    
        % Add heat source port
        addHeatPort = strcat(roomModel.Name,'/Q');
        portHeatLoc = datacenter.Servers.Location+[-150 0+delLen2 -150-round(delLen1*0.75) -round(delLen2*0.75)+delLen2];
        add_block(libBlkPath.connPort,addHeatPort,'Position',portHeatLoc);
        set_param(addHeatPort,'Orientation','right');
        set_param(addHeatPort,'Side','left');
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created heat input port, Q.")); end
       
        simscape.addConnection(datacenter.Datacenter.Name,"H",roomModel.Name,"H");
    
        % Add Troom source port
        addTroomPort = strcat(roomModel.Name,'/T');
        portTroomLoc = datacenter.Servers.Location+[-150+delLen1*7.5 delLen2 -150-round(delLen1*0.75)+delLen1*7.5 -round(delLen2*0.75)+delLen2];
        add_block(libBlkPath.connPort,addTroomPort,'Position',portTroomLoc);
        set_param(addTroomPort,'Orientation','left');
        set_param(addTroomPort,'Side','right');
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created output port for room temperature, T.")); end
    
        % Add ambient node
        addAmbPort = strcat(roomModel.Name,'/Amb');
        portAmbLoc = portTroomLoc+[0 delLen2*1.5 0 delLen2*1.5];
        add_block(libBlkPath.connPort,addAmbPort,'Position',portAmbLoc);
        set_param(addAmbPort,'Orientation','left');
        set_param(addAmbPort,'Side','right');
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created ambient thermal node, Amb.")); end
    
        % Add solar port
        addSolarPort = strcat(roomModel.Name,'/Solar');
        portSolarLoc = portTroomLoc+[0 delLen2*3 0 delLen2*3];
        add_block(libBlkPath.connPort,addSolarPort,'Position',portSolarLoc);
        set_param(addSolarPort,'Orientation','left');
        set_param(addSolarPort,'Side','left');
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created input port for solar radiation, Solar.")); end
    
        % Add concatenate for Troom
        blkTroomConcat = strcat(roomModel.Name,'/Tvec');
        blkTroomConcatPos = portTroomLoc-[delLen1 delLen2/2 delLen1 delLen2/2];
        add_block("built-in/Subsystem", blkTroomConcat,"Position",blkTroomConcatPos);
        addBlockConcatSignalPS(X=1,Y=5,BlkName=blkTroomConcat,LibBlockPath=libBlkPath);
    
        wallSide = ["ToRoof","ToWall_X1X2Y1","ToWall_X2Y1Y2","ToWall_X2X1Y2","ToWall_X1Y2Y1"];
        for i = 1:length(wallSide)
            if i == 2
                nodeNumList = X*(1:Y);
            elseif i == 3
                nodeNumList = X*(Y-1)+(1:X);  %(1:X)*Y;
            elseif i == 4
                nodeNumList = [1, X*(1:(Y-1))+1];  %X*(1:Y - 1)+1;
            elseif i == 5
                nodeNumList = 1:X;
            else
                nodeNumList = 1:X*Y;
            end
            airVolumeLoc = datacenter.Servers.Location+[delLen1*(i-1)/2 delLen2*(i-1) delLen1*(i-1)/2-round(delLen1*0.25) delLen2*(i-1)-round(delLen2*0.25)];
            modelData = addAirVolBetweenDatacenterAndWall(TowardsWall=wallSide(1,i),...
                LibBlkPath=libBlkPath,CustomBlkPath=customBlkPath,...
                ReferenceLocation=airVolumeLoc,...
                SubsysName=roomModel.Name,X=X,Y=Y,...
                ConnectNodeArrayElem=nodeNumList);
            roomModel.(wallSide(1,i)) = modelData.(wallSide(1,i));
    
            simscape.addConnection(roomModel.Name,"H",roomModel.(wallSide(1,i)).Name,"H");
            simscape.addConnection(roomModel.Name,"Q",roomModel.(wallSide(1,i)).Name,"Q","autorouting","off");
    
            roomModel.Walls.(wallSide(1,i)).Name = strcat(roomModel.Name,'/Amb',wallSide(1,i));
            roomModel.Walls.(wallSide(1,i)).Loc = airVolumeLoc + [1.2*delLen1 -delLen2/3 1.2*delLen1 -delLen2/3];
            add_block(customBlkPath.extWall,roomModel.Walls.(wallSide(1,i)).Name,'Position',roomModel.Walls.(wallSide(1,i)).Loc);
            set_param(roomModel.Walls.(wallSide(1,i)).Name,'Orientation','left');
            
            simscape.addConnection(roomModel.Walls.(wallSide(1,i)).Name,"B",roomModel.(wallSide(1,i)).Name,"W","autorouting","off");
    
            simscape.addConnection(roomModel.Name,"Amb",roomModel.Walls.(wallSide(1,i)).Name,"A");
    
            simscape.addConnection(roomModel.Name,"Solar",roomModel.Walls.(wallSide(1,i)).Name,"R","autorouting","off");
            
            % Add port from Troom to blocks
            simscape.addConnection(roomModel.(wallSide(1,i)).Name,"T",blkTroomConcat,num2str(i),"autorouting","smart");
        end
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Completed adding stagnant air model around the datacenter.")); end
    
        % Troom port to outside
        simscape.addConnection(blkTroomConcat,"v",addTroomPort,"port");
    
        i = 6; floorLoc = datacenter.Servers.Location+[delLen1*(i-1)/2 delLen2*(i-1) delLen1*(i-1)/2-round(delLen1*0.25) delLen2*(i-1)-round(delLen2*0.25)];
        modelData = connectToEnclosureFloor(LibBlkPath=libBlkPath,ReferenceLocation=floorLoc,...
            SubsysName=roomModel.Name,X=X,Y=Y);
        roomModel.("FloorThermalRes") = modelData.("FloorThermalRes");
    
        roomModel.Walls.("Ground").Name = strcat(roomModel.Name,'/Grd');
        roomModel.Walls.("Ground").Loc = floorLoc + [1.2*delLen1 -delLen2/3 1.2*delLen1 -delLen2/3];
        add_block(customBlkPath.selectWall,roomModel.Walls.("Ground").Name,'Position',roomModel.Walls.("Ground").Loc);
        set_param(roomModel.Walls.("Ground").Name,'Orientation','left');
        set_param(roomModel.Walls.("Ground").Name,'optWall',num2str(int32(1)));
    
        if NameValueArgs.Diagnostics, disp(strcat("*** Created ground thermal port, Grd.")); end
    
        % Add ground port
        addGrdPort = strcat(roomModel.Name,'/G');
        portGrdLoc = roomModel.Walls.("Ground").Loc+[2*delLen1 0 2*delLen1-round(0.5*delLen1) -round(0.5*delLen2)];
        add_block(libBlkPath.connPort,addGrdPort,'Position',portGrdLoc);
        set_param(addGrdPort,'Orientation','left');
        set_param(addGrdPort,'Side','Right');
        simscape.addConnection(roomModel.Walls.("Ground").Name,"A",addGrdPort,"port");
        % simscape.addConnection(roomModel.Name,"W",roomModel.Walls.("Ground").Name,"B");
        simscape.addConnection(roomModel.Name,"H",roomModel.("FloorThermalRes").Name,"H");
        simscape.addConnection(roomModel.Walls.("Ground").Name,"B",roomModel.("FloorThermalRes").Name,"W","autorouting","off");
    
        if NameValueArgs.Diagnostics, disp(strcat("Success: Completed creation of '",NameValueArgs.EnclosureName,"'. Goto Simulink model and save it at your desired location.")); end
    end
end