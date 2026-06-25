function clockTime = getLocalClockTime(long,longStdTimeZoneMeredian,year,nDayOfYear,watchTime,dayLightSavingHrs)
% Function to find local clock time.

% Copyright 2024 - 2025 The MathWorks, Inc.

    EOTminutes = getEquationOfTimeInMinutes(year,nDayOfYear);
    clockTime = watchTime - EOTminutes/60 + (long-longStdTimeZoneMeredian)/15 + dayLightSavingHrs;
end