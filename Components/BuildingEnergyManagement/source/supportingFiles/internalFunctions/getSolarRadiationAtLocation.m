function solarRadWattPerMeterSqVec = getSolarRadiationAtLocation(startYear,startMonth,startDay,startHr,numHrsData,latitude,longitude,localTime,dayLightS)
% Function to get solar radiation data at a location.

% Copyright 2025 The MathWorks, Inc.

    geoLocation = getLocationDataTable(latitude,longitude,localTime);

    solarRadWattPerMeterSqVec = ones(1,numHrsData);

    totalTimeSeries = datetime(startYear,startMonth,startDay,startHr:(startHr+numHrsData),0,0);

    for i = 1:numHrsData
        [nYear,nDay,nHour] = getDataFromDatetimeSeries(totalTimeSeries(1,i));
        solarRadWattPerMeterSqVec(1,i) = getSunRadiationOnTheDay(geoLocation,nYear,nDay,nHour,dayLightS);
    end
end