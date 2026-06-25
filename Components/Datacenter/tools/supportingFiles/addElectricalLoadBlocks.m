function [blkName2phCustomBlock,blkName2phLibraryBlock] = addElectricalLoadBlocks(NameValueArgs)
% Add electrical load blocks.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.NumServer (1,1) {mustBeGreaterThan(NameValueArgs.NumServer,0)}
        NameValueArgs.DatacenterSubsystemName string {mustBeText}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.CustomBlkPath struct {mustBeNonempty}
        NameValueArgs.DatacenterSubsystemLoc (1,4) {mustBeNonempty}
    end

    NameValueArgs.LibBlkPath.dynLoad3ph = 'ee_lib/Passive/Dynamic Load (Three-Phase)';
    NameValueArgs.CustomBlkPath.load3ph = 'datacenter_lib/Custom Dynamic Load (3-phase) block';
    blkName2phCustomBlock = strcat(NameValueArgs.DatacenterSubsystemName,'/THD');
    blkName2phLibraryBlock = strcat(NameValueArgs.DatacenterSubsystemName,'/Load');
    delLength = NameValueArgs.DatacenterSubsystemLoc(1,3)-NameValueArgs.DatacenterSubsystemLoc(1,1);
    add_block(NameValueArgs.CustomBlkPath.load3ph,blkName2phCustomBlock,"Position",[2*delLength 0 2*delLength 0]+NameValueArgs.DatacenterSubsystemLoc);
    set_param(blkName2phCustomBlock,'N',num2str(NameValueArgs.NumServer));
    add_block(NameValueArgs.LibBlkPath.dynLoad3ph,blkName2phLibraryBlock,"Position",[4*delLength 0 4*delLength 0]+NameValueArgs.DatacenterSubsystemLoc);
    set_param(blkName2phLibraryBlock,'Orientation','down');
    simscape.addConnection(blkName2phCustomBlock,"P",blkName2phLibraryBlock,"P");
    simscape.addConnection(blkName2phCustomBlock,"Q",blkName2phLibraryBlock,"Q");
end