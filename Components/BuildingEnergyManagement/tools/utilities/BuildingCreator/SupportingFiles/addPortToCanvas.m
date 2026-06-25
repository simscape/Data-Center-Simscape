function portPath = addPortToCanvas(NameValueArgs)
% Add port to Simulink canvas
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.CanvasLocation string {mustBeNonempty}
        NameValueArgs.PortName string {mustBeNonempty}
        NameValueArgs.PortLocation (1,4) {mustBeNonempty}
        NameValueArgs.PortSide string {mustBeMember(NameValueArgs.PortSide,["left","right"])}
    end
    
    setLibraryPathReferences;
    portPath = strcat(NameValueArgs.CanvasLocation,"/",NameValueArgs.PortName);
    add_block(libBlkPath.connPort,portPath,"Position",NameValueArgs.PortLocation);
    if NameValueArgs.PortSide == "left"
        set_param(portPath,"Orientation","right");
        set_param(portPath,"Side","left");
    else
        set_param(portPath,"Orientation","left");
        set_param(portPath,"Side","right");
    end
end
