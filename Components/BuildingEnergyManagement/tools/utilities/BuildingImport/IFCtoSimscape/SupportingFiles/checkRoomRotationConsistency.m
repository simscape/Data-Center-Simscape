function updatedRoom = checkRoomRotationConsistency(NameValueArgs)
% Function to check room rotation values.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Room (:,1) cell {mustBeNonempty}
    end
    
    updatedRoom = NameValueArgs.Room;
    listOfRotAngles = zeros(size(NameValueArgs.Room,1),1);
    for i = 1:size(NameValueArgs.Room,1)
        listOfRotAngles = value(NameValueArgs.Room{i,1}.rotateByDeg,"deg");
    end
    for i = 1:size(NameValueArgs.Room,1)
        updatedRoom{i,1}.rotateByDeg = simscape.Value(mode(listOfRotAngles),"deg");
    end
end