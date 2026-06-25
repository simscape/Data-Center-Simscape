function solarRadCosineVec = getSolarRadiationCosineOnSurf(startYear,startMonth,startDay,startHr,numHrsData,latitude,longitude,localTime,dayLightS,surfAngle,surfUnitV)
% Function to get cosine of solar radiation on a flat surface.

% Copyright 2025 The MathWorks, Inc.

% disp([startYear,startMonth,startDay,startHr,numHrsData,latitude,longitude,localTime,dayLightS,surfAngle]);
% disp(surfUnitV);

    geoLocation = getLocationDataTable(latitude,longitude,localTime);

    solarRadCosineVec = ones(1,numHrsData);

    totalTimeSeries = datetime(startYear,startMonth,startDay,startHr:(startHr+numHrsData),0,0);

    for i = 1:numHrsData
        [nYear,nDay,nHour] = getDataFromDatetimeSeries(totalTimeSeries(1,i));
        solarRadCosineVec(1,i) = getAngleSunRaysOnSurface(surfAngle,surfUnitV,nYear,nDay,nHour,geoLocation,dayLightS);
    end

    % disp(mat2str(size(solarRadCosineVec)));
end