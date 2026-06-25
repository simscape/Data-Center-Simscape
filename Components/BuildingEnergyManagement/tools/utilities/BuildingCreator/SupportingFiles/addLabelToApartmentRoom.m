function addLabelToApartmentRoom(NameValueArgs)
% Add label to rooms
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel struct {mustBeNonempty}
        NameValueArgs.FloorLevel (1,1) {mustBeGreaterThan(NameValueArgs.FloorLevel,0)}
        NameValueArgs.RoomPathData struct {mustBeNonempty}
        NameValueArgs.RoomPortName string {mustBeMember(NameValueArgs.RoomPortName,["Top","Bottom","TL_A","TL_B"])}
        NameValueArgs.LabelSize (1,1) {mustBeGreaterThan(NameValueArgs.LabelSize,5)} = 10
        NameValueArgs.RelativePos string {mustBeMember(NameValueArgs.RelativePos,["quad1","quad2","quad3","quad4"])} = "quad1"
        NameValueArgs.Orientation string {mustBeMember(NameValueArgs.Orientation,["left","right","up","down","auto"])} = "auto"
    end

    setLibraryPathReferences;
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(NameValueArgs.BuildingModel);
    count = 0;
    adjPos = 0.4;
    for i = 1:nApt
        fLvl = NameValueArgs.BuildingModel.("apartment"+i).("room1").geometry.dim.floorLevel;
        if  fLvl == NameValueArgs.FloorLevel
            for j = 1:nRooms(i,1)
                count = count+1;
                labelName = strcat(NameValueArgs.RoomPathData.blkNameFloorLevel(NameValueArgs.FloorLevel,1),"/",NameValueArgs.RoomPortName,num2str(count),"Lib");
                blkLocation = str2num(NameValueArgs.RoomPathData.blkNameBldgLoc(i,j));
                delX = blkLocation(1,3)-blkLocation(1,1);
                delY = blkLocation(1,4)-blkLocation(1,2);
                if NameValueArgs.RoomPortName == "Top"
                    if NameValueArgs.Orientation == "auto"
                        labelOrient = "right";
                    else
                        labelOrient = NameValueArgs.Orientation;
                    end
                    lblLocation = [(1+adjPos)*delX -adjPos*delY (1+adjPos)*delX+NameValueArgs.LabelSize -adjPos*delY+NameValueArgs.LabelSize];
                elseif NameValueArgs.RoomPortName == "Bottom"
                    if NameValueArgs.Orientation == "auto"
                        labelOrient = "right";
                    else
                        labelOrient = NameValueArgs.Orientation;
                    end
                    lblLocation = [(1+adjPos)*delX (1+adjPos)*delY (1+adjPos)*delX+NameValueArgs.LabelSize (1+adjPos)*delY+NameValueArgs.LabelSize];
                elseif NameValueArgs.RoomPortName == "TL_A"
                    if NameValueArgs.Orientation == "auto"
                        labelOrient = "left";
                    else
                        labelOrient = NameValueArgs.Orientation;
                    end
                    lblLocation = [-(1-adjPos)*delX (1-adjPos)*delY -(1-adjPos)*delX+NameValueArgs.LabelSize (1-adjPos)*delY+NameValueArgs.LabelSize];
                elseif NameValueArgs.RoomPortName == "TL_B"
                    if NameValueArgs.Orientation == "auto"
                        labelOrient = "right";
                    else
                        labelOrient = NameValueArgs.Orientation;
                    end
                    lblLocation = [(1+adjPos)*delX (1-adjPos)*delY (1+adjPos)*delX+NameValueArgs.LabelSize (1-adjPos)*delY+NameValueArgs.LabelSize];
                else

                end
                add_block(libBlkPath.labelConn,labelName,"Position",[blkLocation(1,1) blkLocation(1,2) blkLocation(1,1) blkLocation(1,2)]+lblLocation);
                set_param(labelName,"Label",strcat(NameValueArgs.RoomPortName,num2str(count)));
                set_param(labelName,"Orientation",labelOrient);
                set_param(labelName,"ShowName","off");
                simscape.addConnection(NameValueArgs.RoomPathData.blkNameBldg(i,j),NameValueArgs.RoomPortName,labelName,"port");
            end
        end
    end
end