%% Temperature Source (LUT)
% 
% This block provides temperature variation at a location using the 
% average day & night temperature values. You must specify the average 
% day temperature vector and the night temperature vector. The vector 
% size is equal to the number of days for which you specify temperature 
% data. The block uses this information, along with additional information 
% on percentage variation in average day and night temperatures, location 
% of interest, and the start date-time values. The location and the start 
% date-time value is used to calculate the sunrise and sunset time. The 
% average temperature data values for each day are used to reconstruct 
% an approximate hourly temperature profile for the day. Multiple such 
% profiles, for all the days specified, are joined together to form the 
% time varying temperature profile lookup table. The block provides value 
% of temperature, at the thermal node _H_, for a given date and time.

% Copyright 2025 The MathWorks, Inc.

%% Location
% * *Latitude of the location*, |latitude|, specified as a positive or
% negative value. If the value is set to be positive, then the value
% corrosponds to the Northern Hemisphere. If the value is set to be
% negative, then it corrosponds to the Southern Hemisphere.
% * *Longitude of the location*, |longitude|, specified as a positive or
% negative value. If the value is set to be positive, then the value
% corrosponds to the Eastern Hemisphere. If the value is set to be
% negative, then it corrosponds to the Western Hemisphere.
% * *Longitude reference for local time calculations*, |localTime|, 
% specified as a positive or negative value. If the value is set to be 
% positive, then the value corrosponds to the Eastern Hemisphere. If the 
% value is set to be negative, then it corrosponds to the Western Hemisphere.
% * *Daylight hour savings*, |dayLightS|, specified as a scalar value.
%
%% Start Date and Time
% * *Year for start time*, |startYear|, defines the start year for time 
% calculation, specified as a scalar value. 
% * *Month for start time*, |startMonth|, defines the start month for time 
% calculation, specified as a scalar value.
% * *Day for start time*, |startDay|, defines the start day for time 
% calculation, specified as a scalar value.
% * *Hour for start time*, |startHr|, defines the start time in hour for time 
% calculation, specified as a scalar value.
% * *Number of days*, |numDaysData|, defines the number of datas for which
% temperature values are provided, specified as a scalar value.
%
%% Daily Average Temperature
% * *Average day temperature vector*, |avgDayTvec|, specified as a vector
% of average daily temperature values. The length of the vector must be
% equal to the *Number of days* parameter set in *Start Date and Time*.
% * *Percent variation in day temperature*, |pcDayTvar|, specified as a
% scalar value equal to the percentage variation in the day time
% temperatures.
% * *Average night temperature vector*, |avgNightTvec|, specified as a vector
% of average night temperature values. The length of the vector must be
% equal to the *Number of days* parameter set in *Start Date and Time*.
% * *Percent variation in night temperature*, |pcNightTvar|, specified as a
% scalar value equal to the percentage variation in the night time
% temperatures.
