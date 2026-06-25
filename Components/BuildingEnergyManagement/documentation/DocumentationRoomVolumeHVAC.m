%% Room Volume (HVAC)
% 
% This block is used to specify a room air volumeusing the Moist Air domain, 
% Constant Volume Chamber library block. The nodes A and B represent the
% moist air inlet and outlet. You can add heat to the air volume through 
% the input port _S_. The node _M_ is the Thermal node and the output port 
% _T_ provides temperature of the air mass. You can specify the number of
% occupants in the room using port _N_.

% Copyright 2025 The MathWorks, Inc.

%% HVAC
% * *Room length*, |length|, specified as a scalar value. It specifies the
% air mass block length.
% * *Room width*, |width|, specified as a scalar value. It specifies the
% air mass block width.
% * *Room height*, |height|, specified as a scalar value. It specifies the
% air mass block height.
% * *Area inlet for HVAC*, |airInletCrossSection|, specified as a scalar
% value. It specifies the inlet area into the room for the moist air
% volume.
% * *Area outlet for HVAC*, |airOutletCrossSection|, specified as a scalar
% value. It specifies the outlet area for the moist air volume, from the
% room.
%
%% Air Quality
% * *Breath temperature*, |breathT|, specified as a scalar value.
% * *CO2 per person*, |perPersonCO2|, specified as a scalar value.
% * *Moisture per person*, |perPersonMoisture|, specified as a scalar value.
% * *Heat load per person*, |perPersonQ|, specified as a scalar value.
% * *Relative humidity at saturation*, |relHumidity|, specified as a scalar value.
% * *Condensation time constant*, |tauCondensation|, specified as a scalar value.
%
%% Initial Conditions
% * *Initial trace gas mole fraction of moist air volume*, 
% |traceGasMoleFrac|, specified as a scalar value.
% * *Initial trace gas mass fraction of moist air volume*, 
% |traceGasMassFrac|, specified as a scalar value.
% * *Initial pressure of moist air volume*, |pressureAirVol|, specified as 
% a scalar value.
% * *Initial temperature of most air volume*, |temperatureAirVol|, 
% specified as a scalar value.
% * *Initial relative humidity of moist air volume*, |relHumidityAirVol|, 
% specified as a scalar value.
%