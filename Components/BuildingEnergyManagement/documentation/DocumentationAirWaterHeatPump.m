%% Air Water Heat Pump
% 
% This block is used for abstract representation of an air-water heat pump.
% The parameters on the block are based on EN14511 test data. The block
% outputs the amount of heating or cooling provided under the specified
% operating conditions. The operating conditions are determined from the
% values entered through the input ports of the block.

% Copyright 2025 The MathWorks, Inc.

%%
% The ports for this block include:
%
% * Input port *Fw* specifies the flow rate of liquid from the heat pump.
% * Input port *Op* specifies the operation mode of the heat pump. Set 
% this input to -1 for heating applications and to +1 for cooling 
% applications. You can choose to add no heat to the water by setting this 
% port value to 0.
% * Input port *Ep* specifies if an additional electric heater has to be 
% used to add heat to water. Set the value of this input to 1 when you want 
% to add more heat, using inbuilt electrical heater in the heat pump, or 0 
% when you do not wish to add any additional heat. The value of the *Ep* 
% port is multiplied by the value of the *Additional electric heater 
% rating* parameter to compute the additional heat to be added to water.
% * Input port *Ta* specifies the inlet air dry bulb temperature.
% * Output port *ePow* and *COP* to to output the actual electrical power 
% consumed in the heat pump and the real COP value realized during the heat 
% pump operation.
% * Input port *Tl* specifies the water inlet temperature.
% * Input port *Tw* specifies the water outlet temperature.
% * Input port *Nd* specified as a sclar value to represent operation 
% deviation from the normal.
%
%% Heating and Cooling Data (EN14511)
% You must specify parameters for Air Water Heat Pump based on EN14511 test
% protocol. The convention used for parameter names is:
%
% * *A* for air, followed by its dry bulb temperature in degree centigrade.
% * *W* for water, followed by its outlet temperature in degree centigrade.
%
% For example: A-2W55 is the test case where inlet air dry bulb temperature
% is -2 degree centigrade and the outlet water temperature is 55 degree
% centigrade.
%
% For all test conditions, you must specify heat pump capacity and the 
% estimated COP or SCOP, the seasonal COP values.
%
% * *A-2W55, estimated heating capacity*, |nominalCapacityA|, specified as 
% a scalar value.
% * *A-2W55, COP (or SCOP)*, |seasonalCOPvalA|, specified as a scalar value.
% * *A-2W65, estimated heating capacity*, |nominalCapacityB|, specified as 
% a scalar value.
% * *A-2W65, COP (or SCOP)*, |seasonalCOPvalB|, specified as a scalar value.
% * *A7W35, estimated heating capacity*, |nominalCapacityC|, specified as 
% a scalar value.
% * *A7W35, COP (or SCOP)*, |seasonalCOPvalC|, specified as a scalar value.
% * *A7W45, estimated heating capacity*, |nominalCapacityD|, specified as 
% a scalar value.
% * *A7W45, COP (or SCOP)*, |seasonalCOPvalD|, specified as a scalar value.
% * *A35W18, estimated cooling capacity*, |nominalCapacityE|, specified as 
% a scalar value.
% * *A35W18 COP (or SCOP)*, |seasonalCOPvalE|, specified as a scalar value.
% * *A35W7, estimated cooling capacity*, |nominalCapacityF|, specified as 
% a scalar value.
% * *A35W7 COP (or SCOP)*, |seasonalCOPvalF|, specified as a scalar value.
%
%% Heat Pump
% * *Minimum operational water temperature*, |wInletOpRangeUpp|, specified as 
% a scalar value.
% * *Maximum operational water temperature*, |wInletOpRangeLow|, specified as 
% a scalar value.
% * *Backup electric heater rating*, |backupElecHeater|, specified as a
% scalar value.
