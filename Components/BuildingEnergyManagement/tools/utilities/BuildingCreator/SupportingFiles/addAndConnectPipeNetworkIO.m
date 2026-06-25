function [namePipeNetworkIn,namePipeNetworkOut] = addAndConnectPipeNetworkIO(NameValueArgs)
% Add pipe network at inlet and outlet of building for the thermal liquid
% variant.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.SubsysPathList struct {mustBeNonempty}
        NameValueArgs.TotalNumFloors (1,1) {mustBeNonnegative}
        NameValueArgs.SizeParameters (1,4) {mustBeNonempty}
    end
    
    setLibraryPathReferences;
    spacingVal = NameValueArgs.SizeParameters(1,1);
    wallSubsystemDim = NameValueArgs.SizeParameters(1,2);
    sizeVal = NameValueArgs.SizeParameters(1,3);
    sizeArrayNodeConn = NameValueArgs.SizeParameters(1,4);
    
    namePipeNetworkOut = strings(NameValueArgs.TotalNumFloors,1);
    namePipeNetworkIn = strings(NameValueArgs.TotalNumFloors,1);
    
    count = 0;
    for i = 1:NameValueArgs.TotalNumFloors
        strItr = count+1;
        endItr = count+NameValueArgs.SubsysPathList.nodesPerFloorLvl(i,1);
        count = endItr;
        locBlock = [400,400+strItr*sizeVal,400+sizeVal,400+endItr*sizeVal];
        %% Inlet
        if NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2) > 0
            blkNameArray = addPortAndArrayOfConnection(Domain="foundation.thermal_liquid.thermal_liquid",...
                ArrayConnectionLocation=locBlock,...
                BlockPath=NameValueArgs.SubsysPathList.nameArrayNodesInletBldg,...
                PortName=strcat("TL_A",num2str(NameValueArgs.TotalNumFloors-i)),PortSide="right",AddLabel=false,...
                NumberNodes=NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2),...
                SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
            simscape.addConnection(NameValueArgs.SubsysPathList.nameArrayNodesInletBldg,strcat("TL_A",num2str(NameValueArgs.TotalNumFloors-i)),NameValueArgs.SubsysPathList.blkNameFloorLevel(NameValueArgs.TotalNumFloors-i+1,1),"TL_A");
        end
        % Add ports
        if i == 1
            portAmbA = addPortToCanvas(CanvasLocation=NameValueArgs.SubsysPathList.nameArrayNodesInletBldg,...
                PortName="Amb",PortSide="left",...
                PortLocation=[locBlock(1,1),locBlock(1,2),locBlock(1,1)+sizeVal,locBlock(1,2)+sizeVal]...
                             -[8*sizeArrayNodeConn,sizeArrayNodeConn,8*sizeArrayNodeConn,sizeArrayNodeConn]);
            portTLA = addPortToCanvas(CanvasLocation=NameValueArgs.SubsysPathList.nameArrayNodesInletBldg,...
                PortName="in",PortSide="left",...
                PortLocation=[locBlock(1,1),locBlock(1,2)+4*sizeVal,locBlock(1,1)+sizeVal,locBlock(1,2)+5*sizeVal]...
                             -[8*sizeArrayNodeConn,sizeArrayNodeConn,8*sizeArrayNodeConn,sizeArrayNodeConn]);
        end
        if NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2) > 0
            % Add vertical pipes
            namePipeNetworkIn(i,1) = strcat(NameValueArgs.SubsysPathList.nameArrayNodesInletBldg,"/VertPipe",num2str(NameValueArgs.TotalNumFloors-i));
            add_block(libBlkPath.pipe,namePipeNetworkIn(i,1),"Position",[locBlock(1,1)-2*spacingVal,locBlock(1,2),locBlock(1,1)-spacingVal,locBlock(1,2)+spacingVal]);
            for j = 1:NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2)
                simscape.addConnection(namePipeNetworkIn(i,1),"B",blkNameArray,strcat("elementNode",num2str(j)),"autorouting","off");
            end
            simscape.addConnection(namePipeNetworkIn(i,1),"A",portTLA,"port","autorouting","off");
            simscape.addConnection(namePipeNetworkIn(i,1),"H",portAmbA,"port","autorouting","off");
        end
        
        %% Outlet
        if NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2) > 0
            blkNameArray = addPortAndArrayOfConnection(Domain="foundation.thermal_liquid.thermal_liquid",...
                ArrayConnectionLocation=locBlock,...
                BlockPath=NameValueArgs.SubsysPathList.nameArrayNodesOutletBldg,...
                PortName=strcat("TL_B",num2str(NameValueArgs.TotalNumFloors-i)),PortSide="left",AddLabel=false,...
                NumberNodes=NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2),...
                SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
            simscape.addConnection(NameValueArgs.SubsysPathList.nameArrayNodesOutletBldg,strcat("TL_B",num2str(NameValueArgs.TotalNumFloors-i)),NameValueArgs.SubsysPathList.blkNameFloorLevel(NameValueArgs.TotalNumFloors-i+1,1),"TL_B");
        end
        % Add ports
        if i == 1
            portAmbB = addPortToCanvas(CanvasLocation=NameValueArgs.SubsysPathList.nameArrayNodesOutletBldg,...
                PortName="Amb",PortSide="right",...
                PortLocation=[locBlock(1,1),locBlock(1,2),locBlock(1,1)+sizeVal,locBlock(1,2)+sizeVal]...
                             +[8*sizeArrayNodeConn,sizeArrayNodeConn,8*sizeArrayNodeConn,sizeArrayNodeConn]);
            portTLB = addPortToCanvas(CanvasLocation=NameValueArgs.SubsysPathList.nameArrayNodesOutletBldg,...
                PortName="out",PortSide="right",...
                PortLocation=[locBlock(1,1),locBlock(1,2)+4*sizeVal,locBlock(1,1)+sizeVal,locBlock(1,2)+5*sizeVal]...
                             +[8*sizeArrayNodeConn,sizeArrayNodeConn,8*sizeArrayNodeConn,sizeArrayNodeConn]);
        end
        if NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2) > 0
            % Add vertical pipes
            namePipeNetworkOut(i,1) = strcat(NameValueArgs.SubsysPathList.nameArrayNodesOutletBldg,"/VertPipe",num2str(NameValueArgs.TotalNumFloors-i));
            add_block(libBlkPath.pipe,namePipeNetworkOut(i,1),"Position",[locBlock(1,1)+2*spacingVal,locBlock(1,2),locBlock(1,1)+3*spacingVal,locBlock(1,2)+spacingVal]);
            set_param(namePipeNetworkOut(i,1),"Orientation","left");
            for j = 1:NameValueArgs.SubsysPathList.nodesPerFloorLvl(NameValueArgs.TotalNumFloors-i+1,2)
                simscape.addConnection(namePipeNetworkOut(i,1),"B",blkNameArray,strcat("elementNode",num2str(j)),"autorouting","off");
            end
            simscape.addConnection(namePipeNetworkOut(i,1),"A",portTLB,"port","autorouting","off");
            simscape.addConnection(namePipeNetworkOut(i,1),"H",portAmbB,"port","autorouting","off");
        end
    end

end