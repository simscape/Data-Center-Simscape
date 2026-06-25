function [hourlyTimeData,hourlyTempVar] = get24HrTemperatureProfile(TDavg,TDvar,TNavg,TNvar,SunR,SunS)
% Function to model temperature variations throughout the day.

% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        TDavg (1,:) {mustBeNonempty,mustBeNonnegative}
        TDvar (1,1) {mustBeNonempty,mustBeNonnegative}
        TNavg (1,:) {mustBeNonempty,mustBeNonnegative}
        TNvar (1,1) {mustBeNonempty,mustBeNonnegative}
        SunR  (1,:) {mustBeNonempty,mustBeNonnegative}
        SunS  (1,:) {mustBeNonempty,mustBeNonnegative}
    end

    curveFitOrder = 2;
    numOfDays = length(TDavg);
    polyfitCoeff = zeros(numOfDays,curveFitOrder+1);
    for i = 1:numOfDays
        TDmin = (1-TDvar)*TDavg(1,i);
        TDmax = (1+TDvar)*TDavg(1,i);
        TNmin = (1-TNvar)*TNavg(1,i);
        TNmax = (1+TNvar)*TNavg(1,i);
        % SUNSET and SUNRISE time are specified over ONE year only. Value
        % of 'i'can be greater than 366 depending upon number of days being
        % simulated. Hence, for these vectors, MOD(i,366) is required.
        R = SunR(1,i);
        S = SunS(1,i);
        % R = SunR(1,max(1,mod(i,366)));
        % S = SunS(1,max(1,mod(i,366)));
        P1 = R/2;
        P2 = (R+S)/2;
        P3 = (24*3600+S)/2;
        P4 = 24*3600;
        valTime = [P1,R,P2,S,P3,P4];
        valTemp = [(TNmin+TNavg(1,i))/2,TDmin,TDmax,TDavg(1,i),(TDavg(1,i)+TNmax)/2,TNavg(1,i)];
        polyfitCoeff(i,:) = polyfit(valTime,valTemp,curveFitOrder);
    end

    oneHour = 24;
    hourlyTempVar = zeros(1,numOfDays*oneHour);
    for i = 1:numOfDays*oneHour
        dayNum = max(1,min(numOfDays,(i-mod(i,oneHour))/oneHour+1));
        hourlyTempVar(1,i) = polyval(polyfitCoeff(dayNum,:),mod(i*3600,24*3600));
    end
    hourlyTempVar = smoothdata(hourlyTempVar);
    hourlyTimeData = (1:numOfDays*oneHour)*3600;
end