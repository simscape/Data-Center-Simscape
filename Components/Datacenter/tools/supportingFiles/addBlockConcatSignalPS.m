function addBlockConcatSignalPS(NameValueArgs)
% Concat PS signals.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.BlkName string {mustBeText}
        NameValueArgs.ConcatColumns {mustBeNonempty} = "true"
        NameValueArgs.LibBlockPath struct {mustBeNonempty}
    end

    count = 0;
    blkNameConcatPort = strings(1,NameValueArgs.X*NameValueArgs.Y);
    for j = 1:NameValueArgs.Y
        for i = 1:NameValueArgs.X
            count = count+1;
            blkNameConcatPort(1,count) = strcat(NameValueArgs.BlkName,'/',num2str(count));
            add_block(NameValueArgs.LibBlockPath.connPort,blkNameConcatPort(1,count),'Position',[50 50*count 70 50*count+20]);
            set_param(blkNameConcatPort(1,count),'Side','left');
        end
    end

    newBlk = 0;
    blkNameConcatNew = strings(1,count-1);
    for i = 1:count-1
        newBlk = newBlk+1;
        blkNameConcatNew(1,i) = strcat(NameValueArgs.BlkName,'/concat',num2str(newBlk));
        add_block(NameValueArgs.LibBlockPath.concatPS,blkNameConcatNew(1,i),'Position',[50+newBlk*50 50*i+10 70+newBlk*50 50*i+10+20]);
        set_param(blkNameConcatNew(1,i),'catColumns',NameValueArgs.ConcatColumns)
    end

    simscape.addConnection(blkNameConcatPort(1,1),"port",blkNameConcatNew(1,1),"I1");
    simscape.addConnection(blkNameConcatPort(1,2),"port",blkNameConcatNew(1,1),"I2");

    for i = 1:newBlk-1
        simscape.addConnection(blkNameConcatNew(1,i),"O",blkNameConcatNew(1,i+1),"I1");
        simscape.addConnection(blkNameConcatPort(1,i+2),"port",blkNameConcatNew(1,i+1),"I2");
    end

    blkNameConcatPortOut = strcat(NameValueArgs.BlkName,'/v');
    add_block(NameValueArgs.LibBlockPath.connPort,blkNameConcatPortOut,'Position',[50+newBlk*50+100 50*i+10 70+newBlk*50+150 50*i+10+20]);
    set_param(blkNameConcatPortOut,'Orientation','left');
    set_param(blkNameConcatPortOut,'Side','right');
    simscape.addConnection(blkNameConcatNew(1,end),"O",blkNameConcatPortOut,"port");
end