function [nYear,nDay,nHour] = getDataFromDatetimeSeries(datetimeVal)
% Function to get Datetime values.

% Copyright 2025 The MathWorks, Inc.

    nYear = year(datetimeVal);
    nDay = day(datetimeVal,"dayofyear");
    nHour = hour(datetimeVal);
end