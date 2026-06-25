function outputPortName = connectOutputPortFromServer(NameValueArgs)
% Connect output port from datacenter.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.ServerSubsystemName string {mustBeText}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.ReferenceLocation (1,4) {mustBeNonempty}
        NameValueArgs.NameOfServerBlocks {mustBeNonempty}
        NameValueArgs.TypeOfPort string {mustBeMember(NameValueArgs.TypeOfPort,["Electrical","Thermal"])}
    end

    numX = NameValueArgs.X;
    numY = NameValueArgs.Y;
    if NameValueArgs.TypeOfPort == "Electrical"
        blkNameSubsystemConcat = strcat(NameValueArgs.ServerSubsystemName,'/concatP');
        positionSubsystem = NameValueArgs.ReferenceLocation+[100 100 150 150]+[1000 numX*numY*50 1000 numX*numY*50];
        positionPort = NameValueArgs.ReferenceLocation+[100 100 150 150]+[1200 numX*numY*50+50 1200 numX*numY*50+50];
        outputPortName = strcat(NameValueArgs.ServerSubsystemName,'/Pvec');
    elseif NameValueArgs.TypeOfPort == "Thermal"
        blkNameSubsystemConcat = strcat(NameValueArgs.ServerSubsystemName,'/concatT');
        positionSubsystem = NameValueArgs.ReferenceLocation+[100 200 150 250]+[1000 numX*numY*50 1000 numX*numY*50];
        positionPort = NameValueArgs.ReferenceLocation+[100 100 150 150]+[1200 numX*numY*50+150 1200 numX*numY*50+150];
        outputPortName = strcat(NameValueArgs.ServerSubsystemName,'/Tvec');
    else
        % do nothing
    end
    add_block("built-in/Subsystem", blkNameSubsystemConcat,"Position",positionSubsystem);
    addBlockConcatSignalPS(X=numX,Y=numY,BlkName=blkNameSubsystemConcat,LibBlockPath=NameValueArgs.LibBlkPath);
    % Add port
    add_block(NameValueArgs.LibBlkPath.connPort,outputPortName,'Position',positionPort);
    set_param(outputPortName,'Orientation','left');
    set_param(outputPortName,'Side','right');
    simscape.addConnection(blkNameSubsystemConcat,"v",outputPortName,"port");
    if NameValueArgs.TypeOfPort == "Electrical"
        count = 0;
        for j = 1:numY
            for i = 1:numX
                count = count+1;
                simscape.addConnection(blkNameSubsystemConcat,num2str(count),NameValueArgs.NameOfServerBlocks(i,j),"P","autorouting","on");
            end
        end
    else
        count = 0;
        for j = 1:numY
            for i = 1:numX
                count = count+1;
                simscape.addConnection(blkNameSubsystemConcat,num2str(count),NameValueArgs.NameOfServerBlocks(i,j),"To","autorouting","on");
            end
        end
    end
end