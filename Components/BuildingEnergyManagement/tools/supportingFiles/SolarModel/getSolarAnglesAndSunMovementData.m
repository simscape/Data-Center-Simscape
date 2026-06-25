% Function to get solar data for the Ambient custom block.

% Copyright 2024 The MathWorks, Inc.

function solarDataTimeSeries = getSolarAnglesAndSunMovementData(dateTimeVec,geoLocation,dayLightSavingHrs)
    dataLen = length(dateTimeVec);
    sunriseTime = zeros(dataLen,1);
    sunsetTime = zeros(dataLen,1);
    solarHrAngleDeg = zeros(dataLen,1);
    solarDeclinationAngleDeg = zeros(dataLen,1);
    solarAltitudeAngleDeg = zeros(dataLen,1);
    solarAzimuthAngleDeg = zeros(dataLen,1);
    count = 0;
    for tm = dateTimeVec
        count = count + 1;
        nHrs = hour(tm);
        nDay = day(tm,'dayofyear'); 
        nYr  = year(tm);
        solarData = getSolarRadiationAngle(nYr,nDay,nHrs,geoLocation,dayLightSavingHrs); 
        sunriseTime(count,1) = solarData.sunrise;
        sunsetTime(count,1) = solarData.sunset;
        solarHrAngleDeg(count,1) = solarData.solarHrAngle;
        solarDeclinationAngleDeg(count,1) = solarData.declinationAngleOnThatDay;
        solarAltitudeAngleDeg(count,1) = solarData.solarAltitudeDeg;
        solarAzimuthAngleDeg(count,1) = solarData.surfaceAzimuthAngle;
    end
    solarDataTimeSeries = timetable(dateTimeVec',sunriseTime,sunsetTime,...
        solarHrAngleDeg,solarDeclinationAngleDeg,solarAltitudeAngleDeg,solarAzimuthAngleDeg);
end