function solarAltDeg = solarAltitude(geoLatDeg,solarDeclinationDeg,hourAngle)
% Function to find solar altitude angle.

% Copyright 2024 - 2025 The MathWorks, Inc.

    solarAltDeg = max(0,rad2deg(asin(...
                       sin(deg2rad(geoLatDeg))*sin(deg2rad(solarDeclinationDeg)) + ...
                       cos(deg2rad(geoLatDeg))*cos(deg2rad(solarDeclinationDeg))*cos(deg2rad(hourAngle))...
                       )));
end