%% CDU (LUT)

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImageCDULUT.png>>
% 
% Use this block to simulate CDU for liquid cooling applications, when you 
% have limited performance data for the CDU. It is well suited to be used 
% with *PDU Racks* composite component, as in the *PDU + CDU Assembly (LUT)* 
% block. Use ports _S_ and _N_ to change the speed and number of pumps used
% in the CDU. Output ports _Q_ and _P_ specify the heat removal capacity
% and electrical power requirments.

%% CDU
% * *Total number of pumps (-)*, |numPump|, specified as a scalar value.
% * *Coolant volumetric flowrate vector (m^3/s)*, |flowrate_vec|, specified as a vector value.
% * *Heat exchanger capacity vector (W)*, |capacity_vec|, specified as a vector value.
% * *Pump efficiency vector, 0-1 (-)*, |effPump_vec|, specified as a vector value.
% * *Pressure drop (Pa)*, |prDrop_mat|, specified as a matrix.
% * *Pump speed scaling (-)*, |speed|, specified as a scalar value.

