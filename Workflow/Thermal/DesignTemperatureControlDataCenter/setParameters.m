%[text] # Set Parameters
%[text] 
%[text] Copyright 2026 The MathWorks, Inc.
%[text] 
modelParam.Model.Name = "DesignTemperatureControlForDataCenter";
setPumpParameters;

modelParam.WetBulbT = simscape.Value(300,"K");
modelParam.RoomT = simscape.Value(291,"K");
modelParam.relHumidity = 0.6;
modelParam.WaterSupplyTempCDU = simscape.Value(7,"degC");

modelParam.NoPumpWindowT = 10;
modelParam.StepControlTempr = 2;

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
