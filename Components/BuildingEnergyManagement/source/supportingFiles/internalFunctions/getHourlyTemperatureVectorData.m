function [hourlyTimeData,hourlyTempVar] = getHourlyTemperatureVectorData(startYearVal,startMonthVal,startDayVal,numDaysDataVal,startHrVal,lat,long,longStdTimeZoneMeredian,dayLightSavingHrs,TDavg,TDvar,TNavg,TNvar)
% Get hourly temperature profile from user data.

% Copyright 2025 The MathWorks, Inc.

    dateTimeVec = datetime(startYearVal,startMonthVal,startDayVal:(startDayVal+numDaysDataVal),startHrVal,0,0);
    nDayVec = day(dateTimeVec);
    nDays = length(nDayVec);
    sunR = zeros(1,nDays);
    sunS = zeros(1,nDays);
    for i = 1:nDays
        [nYear,nDay,~] = getDataFromDatetimeSeries(dateTimeVec(1,i));
        [sunR(1,i), sunS(1,i)] = calcSunriseAndSunsetTime(nYear,nDay,lat,long,longStdTimeZoneMeredian,dayLightSavingHrs);
    end
    [hourlyTimeData,hourlyTempVar] = get24HrTemperatureProfile(TDavg,TDvar,TNavg,TNvar,sunR,sunS);
end