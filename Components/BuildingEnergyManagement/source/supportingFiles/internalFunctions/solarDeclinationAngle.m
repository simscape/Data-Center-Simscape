function declinationAngle = solarDeclinationAngle(daysOfTheYear)
% Function to find solar declination angle.

% Copyright 2024 - 2025 The MathWorks, Inc.

    declinationAngle = 23.45*sin(deg2rad((360/365)*(284+daysOfTheYear)));
end