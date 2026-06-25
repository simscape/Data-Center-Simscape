% Function to get solar radiation data.

% Copyright 2024 The MathWorks, Inc.

function solarRadiationDataTbl = getSolarRadiationData(year,dayVal,currTime,geoLocation,dayLightSavingHrs)
    arguments
        year (1,1) {mustBeGreaterThan(year,0),mustBeInteger}
        dayVal (1,:) {mustBeNumeric,mustBeInteger,mustBeGreaterThan(dayVal,0)}
        currTime (1,:) {mustBeNumeric,mustBeInRange(currTime,0,24)}
        geoLocation (1,3) table {mustBeNonempty}
        dayLightSavingHrs (1,1) {mustBeNumeric,mustBeNonnegative}
    end

    nDays = length(dayVal);
    nHrs  = length(currTime);
    % nDay, nHrs denote number of day and time data points for which solar
    % radiation angle data is needed. This function is a wrapper to the
    % function getSolarRadiationAngle(). The output will be a matrix if
    % either of nDay or nHrs is greater than one. The output will be a
    % scalar quantity if data is sought for only a particular day and at a
    % particular time.
    % 
    % nHrs must be between 0 and 24.
    % nDays must be non-negative and integer quantities. It can be greater
    % than 365 too.
    sunRayDirection = cell(nDays,nHrs);
    rowLbl = cell(1,nDays); colLbl = cell(1,nHrs);
    if nDays > 1 || nHrs > 1
        for day = 1:nDays
            rowLbl{1,day} = num2str(dayVal(1,day));
            for hr = 1:nHrs
                colLbl{1,hr} = strcat(num2str(currTime(1,hr)),':00 hrs');
                solarData = getSolarRadiationAngle(year,dayVal(1,day),...
                    currTime(1,hr),geoLocation,dayLightSavingHrs);
                sunRayDirection{day,hr} = struct2table(solarData);
            end
        end
    else
        rowLbl{1,1} = num2str(dayVal); colLbl{1,1} = num2str(currTime);
        solarData = getSolarRadiationAngle(year,dayVal,currTime,geoLocation,...
            dayLightSavingHrs);
        sunRayDirection{1,1} = struct2table(solarData);
    end
    solarRadiationDataTbl = cell2table(sunRayDirection,...
        'VariableNames',colLbl,'RowNames',rowLbl);
end
