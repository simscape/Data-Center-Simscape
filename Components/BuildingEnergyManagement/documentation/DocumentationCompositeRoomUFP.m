%% Room with Under Floor Piping (UFP)
% 
% This documentation describes a simple room model, with internal air
% mass and a UFP for thermal comfort.

% Copyright 2025 The MathWorks, Inc.

%%
% The block has 4 thermal nodes labeled as *w1* , *w2* , *w3* , *w4* to represent
% connection on 4 sides of the room. These must be connected to wall
% blocks, either internal wall or external walls. The thermal nodes *top* and
% *bottom* represent connections to roof and floor elements. The port _S_
% is input port for specifying any heat source in the room. The output port
% _T_ provides the room temperature value. 
% The radiator water flow if tracked through the thermal liquid domain
% nodes, *TL_A* and *TL_B* . The port _V_ is the input port for specifying
% valve state for the radiator. 
%
%% Room Dimensions
% * *Room length*, |roomLen|, specified as a scalar value.
% * *Room width*, |roomWid|, specified as a scalar value.
% * *Room height*, |roomHgt|, specified as a scalar value.
%
%% Under Floor Piping
% * *Pipe length*, |pipeLenUFP|, specified as a scalar value.
% * *Pipe cross-sectional area*, |pipeCrossSectionalAreaUFP|, specified as a scalar value.
% * *Pipe hydraulic diameter*, |pipeHydrDiaUFP|, specified as a scalar value.
% * *Pipe roughness*, |pipeRoughnessUFP|, specified as a scalar value.
% 
%% Heat Transfer
% * *Heat transfer coefficient*, |htc|, specified as a scalar value.
% * *Initial temperature*, |iniT|, specified as a scalar value.
% * *Heat source vector index*, |indxS|, specified as a scalar value. This
% is the element location in the _S_ input on the building block mask. The
% index number specifies the serial order of data in the input array for
% the given room.
% * *Valve operation vector index*, |indxV|, specified as a scalar value. This
% is the element location in the _V_ input on the building block mask. The
% index number specifies the serial order of data in the input array for
% the given room.