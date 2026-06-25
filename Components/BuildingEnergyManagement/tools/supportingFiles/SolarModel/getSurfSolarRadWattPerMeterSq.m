% Function to find solar radiation on a plane surface inclined at a 
% particular angle.

% Copyright 2024 The MathWorks, Inc.

function solarRadWattPerMeterSq = getSurfSolarRadWattPerMeterSq(NameValueArgs)
    arguments
        NameValueArgs.SurfAngle {mustBeInRange(NameValueArgs.SurfAngle,0,90)}
        NameValueArgs.SurfUnitNormal (1,2) {mustBeNonempty, mustBeNonNan}
        NameValueArgs.Year (1,1) {mustBeInteger}
        NameValueArgs.DayOfTheYear (1,1) {mustBeInRange(NameValueArgs.DayOfTheYear,0,366)}
        NameValueArgs.HourOfTheDay (1,1) {mustBeInRange(NameValueArgs.HourOfTheDay,0,24)}
        NameValueArgs.Location (1,3) table {mustBeNonempty}
        NameValueArgs.DayLightSaving (1,1) {mustBeNonNan} = 0
    end
    cosineAngleOfIncidence = getAngleSunRaysOnSurface(NameValueArgs.SurfAngle,NameValueArgs.SurfUnitNormal,NameValueArgs.Year,NameValueArgs.DayOfTheYear,NameValueArgs.HourOfTheDay,NameValueArgs.Location,NameValueArgs.DayLightSaving);
    solarRadWattPerMeterSq = cosineAngleOfIncidence*getSunRadiationOnTheDay(NameValueArgs.Location,NameValueArgs.Year,NameValueArgs.DayOfTheYear,NameValueArgs.HourOfTheDay,NameValueArgs.DayLightSaving);
end