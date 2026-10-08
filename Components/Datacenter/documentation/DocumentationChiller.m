%% Chiller

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImageChiller.png>>
% 
% Use this block to simulate a chiller component. This block is an
% abstract representation of the chiller and has Thermal Liquid ports *Ae* 
% and *Be* for the evaporator side, and *Ac* and *Bc* for the condenser side. 
% The input port _S_ controls the chiller operation. A value of 0 indicates 
% no chiller operation while a value of 1 represents full capacity operation. 
% Output port _P_ provides the electrical energy consumption in the chiller.

%% Rating
% * *Nominal rating (kW)*, |nominalRating|, specified as a scalar value.
% * *Nominal flowrate (kg/s)*, |nominalFlowrate|, specified as a scalar value.
% * *Nominal pressure drop (MPa)*, |nominalPrDrop|, specified as a scalar value.
% * *Coefficient of performance (-)*, |cop|, specified as a scalar value.
% * *Chiller volume (m^3)*, |volume|, specified as a scalar value.
% * *Cross-sectional port area (m^2)*, |portArea|, specified as a scalar value.

%% Initial Conditions
% * *Initial pressure (MPa)*, |initialP|, specified as a scalar value.
% * *Initial temperature (K)*, |initialT|, specified as a scalar value.

