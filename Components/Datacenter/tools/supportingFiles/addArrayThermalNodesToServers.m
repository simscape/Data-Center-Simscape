function [blkNameThermalPort,listOfThermalRes] = addArrayThermalNodesToServers(NameValueArgs)
% Add Array Connection to all datacenter server units.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.ServerSubsystemName string {mustBeText}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.ReferenceLocation (1,4) {mustBeNonempty}
        NameValueArgs.NameOfServerBlocks {mustBeNonempty} 
    end
    % Add Array of Nodes block
    numX = NameValueArgs.X;
    numY = NameValueArgs.Y;
    blkNameArray = strcat(NameValueArgs.ServerSubsystemName,'/Array of Thermal Nodes');
    add_block(NameValueArgs.LibBlkPath.arrayConn,blkNameArray,'Position',NameValueArgs.ReferenceLocation+[0 numX 0 numX*numY*20]+[numY 0 numY+1 0]*350);
    set_param(blkNameArray,'ConcatenateDimension','1');
    set_param(blkNameArray,'NumScalarElements',num2str(numX*numY));
    set_param(blkNameArray,'Domain','foundation.thermal.thermal');

    % Add Connection Port
    blkNameThermalPort = strcat(NameValueArgs.ServerSubsystemName,'/H');
    add_block(NameValueArgs.LibBlkPath.connPort,blkNameThermalPort,'Position',NameValueArgs.ReferenceLocation+[0 numX+20*numY*(numX-1)-2 0 numX+20*numY*(numX-1)+2]+[numY*470 0 numY*475 0]);
    set_param(blkNameThermalPort,'Orientation','left');
    set_param(blkNameThermalPort,'Side','right');
    simscape.addConnection(blkNameArray,"arrayNode",blkNameThermalPort,"port");

    % Add thermal resistance blocks before array of nodes port.
    count = 0;
    blkNameThResExitNodes = strings(numX,numY);
    for j = 1:numY
        for i = 1:numX
            count = count+1;
            blkNameThResExitNodes(i,j) = strcat(NameValueArgs.ServerSubsystemName,'/Hx',num2str(i),'y',num2str(j));
            add_block(NameValueArgs.LibBlkPath.thermalRes,blkNameThResExitNodes(i,j),'Position',NameValueArgs.ReferenceLocation+[0 (count-1)*25 0 (count-1)*25+5] + [numY 0 numY+1/30 0]*300);
            simscape.addConnection(blkNameThResExitNodes(i,j),"B",blkNameArray,strcat('elementNode',num2str(count)),"autorouting","on");
            simscape.addConnection(NameValueArgs.NameOfServerBlocks(i,j),"H",blkNameThResExitNodes(i,j),"A");
        end
    end
    listOfThermalRes = reshape(blkNameThResExitNodes,[numX*numY,1]);
end