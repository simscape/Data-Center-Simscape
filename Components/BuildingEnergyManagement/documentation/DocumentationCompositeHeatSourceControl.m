%% Heat Source Control
% 
% This documentation describes a control to supply cooling or heating fluid 
% energy to a building block. The block has port _S_ which specifies the
% heat provided to, or extracted from, each room inside the building.

% Copyright 2025 The MathWorks, Inc.

%%
% The block compares the measured room temperature _Tr_ with the set point
% temperature _Ts_ and provides heating or cooling value required per room 
% in the building, through port _S_. _Tr_ is a vector of length equal to
% the number of rooms in the building. _S_ is of same size as the vector at
% input _Tr_. The set point temperature could be specified as same for all
% rooms using a scalar value or as a vector to specify different set point
% in each room. In such a scenario, the size of _Ts_ vector must be equal
% to the number of rooms in the building. Additionally, ports _heating_ and
% _cooling_ specify the heating and cooling requirements for the building.
%
% * *Heat pump capacity*, |capacity|, specified as a scalar value.
% * *Number of source*, |number|, specified as a scalar value.
% * *Change in water temperature*, |delT|, specified as a scalar value.
% This value specifies the difference between heat pump inlet and outlet
% water streams.
% * *Measurement time constant*, |tau|, specified as a scalar value.
% * *Initial water temperature*, |iniT|, specified as a scalar value.
