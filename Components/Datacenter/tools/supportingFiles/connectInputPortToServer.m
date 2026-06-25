function blkNameUvecPort = connectInputPortToServer(NameValueArgs)
% Connect input port to datacenter.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.ServerSubsystemName string {mustBeText}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.NameOfServerBlocks {mustBeNonempty}
    end
    
    blkNameUvecPort = strcat(NameValueArgs.ServerSubsystemName,'/U');
    add_block(NameValueArgs.LibBlkPath.connPort,blkNameUvecPort,'Position',[0 200 20 220]);
    set_param(blkNameUvecPort,'Orientation','right');
    set_param(blkNameUvecPort,'Side','left');

    %% Add input signal block
    blkNameInputPort = strings(1,NameValueArgs.X*NameValueArgs.Y);
    for i = 1:NameValueArgs.X*NameValueArgs.Y
        blkNameInputPort(1,i) = strcat(NameValueArgs.ServerSubsystemName,'/U',num2str(i));
        add_block(NameValueArgs.LibBlkPath.selectorPS,blkNameInputPort(1,i),'Position',[200 100+20*i 210 100+20*i+10]);
        set_param(blkNameInputPort(1,i),'Orientation','right');
        set_param(blkNameInputPort(1,i),'ix',num2str(i));
        simscape.addConnection(blkNameInputPort(1,i),"I",blkNameUvecPort,"port");
    end

    count = 0;
    for j = 1:NameValueArgs.Y
        for i = 1:NameValueArgs.X
            count = count+1;
            simscape.addConnection(blkNameInputPort(1,count),"O",NameValueArgs.NameOfServerBlocks(i,j),"U","autorouting","on");
        end
    end

end