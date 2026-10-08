%[text] # Estimate Power Usage Effectiveness for Different Design Parameters
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] This example uses the data center developed in the [Size Data Center Cooling System](file:./SizeDataCenterCoolingSystemExample.m) example. It shows how to evaluate the best operating point for HVAC operations, ensuring that the temperature inside the data center room stays within a specified comfort limit while maintaining a reasonable power usage effectiveness (PUE) for the system.
%[text] ## Setup System Model
%[text] Open the example. 
modelData.SLXModelName = "SizeDataCenterCoolingSystem";
open_system(modelData.SLXModelName);
%[text] Specify geographical location.
modelData.LocationName = "London";
modelData.Location     = getGeoLocationForMajorCities(CityName=modelData.LocationName);
%[text] Specify the start date and time for the chosen location when HVAC requirements for room heating or cooling are expected to be high. Specify a time range of one or more weeks for the analysis.
modelData = setSimulationDateTime(ModelInfo=modelData,... %[output:group:7d4e236c] %[output:3dc7558a]
                                  StartTime=datetime(2025,6,15,1,0,0),... %[output:3dc7558a]
                                  NumOfWeeks=1); %[output:group:7d4e236c] %[output:3dc7558a]
%[text] Specify the daily average day-time and night-time temperatures.
avgAmbientT  = 298;
nDays = ceil(length(modelData.DateTimeVec)/24);
dailyTprofile.AvgDayT = simscape.Value(ones(1,nDays)*avgAmbientT,"K");
dailyTprofile.AvgDayTvar = 2; % 2K, this must be scalar and not sismcape.Value()
dailyTprofile.AvgNightT = simscape.Value(ones(1,nDays)*(avgAmbientT-10),"K"); 
dailyTprofile.AvgNightTvar = 2; % 2K, this must be scalar and not sismcape.Value()
clear avgAmbientT nDays
%[text] ## Specify Design Options
%[text] For the chosen control parameters, or design options, create a table that specifies the different design case combinations. This workflow considers a full factorial of all cases for the specified design parameters.
listOfDesignOpt = setDesignParameterVariation(RoomSetPointTemperature_K=[288 292 294],... %[output:group:6a2d7b4a] %[output:08081513]
                                              RoomOperationHVAC=[0,1],... %[output:08081513]
                                              CoolingTowerTemperatureRange_K=7,... %[output:08081513]
                                              ChillerCOP=5,... %[output:08081513]
                                              PumpEfficiencyPercentHVAC=83,... %[output:08081513]
                                              PumpEfficiencyPercentCoolTwr=85,... %[output:08081513]
                                              CoolingTowerFanPowerRatio=0.02); %[output:group:6a2d7b4a] %[output:08081513]
%[text] ## Run Simulation
%[text] Run all cases as specified in the table `listOfDesignOpt`.
nCase = size(listOfDesignOpt,1); simResData = cell(1,nCase);
for i = 1:nCase %[output:group:402e1610]
    modelData = setModelParameters(modelData,dailyTprofile,listOfDesignOpt(i,:));
    sim(modelData.SLXModelName);
    simResData{1,i} = getWeeklyAvgData(logsout_SizeDataCenterCoolingSystem,modelData);
    disp(strcat("Completed ",num2str(i),"/",num2str(nCase)," case(s).")); %[output:578bf5a3]
end %[output:group:402e1610]
close_system(modelData.SLXModelName,1);
clear i nCase modelData logsout_SizeDataCenterCoolingSystem
%%
%[text] ## Analyze Results
%[text] Find the design option that yields the lowest PUE for the system while maintaining the room temperature within the prescribed limit.
[designChoice,designPUE] = findBestSolution(... %[output:group:38429c46] %[output:26649e05]
                                 ListOfDesignOptions=listOfDesignOpt,... %[output:26649e05]
                                 SimulationResults=simResData,... %[output:26649e05]
                                 MaxRoomTempPermissible=simscape.Value(294,"K"),... %[output:26649e05]
                                 MinRoomTempPermissible=simscape.Value(280,"K")); %[output:group:38429c46] %[output:26649e05]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":34.2}
%---
%[output:3dc7558a]
%   data: {"dataType":"text","outputData":{"text":"Start Date 15-Jun-2025 01:00:00 till End Date 23-Jun-2025 01:00:00\n","truncated":false}}
%---
%[output:08081513]
%   data: {"dataType":"text","outputData":{"text":"Total number of design scenarios ~ 6\n  \n    <strong>Room Tset<\/strong>    <strong>Room HVAC<\/strong>    <strong>Wall Window Fraction<\/strong>    <strong>Room Orientation Angle<\/strong>    <strong>Glass Transmissivity<\/strong>    <strong>Room Wall Thickness<\/strong>    <strong>Room Roof Thickness<\/strong>    <strong>Room Floor Thickness<\/strong>    <strong>Room Window Glass Thickness<\/strong>    <strong>PDU Tset<\/strong>    <strong>Cooling Tower T-range<\/strong>    <strong>Cooling Tower Fan Power Ratio<\/strong>    <strong>Chiller COP<\/strong>    <strong>HVAC Pump Efficiency<\/strong>    <strong>Cooling Tower Pump Efficiency<\/strong>\n    <strong>_________<\/strong>    <strong>_________<\/strong>    <strong>____________________<\/strong>    <strong>______________________<\/strong>    <strong>____________________<\/strong>    <strong>___________________<\/strong>    <strong>___________________<\/strong>    <strong>____________________<\/strong>    <strong>___________________________<\/strong>    <strong>________<\/strong>    <strong>_____________________<\/strong>    <strong>_____________________________<\/strong>    <strong>___________<\/strong>    <strong>____________________<\/strong>    <strong>_____________________________<\/strong>\n\n       288           0                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n       292           0                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n       294           0                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n       288           1                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n       292           1                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n       294           1                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n\n","truncated":false}}
%---
%[output:578bf5a3]
%   data: {"dataType":"text","outputData":{"text":"Completed 1\/6 case(s).\nCompleted 2\/6 case(s).\nCompleted 3\/6 case(s).\nCompleted 4\/6 case(s).\nCompleted 5\/6 case(s).\nCompleted 6\/6 case(s).\n","truncated":false}}
%---
%[output:26649e05]
%   data: {"dataType":"text","outputData":{"text":"PUE number ~1.49\n \n    <strong>Room Tset<\/strong>    <strong>Room HVAC<\/strong>    <strong>Wall Window Fraction<\/strong>    <strong>Room Orientation Angle<\/strong>    <strong>Glass Transmissivity<\/strong>    <strong>Room Wall Thickness<\/strong>    <strong>Room Roof Thickness<\/strong>    <strong>Room Floor Thickness<\/strong>    <strong>Room Window Glass Thickness<\/strong>    <strong>PDU Tset<\/strong>    <strong>Cooling Tower T-range<\/strong>    <strong>Cooling Tower Fan Power Ratio<\/strong>    <strong>Chiller COP<\/strong>    <strong>HVAC Pump Efficiency<\/strong>    <strong>Cooling Tower Pump Efficiency<\/strong>\n    <strong>_________<\/strong>    <strong>_________<\/strong>    <strong>____________________<\/strong>    <strong>______________________<\/strong>    <strong>____________________<\/strong>    <strong>___________________<\/strong>    <strong>___________________<\/strong>    <strong>____________________<\/strong>    <strong>___________________________<\/strong>    <strong>________<\/strong>    <strong>_____________________<\/strong>    <strong>_____________________________<\/strong>    <strong>___________<\/strong>    <strong>____________________<\/strong>    <strong>_____________________________<\/strong>\n\n       292           1                0.8                       0                       0.45                    0.1                   0.08                    0.12                       0.005                 300                 7                          0.02                      5                  83                          85              \n\n","truncated":false}}
%---
