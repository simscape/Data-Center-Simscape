function [listOfDays,simStartTime,sunrise,sunset] = getSunriseSunsetData(NameValueArgs)
% Function to model ambient temperature variation.

% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DateTimeVector datetime {mustBeNonempty}
        NameValueArgs.Location table {mustBeNonempty}
        NameValueArgs.DayLightSavingHrs (1,1) {mustBeNonempty,mustBeNonnegative} = 0
    end
    
    solarDataTimeSeries = getSolarAnglesAndSunMovementData(NameValueArgs.DateTimeVector,...
                                                           NameValueArgs.Location,...
                                                           NameValueArgs.DayLightSavingHrs);
    % listOfDays = unique(day(solarDataTimeSeries.Time));
    % listOfDays = unique(day(solarDataTimeSeries.Time,'dayofyear'));
    numOfDays = days(NameValueArgs.DateTimeVector(1,end)-NameValueArgs.DateTimeVector(1,1));
    listOfDays = ones(numOfDays,1);
    listOfDays(1,1) = day(NameValueArgs.DateTimeVector(1,1),"dayofyear");
    for i = 2:numOfDays
        valDayNum = mod(listOfDays(i-1,1)+1,366);
        if valDayNum == 0, valDayNum = 366; end
        listOfDays(i,1) = valDayNum;
    end

    % disp(listOfDays)

    simStartTime  = hour(solarDataTimeSeries.Time(1,1))*3600 + ...
                    minute(solarDataTimeSeries.Time(1,1))*60 + ...
                    second(solarDataTimeSeries.Time(1,1));
    % Find sunrise and sunset time
    % numOfDays = length(listOfDays);
    if numOfDays == 1
        listOfDays = [listOfDays;listOfDays];
        numOfDays = length(listOfDays);
    end
    sunrise = zeros(1,numOfDays);
    sunset = zeros(1,numOfDays);

    % day1 = listOfDays(1,1);
    yrStart = year(NameValueArgs.DateTimeVector(1,1));
    for i = 1:numOfDays
        % rowNum = find(day(solarDataTimeSeries.Time,'dayofyear')==listOfDays(i,1),1);
        % rowNum = find(and(day(NameValueArgs.DateTimeVector,'dayofyear')==listOfDays(i,1),year(NameValueArgs.DateTimeVector)==yrStart),1)
        rowNum = (i-1)*24+1;
        sunrise(1,i) = solarDataTimeSeries.sunriseTime(rowNum,1)*3600;
        sunset(1,i) = solarDataTimeSeries.sunsetTime(rowNum,1)*3600;
        if i == 366, yrStart = yrStart+1; end
    end
end