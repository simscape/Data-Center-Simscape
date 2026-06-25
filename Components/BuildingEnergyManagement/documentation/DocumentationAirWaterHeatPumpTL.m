%% Air Water Heat Pump (TL)
% 
% This block is used for representation of an air-water heat pump using 
% *Thermal Liquid* domain and the custom library block |Air Water Heat Pump| .
% The parameters on the block are based on EN14511 test data. The operating 
% conditions are determined from the values entered through the input ports 
% of the block.

% Copyright 2025 The MathWorks, Inc.

%%
% The block has ports:
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
% * Simscape Thermal Liquid ports *A* and *B* to connect to the *Building* 
% custom component or to the *Operational Data* custom component.
% * Output port *ePow* and *COP* to to output the actual electrical power 
% consumed in the heat pump and the real COP value realized during the heat 
% pump operation.
% 
% |Air Water Heat Pump| is a custom component that evaluates the heat pump 
% capacity based on EN14511 test data. This block, |Air Water Heat Pump (TL)|, 
% then estimates the capacity of the pump based on inlet air temperature 
% and outlet water temperature values and calculates the heat added or 
% removed from the fluid. The Simscape Foundation |Pipe| block adds heat to 
% the liquid. The pipe is parameterized based on datasheet values for heat 
% pump coil lengths and internal storage volumes.
%
% The list of parameters needed to define the heat pump block are:
% 
%% EN14511 (Heating) Data
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
% 
%% EN14511 (Cooling) Data
% * *A7W45, COP (or SCOP)*, |seasonalCOPvalD|, specified as a scalar value.
% * *A35W18, estimated cooling capacity*, |nominalCapacityE|, specified as 
% a scalar value.
% * *A35W18 COP (or SCOP)*, |seasonalCOPvalE|, specified as a scalar value.
% * *A35W7, estimated cooling capacity*, |nominalCapacityF|, specified as 
% a scalar value.
% * *A35W7 COP (or SCOP)*, |seasonalCOPvalF|, specified as a scalar value.
%
%% Heat Pump Construction
% * *Additional electric heater rating*, |elecHeaterPower|, specified as a
% scalar value.
% * *Length of coil pipe*, |coilLen|, specified as a scalar value.
% * *Area of coil pipe*, |coilArea|, specified as a scalar value.
% * *Diameter of coil pipe*, |coilDia|, specified as a scalar value.
% * *Heat exchanger internal volume*, |tankVolume|, specified as a scalar 
% value.
% 
%% Flow and Thermal Specifications
% * *Initial temperature*, |initialT|, specified as a scalar value.
% * *Initial pressure of water in the coils*, |initialP|, specified as a 
% scalar value.
% * *Nominal water flowrate during test*, |nomFlowDuringTest|, specified as 
% a scalar value.
% * *Minimum water flowrate*, |minWaterFlowRate|, specified as a scalar 
% value.
% * *Temperature sensor delay for water flow (s)*, |measTimelagWater|, 
% specified as a scalar value.
% * *Minimum operational water temperature*, |waterOpTempMin|, specified as 
% a scalar value.
% * *Maximum operational water temperature*, |waterOpTempMax|, specified as 
% a scalar value.
