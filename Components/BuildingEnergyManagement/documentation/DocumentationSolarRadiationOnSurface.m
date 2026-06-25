%% Solar Radiation on Surface
% 
% This block provides value of cosine of solar radiation at the a given 
% surface orientation. The input port _Rad_ takes in solar radiation values
% and outputs the solar radiation incident on the flat surface at the 
% parameterized location and surface orientation values, through output 
% port _S_. This block, when combined with the *Wall Selector* block, 
% provides wall with an orientation and incident solar radiation values.

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
%% Surface Orientation
% * *Surface angle wrt ground*, |surfAngle|, specified as a scalar value
% between 0 and 90. The parameter specifies the value of the angles, in
% degrees, at which the flat surface is inclined from the horizontal. A
% value of 90 is used for vertical walls, a value of 0 for a flat
% horizontal surface, and any intermediate value for an inclined surface.
% * *Unit outward normal direction vector*, |surfUnitV|, specified as an 
% unit vector of two elements.The first element denotes the direction from
% east-west perspective, positive being eastwards and negative being
% westwards. The second element denotes the direction from north-south
% perspective, positive being northwards and negative being southwards. For
% example, a value of [0 -1] denotes south facing while [-1 0] denotes a
% westward facing surface.
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