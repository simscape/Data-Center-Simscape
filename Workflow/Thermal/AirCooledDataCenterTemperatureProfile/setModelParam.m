%[text] # Set Model Parameters
%[text] 
%[text] Copyright 2026 The MathWorks, Inc.
%[text] 
airCooledDataCenter.Room.Length = simscape.Value(100,"m");
airCooledDataCenter.Room.Width  = simscape.Value(40,"m");
airCooledDataCenter.Room.Height = simscape.Value(5,"m");
airCooledDataCenter.Room.RoomAssetVolPercent = 80;
airCooledDataCenter.Room.Tset_K = simscape.Value(291,"K");
airCooledDataCenter.HeatTransfer.HTC = simscape.Value(50,"W/(K*m^2)");
airCooledDataCenter.HeatTransfer.InitialT = simscape.Value(293,"K");
airCooledDataCenter.HeatTransfer.AmbientT = simscape.Value(300,"K");
airCooledDataCenter.Room.HVAC.EffHeatExchanger = 80;
airCooledDataCenter.Fan.UpperT = simscape.Value(320,"K");
airCooledDataCenter.Fan.LowerT = simscape.Value(300,"K");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
