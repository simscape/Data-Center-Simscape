function outputPortTLoc = collateBuildingTemperatureData(NameValueArgs)
% Collate building temperature port data
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.CanvasPath string {mustBeNonempty}
        NameValueArgs.NumBlocksToConnect (1,1) {mustBeNonnegative}
        NameValueArgs.ConnectToBlock (:,:) string {mustBeNonempty}
        NameValueArgs.BlockIndices (:,2) {mustBeNonempty}
        NameValueArgs.ConnectToBlockPort string {mustBeNonempty}
        NameValueArgs.SizeParameters (1,4) {mustBeNonempty}
        NameValueArgs.BaselineLocation (1,4) {mustBeNonempty}
        NameValueArgs.ConnectionOrder string {mustBeMember(NameValueArgs.ConnectionOrder,["default","reverse"])} = "default"
    end

    setLibraryPathReferences;
    spacingVal = NameValueArgs.SizeParameters(1,1);
    sizeVal = NameValueArgs.SizeParameters(1,3);
    sizeArrayNodeConn = NameValueArgs.SizeParameters(1,4);

    % Add output Tvec port for lib, collating all floor data
    collateRoomTemp = strcat(NameValueArgs.CanvasPath,"/roomT");
    positionSubsystem = NameValueArgs.BaselineLocation+3*[0,sizeArrayNodeConn,0,sizeArrayNodeConn]+5*[spacingVal,-(1/5)*spacingVal,spacingVal,-(1/5)*spacingVal];
    add_block("built-in/Subsystem", collateRoomTemp,"Position",positionSubsystem);
    set_param(collateRoomTemp,"ShowName","off");
    set_param(collateRoomTemp,"ShowPortLabels","none");
    addBlockConcatSignalPS(X=1,Y=NameValueArgs.NumBlocksToConnect,BlkName=collateRoomTemp,LibBlockPath=libBlkPath);
    for i = 1:NameValueArgs.NumBlocksToConnect
        if NameValueArgs.ConnectionOrder == "default"
            simscape.addConnection(collateRoomTemp,num2str(i),NameValueArgs.ConnectToBlock(NameValueArgs.BlockIndices(i,1),NameValueArgs.BlockIndices(i,2)),NameValueArgs.ConnectToBlockPort);
        else
            j = NameValueArgs.NumBlocksToConnect-i+1;
            simscape.addConnection(collateRoomTemp,num2str(i),NameValueArgs.ConnectToBlock(NameValueArgs.BlockIndices(j,1),NameValueArgs.BlockIndices(j,2)),NameValueArgs.ConnectToBlockPort);
        end
    end
    outputPortTLoc = [positionSubsystem(1,1)+0.5*spacingVal (positionSubsystem(1,2)+positionSubsystem(1,4))/2 positionSubsystem(1,1)+0.5*spacingVal+sizeVal (positionSubsystem(1,2)+positionSubsystem(1,4))/2+sizeVal];
    outputPortName = addPortToCanvas(CanvasLocation=NameValueArgs.CanvasPath,...
                                     PortName=NameValueArgs.ConnectToBlockPort,PortSide="right",...
                                     PortLocation=outputPortTLoc);
    simscape.addConnection(collateRoomTemp,"v",outputPortName,"port");
end