function connectLevelThroughFloors(NameValueArgs)
% Connect floors
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.ListOfLevels (:,1) string {mustBeNonempty}
        NameValueArgs.ListOfFloors (:,1) string {mustBeNonempty}
    end

    topFloorLevelNum = size(NameValueArgs.ListOfLevels,1);

    % Room level
    for i = 1:topFloorLevelNum
        hndl = get_param(NameValueArgs.ListOfLevels(i,1),"PortHandles");
        topPort = hndl.RConn(length(hndl.RConn)-1);
        bottomPort = hndl.RConn(length(hndl.RConn));
        placeSubsystemPort(topPort,"Top");
        placeSubsystemPort(bottomPort,"Bottom");
    end

    % Roof, floors
    for i = 1:topFloorLevelNum+1
        hndl = get_param(NameValueArgs.ListOfFloors(i,1),"PortHandles");
        topPort = hndl.RConn(length(hndl.RConn)-1);
        bottomPort = hndl.RConn(length(hndl.RConn));
        % if i == topFloorLevelNum+1
        %     placeSubsystemPort(topPort,"Left");
        % else
        %     placeSubsystemPort(topPort,"Top");
        % end
        placeSubsystemPort(topPort,"Top");
        placeSubsystemPort(bottomPort,"Bottom");
        if i < topFloorLevelNum+1
            simscape.addConnection(NameValueArgs.ListOfLevels(i,1),"Bottom",...
                                   NameValueArgs.ListOfFloors(i,1),"Top","autorouting","off");
        end
        if i > 1
            simscape.addConnection(NameValueArgs.ListOfLevels(i-1,1),"Top",...
                                   NameValueArgs.ListOfFloors(i,1),"Bottom","autorouting","off");
        end
        set_param(NameValueArgs.ListOfFloors(i,1),"ShowPortLabels","none");
    end
end