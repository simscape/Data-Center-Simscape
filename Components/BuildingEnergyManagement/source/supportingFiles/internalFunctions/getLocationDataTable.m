function geoLocation = getLocationDataTable(latitude,longitude,localTime)
% Function to get location data in tabular form.

% Copyright 2025 The MathWorks, Inc.

    location ="MyCityName";
    if longitude > 0
        degLongitude = cellstr(num2str(abs(longitude))+"E");
    else
        degLongitude = cellstr(num2str(abs(longitude))+"W");
    end
    if latitude > 0
        degLatitude = cellstr(num2str(abs(latitude))+"N");
    else
        degLatitude = cellstr(num2str(abs(latitude))+"S");
    end
    if localTime > 0
        stdTimeZone = cellstr(num2str(abs(localTime))+"E");
    else
        stdTimeZone = cellstr(num2str(abs(localTime))+"W");
    end

    geoLocation = table(degLatitude,degLongitude,stdTimeZone,...
        'VariableNames',{'Latitude','Longitude','Meredian (Time Zone)'},...
        'RowNames',location);
end