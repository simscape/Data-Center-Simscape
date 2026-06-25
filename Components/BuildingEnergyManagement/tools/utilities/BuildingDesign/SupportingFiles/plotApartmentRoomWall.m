% Internal function to plot a room wall.

% Copyright 2024 The MathWorks, Inc.

function plotApartmentRoomWall(wallPoints,wallColor)
    patch(wallPoints(1,:),wallPoints(2,:),wallPoints(3,:),wallColor);
end