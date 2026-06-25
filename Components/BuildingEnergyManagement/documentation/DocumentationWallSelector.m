%% Wall Selector
% 
% This block is used to specify a solid wall, or a solid wall with vent 
% and/or windows. The wall and the window glass properties are also set 
% using this block. This block can also be used to build composite 
% walls. One node, Thermal node _A_, is connected to the ambient and the 
% other node, Thermal node _B_, to the room. The optional port _S_ is 
% used to specify the solar radiation falling on the wall. This port is 
% only visible for |Wall Type| values |Solid Wall with Solar Load|, 
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
