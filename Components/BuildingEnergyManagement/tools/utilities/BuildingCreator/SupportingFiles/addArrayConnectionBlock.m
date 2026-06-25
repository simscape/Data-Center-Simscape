function blkNameArray = addArrayConnectionBlock(NameValueArgs)
% Add Arracy Connection block
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockName string {mustBeNonempty}
        NameValueArgs.BlockLocation (1,4) {mustBeNonempty}
        NameValueArgs.Domain string {mustBeNonempty}
        NameValueArgs.NumberOfNodes (1,1) {mustBeNonnegative}
        NameValueArgs.Orientation string {mustBeMember(NameValueArgs.Orientation,["left","right"])} = "right"
        NameValueArgs.AddLabel logical {mustBeNumericOrLogical} = false
        NameValueArgs.LabelName string {mustBeNonempty} = "NoName"
        NameValueArgs.LabelSize (1,1) {mustBeGreaterThan(NameValueArgs.LabelSize,5)} = 10
    end

    setLibraryPathReferences;
    blkNameArray = strcat(NameValueArgs.BlockPath,"/",NameValueArgs.BlockName);
    add_block(libBlkPath.arrayConn,blkNameArray,"Position",NameValueArgs.BlockLocation);
    set_param(blkNameArray,"ConcatenateDimension","1");
    set_param(blkNameArray,"NumScalarElements",num2str(NameValueArgs.NumberOfNodes));
    set_param(blkNameArray,"Domain",NameValueArgs.Domain);
    set_param(blkNameArray,"Orientation",NameValueArgs.Orientation);

    delY = max(NameValueArgs.LabelSize,abs(NameValueArgs.BlockLocation(1,4)-NameValueArgs.BlockLocation(1,2))/NameValueArgs.NumberOfNodes);
    labelBaselineLoc = 2*[NameValueArgs.BlockLocation(1,3)-NameValueArgs.BlockLocation(1,1) 0 NameValueArgs.BlockLocation(1,3)-NameValueArgs.BlockLocation(1,1) 0];
    if NameValueArgs.Orientation == "right"
        labelBaselineLoc = labelBaselineLoc*(-1); 
        labelOrientation = "left";
    else
        labelOrientation = "right";
    end
    labelName = strings(1,NameValueArgs.NumberOfNodes);
    if NameValueArgs.AddLabel
        for i = 1:NameValueArgs.NumberOfNodes
            labelName(1,i) = strcat(NameValueArgs.BlockPath,"/",NameValueArgs.LabelName,num2str(i));
            add_block(libBlkPath.labelConn,labelName(1,i),"Position",NameValueArgs.BlockLocation+labelBaselineLoc+[0 (i-1)*delY 0 (i-1)*delY]);
            set_param(labelName(1,i),"Orientation",labelOrientation);
            set_param(labelName(1,i),"Label",strcat(NameValueArgs.LabelName,num2str(i)));
            simscape.addConnection(labelName(1,i),"port",blkNameArray,strcat("elementNode",num2str(i)));
        end
    end
end