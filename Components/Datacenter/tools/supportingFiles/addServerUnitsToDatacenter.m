function [blkNameDC,listInterThermalRes] = addServerUnitsToDatacenter(NameValueArgs)
% Add server unit to datacenters.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.X (1,1) {mustBeGreaterThan(NameValueArgs.X,0)}
        NameValueArgs.Y (1,1) {mustBeGreaterThan(NameValueArgs.Y,0)}
        NameValueArgs.ServerSubsystemName string {mustBeText}
        NameValueArgs.LibBlkPath struct {mustBeNonempty}
        NameValueArgs.CustomBlkPath struct {mustBeNonempty}
        NameValueArgs.ReferenceLocation (1,4) {mustBeNonempty}
    end

    blkNameDC = strings(NameValueArgs.X,NameValueArgs.Y);
    for i = 1:NameValueArgs.X
        for j = 1:NameValueArgs.Y
            blkNameDC(i,j) = strcat(NameValueArgs.ServerSubsystemName,'/Datacenter_',num2str(i),'_',num2str(j));
            add_block(NameValueArgs.CustomBlkPath.datacenter,blkNameDC(i,j),'Position',NameValueArgs.ReferenceLocation+[0 i-1 0 i-1]*200 + [j-1 0 j-1 0]*200);
        end
    end

    blkNameThResX = strings(NameValueArgs.X,NameValueArgs.Y-1);
    for i = 1:NameValueArgs.X
        for j = 1:NameValueArgs.Y-1
            blkNameThResX(i,j) = strcat(NameValueArgs.ServerSubsystemName,'/ThRes_x',num2str(i),'_y',num2str(j),'y',num2str(j+1));
            add_block(NameValueArgs.LibBlkPath.thermalRes,blkNameThResX(i,j),'Position',NameValueArgs.ReferenceLocation+[0 i-1 0 i-1]*200+[0 50 0 50] + [j-1 0 j-1 0]*200+[100 0 100 0]);
            simscape.addConnection(blkNameDC(i,j),"H",blkNameThResX(i,j),"A");
            simscape.addConnection(blkNameDC(i,j+1),"H",blkNameThResX(i,j),"B")
        end
    end
    blkNameThResY = strings(NameValueArgs.X-1,NameValueArgs.Y);
    for i = 1:NameValueArgs.X-1
        for j = 1:NameValueArgs.Y
            blkNameThResY(i,j) = strcat(NameValueArgs.ServerSubsystemName,'/ThRes_y',num2str(j),'_x',num2str(i),'y',num2str(i+1));
            add_block(NameValueArgs.LibBlkPath.thermalRes,blkNameThResY(i,j),'Position',NameValueArgs.ReferenceLocation+[0 i-1 0 i-1]*200+[0 100 0 100] + [j-1 0 j-1 0]*200+[50 0 50 0]);
            set_param(blkNameThResY(i,j),'Orientation','down');
            simscape.addConnection(blkNameDC(i,j),"H",blkNameThResY(i,j),"A");
            simscape.addConnection(blkNameDC(i+1,j),"H",blkNameThResY(i,j),"B")
        end
    end
    listInterThermalRes = [reshape(blkNameThResX,[NameValueArgs.X*(NameValueArgs.Y-1),1]);...
                           reshape(blkNameThResY,[NameValueArgs.Y*(NameValueArgs.X-1),1])];
end