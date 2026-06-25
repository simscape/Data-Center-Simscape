% Function to get the other rooms numbers from a list of connections that a
% given room has boundaries with.

% Copyright 2024 The MathWorks, Inc.

function roomNumList = getConnectedRoomNumber(nameOfConnections)
    numOfNames = size(nameOfConnections,1);
    roomNumList = zeros(1,numOfNames);
    for i = 1:numOfNames
        roomNumStr = erase(nameOfConnections{i,1},"room");
        roomNumList(1,i) = str2num(roomNumStr);
    end
end