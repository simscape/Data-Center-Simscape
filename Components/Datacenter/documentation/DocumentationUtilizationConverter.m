%% Data Center Utilization Data Conversion Block
% This block is used to convert data center utilization values specified in 
% a matrix form to a vector form, as required by the custom data center 
% created using the utility |createDataCenterWithEnclosure|. 

% Copyright 2026 The MathWorks, Inc.

%% Overview
% The utility |createDataCenterWithEnclosure| requires input arguments 
% *NumPDUunitsX* and *NumPDUunitsY* that specify the server rack layout in
% X and Y direction. The individual server utilization is specified through
% the port _Util_ that accepts a vector of values equal to the total number
% of server racks in the system. You may specify this input as a matrix of
% size [ *NumPDUunitsX* , *NumPDUunitsY* ] and link it to this block input
% port. The output port of the block can then be linked to the _Util_ port
% of the (composite) data center.
% 
%% Parameters
% * *Number of server units in X*, |X|, specified as a scalar value.
% * *Number of server units in Y*, |Y|, specified as a scalar value.
%
