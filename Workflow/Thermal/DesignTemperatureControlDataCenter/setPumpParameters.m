%[text] # Set Pump Parameters
%[text] 
%[text] Copyright 2026 The MathWorks, Inc.
%[text] 
modelParam.Model.DataCenterLib = "PDU + CDU Assembly (TL)";
modelParam.Model.Path = modelParam.Model.Name+"/"+modelParam.Model.DataCenterLib;
modelParam.Pump.FractionHead = 0.9;
modelParam.Pump.WaterDensity = 998;

modelParam.Pump.Flow_kg_per_s = round(mean(str2num(get_param(modelParam.Model.Path,"extFluidMdot"))),2);

% CDU Pump
modelParam.Pump.NominalCapacity = ceil((modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*str2double(get_param(modelParam.Model.Path,"nAssembly")));
set_param(modelParam.Model.Name+"/CDU Pump","capacity_ref_nominal",strcat(num2str(modelParam.Pump.NominalCapacity),"% ",string(datetime("now"))))

modelParam.Pump.MaxHeadZeroCapacity = str2double(get_param(modelParam.Model.Name+"/CDU Pump","head_ref_max"));
modelParam.Pump.NominalHead = str2double(get_param(modelParam.Model.Name+"/CDU Pump","head_ref_nominal"));

modelParam.Pump.MaxCapacityZeroHead = ceil(modelParam.Pump.FractionHead*modelParam.Pump.MaxHeadZeroCapacity*modelParam.Pump.NominalCapacity/(modelParam.Pump.MaxHeadZeroCapacity-modelParam.Pump.NominalHead));
set_param(modelParam.Model.Name+"/CDU Pump","capacity_ref_max",strcat(num2str(modelParam.Pump.MaxCapacityZeroHead),"% ",string(datetime("now"))));

% Tower Pump
modelParam.Pump.NominalCapacity = ceil((modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*str2double(get_param(modelParam.Model.Path,"nAssembly")));
set_param(modelParam.Model.Name+"/Tower Pump","capacity_ref_nominal",strcat(num2str(modelParam.Pump.NominalCapacity),"% ",string(datetime("now"))))

modelParam.Pump.MaxHeadZeroCapacity = str2double(get_param(modelParam.Model.Name+"/Tower Pump","head_ref_max"));
modelParam.Pump.NominalHead = str2double(get_param(modelParam.Model.Name+"/Tower Pump","head_ref_nominal"));

modelParam.Pump.MaxCapacityZeroHead = ceil(modelParam.Pump.FractionHead*modelParam.Pump.MaxHeadZeroCapacity*modelParam.Pump.NominalCapacity/(modelParam.Pump.MaxHeadZeroCapacity-modelParam.Pump.NominalHead));
set_param(modelParam.Model.Name+"/Tower Pump","capacity_ref_max",strcat(num2str(modelParam.Pump.MaxCapacityZeroHead),"% ",string(datetime("now"))));

% Cooling Tower
modelParam.CoolingTower.Capacity = (modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*str2double(get_param(modelParam.Model.Path,"nAssembly"));

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":44}
%---
