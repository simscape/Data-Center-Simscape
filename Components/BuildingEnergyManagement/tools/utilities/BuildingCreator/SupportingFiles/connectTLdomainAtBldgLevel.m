function connectTLdomainAtBldgLevel(NameValueArgs)
% Connect Thermal Liquid domain pipes
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.PathData struct {mustBeNonempty}
        NameValueArgs.FloorLevel (1,1) {mustBeNonnegative}
        NameValueArgs.BlockIndices (:,2) {mustBeNonempty}
        NameValueArgs.LabelSize (1,1) {mustBeNonnegative} = 6
    end

    setLibraryPathReferences;

    count = 0;
    for idx = 1:size(NameValueArgs.BlockIndices,1)
        i = NameValueArgs.BlockIndices(idx,1);
        j = NameValueArgs.BlockIndices(idx,2);
        if NameValueArgs.PathData.blkNameBldgPhys(i,j) == 1
            count = count+1;
            if NameValueArgs.PathData.nodesPerFloorLvl(NameValueArgs.FloorLevel,2) > 1
                % If there are more than 1 room with TL connection,
                % then there would be Array Connection block.
                % Connect it to individual rooms using Labels
                labelName = strcat(NameValueArgs.PathData.blkNameFloorLevel(NameValueArgs.FloorLevel,1),"/TL_A",num2str(count),"Lib");
                blkLocation = str2num(NameValueArgs.PathData.blkNameBldgLoc(i,j));
                delX = blkLocation(1,3)-blkLocation(1,1);
                delY = blkLocation(1,4)-blkLocation(1,2);
                lblLocation = [-delX*0.2 1.2*delY -delX*0.2+NameValueArgs.LabelSize 1.2*delY+2*NameValueArgs.LabelSize]; % quad3
                add_block(libBlkPath.labelConn,labelName,"Position",[blkLocation(1,1) blkLocation(1,2) blkLocation(1,1) blkLocation(1,2)]+lblLocation);
                set_param(labelName,"Label",strcat("TL_A",num2str(count)));
                set_param(labelName,"Orientation","down");
                simscape.addConnection(NameValueArgs.PathData.blkNameBldg(i,j),"TL_A",labelName,"port");
                    
                labelName = strcat(NameValueArgs.PathData.blkNameFloorLevel(NameValueArgs.FloorLevel,1),"/TL_B",num2str(count),"Lib");
                blkLocation = str2num(NameValueArgs.PathData.blkNameBldgLoc(i,j));
                delX = blkLocation(1,3)-blkLocation(1,1);
                delY = blkLocation(1,4)-blkLocation(1,2);
                lblLocation = [delX -delY/5 delX+NameValueArgs.LabelSize -delY/5+2*NameValueArgs.LabelSize]; % quad1
                add_block(libBlkPath.labelConn,labelName,"Position",[blkLocation(1,1) blkLocation(1,2) blkLocation(1,1) blkLocation(1,2)]+lblLocation);
                set_param(labelName,"Label",strcat("TL_B",num2str(count)));
                set_param(labelName,"Orientation","up");
                simscape.addConnection(NameValueArgs.PathData.blkNameBldg(i,j),"TL_B",labelName,"port");
            else
                % Only one TL port, connect directly (instead of Labels)
                simscape.addConnection(NameValueArgs.PathData.blkNameBldg(i,j),"TL_A",portTLA,"port","autorouting","on");
                simscape.addConnection(NameValueArgs.PathData.blkNameBldg(i,j),"TL_B",portTLB,"port","autorouting","on");
            end
        end
    end
end