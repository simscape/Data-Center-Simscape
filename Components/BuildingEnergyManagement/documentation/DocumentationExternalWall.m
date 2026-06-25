%% External Wall
% 
% This block is used to specify an external wall and is a combination of the
% |Wall Selector| block and the |Solar Radiation on Surface| block. One 
% node, Thermal node _A_ of the block, is connected to the ambient and the 
% other node, Thermal node _B_, to the room. The input port _S_ is 
% used to specify the solar radiation falling on the wall. You can set the 
% |Wall Type| to one of the following: |Solid Wall with Solar Load|, 
% |Solid Wall with Window/Door and Solar Load|, |Solid Wall with 
% Window/Door, Vent, and Solar Load|, and |Solid Wall with Vent and 
% Solar Load|. 

% Copyright 2025 The MathWorks, Inc.

%% Wall
% * *Select wall type*, |optWall|, specified as a drop-down list option for
% the wall type. The options available are (1) |Solid Wall|, (2) |Solid 
% Wall with Opening|, (3) |Solid Wall with Solar Load|, (4) |Solid Wall 
% with Window/Door and Solar Load|, (5) |Solid Wall with Window/Door, Vent, 
% and Solar Load|, and (6) |Solid Wall with Vent and Solar Load|. Option
% (1) and (2) are used for internal walls, solid and walls with openings.
% They can also be used to specify external walls or surfaces where no
% solar radiation falls. Options (3)-(6) are different wall types with
% solar radiation falling on them. The solar radiation is specified using
% the input port _S_.
% * *Wall length*, |wallLength|, specified as a scalar value.
% * *Wall height*, |wallHeight|, specified as a scalar value.
% * *Wall thickness*, |wallThickness|, specified as a scalar value.
% * *Wall material density*, |wallMaterialDen|, specified as a scalar value.
% * *Wall material heat capacity*, |wallMaterialCp|, specified as a scalar value.
% * *Wall absorptivity*, |wallAbsorptivity|, specified as a scalar value.
% * *Wall thermal conductivity*, |wallThermalK|, specified as a scalar value.
%
%% Window
% * *Window length*, |winLength|, specified as a scalar value.
% * *Window height*, |winHeight|, specified as a scalar value.
% * *Window glass thickness*, |winThickness|, specified as a scalar value.
% * *Window glass material density*, |winMaterialDen|, specified as a scalar value.
% * *Window glass material heat capacity*, |winMaterialCp|, specified as a scalar value.
% * *Window glass absorptivity*, |winAbsorptivity|, specified as a scalar value.
% * *Window glass transmissivity*, |winTransmissivity|, specified as a scalar value.
% * *Window glass thermal conductivity*, |winThermalK|, specified as a scalar value.
%
%% Vent
% * *Vent length*, |ventLength|, specified as a scalar value.
% * *Vent height*, |ventHeight|, specified as a scalar value.
%
%% Heat Transfer
% * *Effective heat transfer coefficient from ambient to wall surface*, 
% |extToWallHTC|, specified as a scalar value.
% * *Effective heat transfer coefficient from internal surface to the room*, 
% |intToRoomHTC|, specified as a scalar value.
% * *Initial temperature*, |iniT|, specified as a scalar value.
%
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