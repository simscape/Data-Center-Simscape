% Set default model parameters

% Copyright 2026 The MathWorks, Inc.

modelParam.Model.Name = "DesignTemperatureControlForDataCenter";
modelParam.WetBulbT = simscape.Value(300,"K");
modelParam.RoomT = simscape.Value(291,"K");
modelParam.relHumidity = 0.6;
modelParam.WaterSupplyTempCDU = simscape.Value(7,"degC");
modelParam.NoPumpWindowT = 10;
modelParam.StepControlTempr = 2;
modelParam.Model.DataCenterLib = "PDU + CDU Assembly (TL)";
modelParam.Model.Path = modelParam.Model.Name+"/"+modelParam.Model.DataCenterLib;
modelParam.Pump.FractionHead = 0.9;
modelParam.Pump.WaterDensity = 998;
modelParam.Pump.Flow_kg_per_s = 1;
% CDU Pump
modelParam.Pump.NominalCapacity = ceil((modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*3);
modelParam.Pump.MaxHeadZeroCapacity = 33;
modelParam.Pump.NominalHead = 28;
modelParam.Pump.MaxCapacityZeroHead = ceil(modelParam.Pump.FractionHead*modelParam.Pump.MaxHeadZeroCapacity*modelParam.Pump.NominalCapacity/(modelParam.Pump.MaxHeadZeroCapacity-modelParam.Pump.NominalHead));
% Tower Pump
modelParam.Pump.NominalCapacity = ceil((modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*3);
modelParam.Pump.MaxHeadZeroCapacity = 33;
modelParam.Pump.NominalHead = 28;
modelParam.Pump.MaxCapacityZeroHead = ceil(modelParam.Pump.FractionHead*modelParam.Pump.MaxHeadZeroCapacity*modelParam.Pump.NominalCapacity/(modelParam.Pump.MaxHeadZeroCapacity-modelParam.Pump.NominalHead));
% Cooling Tower
modelParam.CoolingTower.Capacity = (modelParam.Pump.Flow_kg_per_s/modelParam.Pump.WaterDensity)*60000*3;
