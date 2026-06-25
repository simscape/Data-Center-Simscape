function addPortToBlock(NameValueArgs)
% Add port to the block
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.PortLocation (1,4) {mustBeNonempty}
        NameValueArgs.PortType string {mustBeNonempty}
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockPortName string {mustBeNonempty}
        NameValueArgs.PortOrientation string {mustBeNonempty}
        NameValueArgs.PortSide string {mustBeNonempty}
    end

    blkFullName = get_param(NameValueArgs.BlockPath,"Name");
    subSysName = erase(NameValueArgs.BlockPath,blkFullName);
    portFullPath = strcat(subSysName,NameValueArgs.BlockPortName);
    add_block(NameValueArgs.PortType,portFullPath,"Position",NameValueArgs.PortLocation);
    set_param(portFullPath,"Orientation",NameValueArgs.PortOrientation);
    set_param(portFullPath,"Side",NameValueArgs.PortSide);
    simscape.addConnection(NameValueArgs.BlockPath,NameValueArgs.BlockPortName,portFullPath,"port","autorouting","on");
end