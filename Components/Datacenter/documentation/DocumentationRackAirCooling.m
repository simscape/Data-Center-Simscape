%% Rack Air Cooling

% Copyright 2026 The MathWorks, Inc.

%%
% 
% <<docImageRackAirCooling.png>>
% 
% This block is used to model air cooling in data center racks. The port
% _S_ specifies the fan speed and the thermal nodes *C* and *H* specify the
% thermal nodes on the cold and hot sides, respectively. The node *H* must
% be connected to thermal node of PDU to model air cooling. The output port
% _P_ specifies the power consumption in the air cooling unit.

%% Fans
% * *Number of fans (-)*, |nFans|, specified as a scalar value.
% * *Fan flow rate vector (m^3/s)*, |flowVec|, specified as a scalar value.
% * *Pressure drop vector (Pa)*, |prDropVec|, specified as a scalar value.
% * *Fan efficiency vector (-)*, |fanEffVec|, specified as a scalar value.

