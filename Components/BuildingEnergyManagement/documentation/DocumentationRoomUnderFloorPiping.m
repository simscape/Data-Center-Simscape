%% Room Under-floor Piping
% 
% This block is used to specify underfloor heating or cooling inside a 
% room. The block has two Thermal-Liquid (TL) nodes, _A_ and _B_, to model 
% the fluid. The Thermal node _R_ connects to the room thermal mass. 
% The input port _V_ is used to control the flow into the radiator. When 
% set to 0, the whole cooling fluid passes through the radiator pipes.
% When it is set to 1, the whole cooling liquid passes through a by-pass
% circuit and the radiator is non-functional.

% Copyright 2025 The MathWorks, Inc.

%% Piping
% * *Pipe length*, |pipeLength|, specified as a scalar value.
% * *Pipe hydraulic diameter*, |pipeHydrDia|, specified as a scalar value.
% * *Pipe cross-sectional area*, |pipeArea|, specified as a scalar value.
% * *Pipe roughness*, |pipeRoughness|, specified as a scalar value.
%
%% Heat Transfer
% * *Heat transfer coefficient*, |htc|, specified as a scalar value.
% * *Initial temperature*, |iniTemperature|, specified as a scalar value.


