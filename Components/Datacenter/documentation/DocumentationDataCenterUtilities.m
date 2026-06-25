%[text] %[text:anchor:T_D6EF7CFB] # Data Center Utilities
%[text] 
%[text] Copyright 2025 - 2026 The MathWorks, Inc.
%[text:tableOfContents]{"heading":"**Table of Contents**"}
%[text] %[text:anchor:H_00164D39] The functions listed below are used in the workflows described in this project. In this document, you will learn how to use these functions and specify their name-value-pairs.
%[text] ## Utilities for Automated Build
%[text] %[text:anchor:M_1eeb] ### getDataCenterNamePlateRatingTable
%[text] This function is used to modify parameters for server required by the data center build utilities like [buildDatacenter](internal:M_37f3) and [createDatacenterWithEnclosure](internal:M_0f9a). The function outputs a struct with two tables, one of size (6,2) and the other of size (5,1). The tables contain parameters for data center server like Server Idle Power, Power Supply Efficiency, Server Actual To Name Plate Ratio, Server Mass & Specific Heat, Peak Power of CPU, Memory, Disk, PCI, Motherboard, and Fans.
%[text] **Example**:
%[text] ```matlabCodeExample
%[text] data = getDataCenterNamePlateRatingTable(...
%[text]     Mass=simscape.Value(30,"kg"),...
%[text]     PeakPowerMotherboard=simscape.Value(34,"W"),...
%[text]     IdlePower=simscape.Value(56,"W"),...)
%[text]     Display=true);
%[text] ```
%[text:table]{"columnWidths":[663],"ignoreHeader":true}
%[text] |  |
%[text] | --- |
%[text:table]
%[text] %[text:anchor:M_0f9a] ### createDataCenterWithEnclosure
%[text] This function executes [`buildDatacenter`](internal:M_37f3) and [`buildEnclosureForDatacenter`](internal:M_2833). The name value pair for this function is a combined list of name value pair for these two functions. This utility also lets you save the model files generated at your specified location (name-value-pair of `SaveAtFullPath`) and also specify the type of file you want to save it as (name-value-pair of `SaveModelAs`).
%[text] **Example**:
%[text] ```matlabCodeExample
%[text] data = getDataCenterNamePlateRatingTable(...
%[text]     Mass=simscape.Value(30,"kg"),...
%[text]     PeakPowerMotherboard=simscape.Value(34,"W"),...
%[text]     IdlePower=simscape.Value(56,"W"),...)
%[text]     Display=true);
%[text] 
%[text] createDataCenterWithEnclosure(NumPDUunitsX=3,NumPDUunitsY=4,...
%[text]     ModelName="ModelDatacenterLiquidCooling",...
%[text]     ModelOption="Thermal",...
%[text]     ModelEnclosure=false,...
%[text]     RatingDatacenter=simscape.Value(6000,"kW"),...
%[text]     ServerNamePlateRating=data.nameplateRating,...
%[text]     ServerPowerSystemSpec=data.powerSystemSpecs,...
%[text]     ThermalRes=simscape.Value(1e-6,"K/W"),...
%[text]     Diagnostics=true);
%[text] ```
%[text] Additionally, you may find the block **Utilization Converter** custom library block useful in converting a 2D matrix of server utilization data (based on **NumPDUunitsX** and **NumPDUunitsY** values required by `createDatacenterWithEnclosure`) into a vector form required by the large data center created above.
%[text:table]{"columnWidths":[663],"ignoreHeader":true}
%[text] |  |
%[text] | --- |
%[text:table]
%[text] ### getCompositeDataCenterRating
%[text] The utilties in this project help create a large data center with multiple **Datacenter Server Unit** custom library block. Use this function to determine or confirm the rating of (composite) data center created using such utilities.
%[text] **Arguments**:
%[text] - `BlockPath`: Specified as a string and denotes the path to the composite data center model.
%[text] - `Display`: Specified as a logical value to enable or disable display of result. \
%[text] **Example**:
%[text] ```matlabCodeExample
%[text] % If in a SLX model DataCenterCooling, you have a subsystem called 'Datacenter', 
%[text] % that contains the 'Datacenter Server Unit' library blocks, then specify the 
%[text] % path as shown below.
%[text] getCompositeDataCenterRating(BlockPath="DataCenterCooling/Datacenter",...
%[text]                              Display=true);
%[text] ```
%[text:table]{"columnWidths":[663],"ignoreHeader":true}
%[text] |  |
%[text] | --- |
%[text:table]
%[text] ## Other Useful Utilities
%[text] %[text:anchor:M_37f3] ### buildDataCenter
%[text] This function is used to connect multiple data center servers in a certain topology. There a 3 different variants available, **thermal**, **electrical**, and **electrothermal**. 
%[text] **Parameters**:
%[text] - `NumPDUunitsX`: Number of power distribution units (PDU) of data center in X direction.
%[text] - `NumPDUunitsY`: Number of power distribution units (PDU) of data center in Y direction.
%[text] - `ModelName`: Name of Simscape model.
%[text] - `ModelOption`: Model fidelity; 3 different options available - **thermal**, **electrical**, and **electrothermal**. 
%[text] - `RatingDatacenter`: A simscape value to specify desired power rating of the data center.
%[text] - `ServerNamePlateRating`: A table of size (6,2) to specify server name plate rating parameters. Default values can be edited using function [`getDataCenterNamePlateRatingTable`](internal:M_1eeb).
%[text] - `ServerPowerSystemSpec`: A table of size (5,1) to specify data center parameters. Default values can be edited using function [`getDataCenterNamePlateRatingTable`](internal:M_1eeb).
%[text] - `PowerSupplyEff`: A scalar to specify the percentage efficiency of power supply. This is an optional argument required for **Electrical** and **Electrothermal** model fidelities.
%[text] - `ThermalRes`: A scalar to specify the thermal resistance of the data center stack bottom rack and the ground.
%[text] - `Diagnostics`: A logical, when set to *true*, outputs key updates from the function/utility. \
%[text] **Example**:
%[text] ```matlabCodeExample
%[text] data = getDataCenterNamePlateRatingTable(...
%[text]     Mass=simscape.Value(30,"kg"),...
%[text]     PeakPowerMotherboard=simscape.Value(34,"W"),...
%[text]     IdlePower=simscape.Value(56,"W"),...)
%[text]     Display=true);
%[text] 
%[text] datacenter = buildDataCenter(NumPDUunitsX=5,...
%[text]                              NumPDUunitsY=6,...
%[text]                              ModelName="MyModel",...
%[text]                              ModelOption="Electrothermal",...
%[text]                              RatingDatacenter=simscape.Value(50,"kW"),...
%[text]                              ServerNamePlateRating=data.nameplateRating,...
%[text]                              ServerPowerSystemSpec=data.powerSystemSpecs,...
%[text]                              ThermalRes=simscape.Value(5,"K/W"),...
%[text]                              Diagnostics=true);
%[text] ```
%[text:table]{"columnWidths":[663],"ignoreHeader":true}
%[text] |  |
%[text] | --- |
%[text:table]
%[text] %[text:anchor:M_2833] ### buildEnclosureForDataCenter
%[text] This function helps build a rectangular enclosure or room around the data center.
%[text] **Arguments**:
%[text] - `ModelName`: Specified as a string and denotes the name for the Simscape model.
%[text] - `EnclosureName`: Specified as a string and denotes the name for the room/enclosure subsystem.
%[text] - `DatacenterModel`: A struct specifying data center properties.
%[text] - `Diagnostics`: When set to *true*, outputs key updates from the build process.
%[text] - `RoomLength`, `RoomWidth`, `RoomHeight`: Simscape values for room/enclosure length, width, and height.
%[text] - `WallThickness`: Simscape value to specify the wall thickness for the room/enclosure.
%[text] - `RoomRotate`: Simscape value for the value of which the room is to be rotated.
%[text] - `PercentAirVolInRoom`: Percent volume of room that is empty or has stagnant air. \
%[text] **Example**:
%[text] ```matlabCodeExample
%[text] roomModel = buildEnclosureForDataCenter(ModelName=NameValueArgs.ModelName,...
%[text]                                             DatacenterModel=datacenter,...
%[text]                                             EnclosureName=NameValueArgs.EnclosureName,...
%[text]                                             PercentAirVolInRoom=8,...
%[text]                                             RoomLength=simscape.Value(4,"m"),...
%[text]                                             RoomWidth=simscape.Value(3.5,"m"),...
%[text]                                             RoomHeight=simscape.Value(2.5,"m"),...
%[text]                                             WallThickness=simscape.Value(1e-1,"m"),...
%[text]                                             RoomRotate=simscape.Value(15,"deg"),...
%[text]                                             Diagnostics=false);
%[text] ```
%[text:table]{"columnWidths":[663],"ignoreHeader":true}
%[text] |  |
%[text] | --- |
%[text:table]
%[text] ## 
%[text] 
%[text] %[text:anchor:TMP_1480] 
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":21.6}
%---
