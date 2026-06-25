%% Data Center Server Unit
% The component has an input port _U_, output port _T_, _P_, and a thermal
% node *H*. The port _U_ is used to specify the utilization of the CPUs.
% This input ranges between 0-1. Output ports _T_ and _P_ specify the
% temperature and the power loss of the unit.

% Copyright 2025 - 2026 The MathWorks, Inc.

%% Server Name-Plate Rating
% * *Peak power of CPU*, |peakPowCPU|, specified as a scalar value.
% * *Number of CPU*, |numOfCPU|, specified as a scalar value.
% * *Peak power of Memory*, |peakPowMemory|, specified as a scalar value.
% * *Number of Memory*, |numOfMemory|, specified as a scalar value.
% * *Peak power of Disk*, |peakPowDisk|, specified as a scalar value.
% * *Number of Disk*, |numOfDisk|, specified as a scalar value.
% * *Peak power of PCI slots*, |peakPowPCIslot|, specified as a scalar value.
% * *Number of PCI slots*, |numOfPCIslot|, specified as a scalar value.
% * *Peak power of Motherboard*, |peakPowMotherboard|, specified as a scalar value.
% * *Number of Motherboard*, |numOfMotherboard|, specified as a scalar value.
% * *Peak power of Fans*, |peakPowFan|, specified as a scalar value.
% * *Number of Fans*, |numOfFan|, specified as a scalar value.


%% Electrical Power Systems
% * *Measured idle power for one server*, |idlePower|, specified as a scalar 
% value.
% * *Power supply efficiency, in percentage*, |powerSupplyEff|, specified 
% as a scalar value between 0-100.
% * *Ratio of server actual to name-plate peak power*, 
% |ratioActualToNameplate|, specified as a scalar value between 0-1.
% * *Mass of each server*, |serverMass|, specified as a scalar value.
% * *Specific heat capacity of the server*, |serverSpHeat|, specified as a 
% scalar value.
% * *Total units in server stack*, |numCPUperServer|, specified as a scalar 
% value.
% * *Heat generation model*, |physQ|, specified as a drop-down option. You
% can choose bwteen two models - *Linear* and *Non-linear*.
% * *Calibration parameter for non-linear heat generation model*, 
% |calibParam|, specified as a scalar value. This option is visible when
% the *Calibration parameter for non-linear heat generation model* is set
% to *Non-linear*.
%
%% Reference
% * Xiaobo Fan, Wolf-Dietrich Weber, and Luiz André Barroso, "Power  
% Provisioning for a Warehouse-sized Computer", Published in Proceedings of  
% the ACM International Symposium on Computer Architecture, San Diego, CA, 
% June 2007.