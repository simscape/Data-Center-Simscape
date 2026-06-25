%% Custom Dynamic Load (3-phase) Block
% This block is used in conjunction with the Dynamic Load (3-phase) 
% library block in Simscape Electrical. It adds the impact of harmonic 
% distortion ad the input P and Q values for the Dynamic Load (3-phase) 
% block. The computation of the values is based on the approach cited in 
% "IEEE Standard Definitions for the Measurement of Electric 
% Power Quantities Under Sinusoidal, Nonsinusoidal, Balanced, or 
% Unbalanced Conditions," in IEEE Std 1459-2010 (Revision of IEEE Std 
% 1459-2000) , vol., no., pp.1-50, 19 March 2010.

% Copyright 2025 - 2026 The MathWorks, Inc.

%% Parameters
% * *Fundamental power factor*, |Pf|, specified as a scalar value.
% * *Total harmonic distortion value*, |THD|, specified as a scalar value.
% * *Number of datacenter units*, |N|, specified as a scalar value. This
% must be equal to the total number of *Datacenter Server Unit* custom
% library blocks it is connected to.
%
% The input _Pvec_ is a vector of _P_ port values from the *Datacenter 
% Server Unit* blocks. The output ports _P_ and _Q_ specify the revised
% input to the Dynamic Load (3-phase) Simscape Electrical block, based on
% the *THD* parameter specified.
