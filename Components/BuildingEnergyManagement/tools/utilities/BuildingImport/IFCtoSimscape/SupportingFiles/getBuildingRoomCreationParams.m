function room = getBuildingRoomCreationParams(NameValueArgs)
% Function to create input data for Simscape Rectangular rooms.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.X (1,4) {mustBeNonempty}
        NameValueArgs.Y (1,4) {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.RoomNum (1,2) {mustBeNonnegative}
        NameValueArgs.PhysUnitLen string {mustBeNonempty}
    end

    if NameValueArgs.RoomNum(1,1) == 0
        room.name = strcat("room",num2str(NameValueArgs.RoomNum(1,2)));
    else
        charName = char(NameValueArgs.RoomNum(1,1)+'a'-1);
        room.name = strcat("room",num2str(NameValueArgs.RoomNum(1,2)),charName);
    end

    Xo = NameValueArgs.X;
    Yo = NameValueArgs.Y;
    idm = zeros(1,2);
    Xm = Xo(Xo<mean(Xo(1,:)));
    res = find(Xo==Xm(1,1));
    if length(res) > 1
        idm(1,:) = res(1,:);
    else
        idm(1,1) = res(1,1);
        idm(1,2) = find(Xo==Xm(1,2),1);
    end
   
    Ym = Yo(idm);
    [~,idy] = min(Ym);
    id = idm(1,idy);
    
    if id == 4
        idn = 1;
        idp = 3;
    else
        idn = id+1;
        if id == 1
            idp = 4;
        else
            idp = id-1;
        end
    end
    delXn = Xo(1,idn)-Xo(1,id);
    delXp = Xo(1,idp)-Xo(1,id);
    
    if delXp <= 0 && delXn >= 0
        id1 = idn;
        id2 = idp;
    elseif delXp <= 0 && delXn <= 0
        if delXp > delXn
            id1 = idp;
            id2 = idn;
        else
            id1 = idn;
            id2 = idp;
        end
    elseif delXp >= 0 && delXn <= 0
        id1 = idp;
        id2 = idn;
    else % delXp >= 0 && delXn >= 0
        if delXp > delXn
            id1 = idp;
            id2 = idn;
        else
            id1 = idn;
            id2 = idp;
        end
    end
    
    room.vertex = simscape.Value([Xo(1,id),Yo(1,id)],NameValueArgs.PhysUnitLen);
    room.rotateByDeg = simscape.Value(round(rad2deg(atan((Yo(1,id)-Yo(1,id1))/(Xo(1,id)-Xo(1,id1)))),2),"deg");
    room.wid = simscape.Value(sqrt((Yo(1,id)-Yo(1,id1))^2+(Xo(1,id)-Xo(1,id1))^2),NameValueArgs.PhysUnitLen);
    room.len = simscape.Value(sqrt((Yo(1,id)-Yo(1,id2))^2+(Xo(1,id)-Xo(1,id2))^2),NameValueArgs.PhysUnitLen);

    if NameValueArgs.Debug
        floorPlanStruct = [];
        addRoomToFloorPlan(Vertex=room.vertex,Length=room.len,...
            Width=room.wid,Angle=room.rotateByDeg,FloorPlan=floorPlanStruct,...
            NewRoom="Room",Plot=true);
        figure("Name","Room points")
        plot(Xo,Yo,"bo");hold on;
        plot(Xo(1,id),Yo(1,id),"*r"); hold off;
        title("Room Vertices and Chosen Vertex (*)");
    end
end