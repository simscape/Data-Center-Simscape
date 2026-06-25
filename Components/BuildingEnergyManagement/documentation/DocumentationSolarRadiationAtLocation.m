%% Solar Radiation (LUT)
% 
% This block provides value of solar radiation, through output port _Rad_, at the 
% specified location. The solar radiation computation is based on the solar 
% angles computed from the location and datetime parameters. The solar 
% radiation is computed using the formula:
%
%   solar_rad = Gsc*(1+0.033*cos(day)*(cos(lat)*cos(delta)*cos(omega)+sin(lat)*sin(delta))
%
% where: *delta* denotes the _Declination Angle_, *lat* denotes the _Latitude 
% of the location_, *omega* denotes the _Solar hour angle_, *day* denotes the 
% _Day of the year representation_, and *Gsc* is equal to 1367 W/m^2.

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
% * *Number of hours of solar data*, |numHrsData|, defines the number of 
% hours for which solar radiation values are computed, specified as a scalar 
% value.
% * *Cloud cover data option*, |cloudData|, specifed as a drop-down list
% for the cloud cover option. You may choose from |none|, |hourly|, or
% |daily| options. If you select |none|, effect of cloud cover is not
% modeled. 
% * *Cloud cover value*, |cloudCoverVal|, specified as a vector of values
% between 0 and 1. If you select *Cloud cover data option* as |daily| or 
% |hourly|, this parameter will appear and you will need to specify a
% vector of values equal to the number of days or the number of hours in
% the simulation. The vector values range between 0 to 1. A value of 0
% indicates no cloud cover and all solar radiation is reaching the
% location. A value of 1 indicates a cloudy sky and no solar radiation
% reaches the location.