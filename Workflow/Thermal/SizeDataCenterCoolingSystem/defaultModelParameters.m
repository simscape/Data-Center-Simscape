% Copyright 2026 The MathWorks, Inc.

defaultGeographicalCoordinates;

modelData.ControlParam.Tset.PDU  = simscape.Value(300,"K");
modelData.ControlParam.Tset.ROOM = simscape.Value(283,"K");
modelData.ControlParam.Room.Length = simscape.Value(100,"m");
modelData.ControlParam.Room.Width  = simscape.Value(40,"m");
modelData.ControlParam.Room.Height = simscape.Value(5,"m");
modelData.ControlParam.Room.OrientationAngle = simscape.Value(30,"deg");
modelData.ControlParam.Room.Thickness.Wall = simscape.Value(0.1,"m");
modelData.ControlParam.Room.Thickness.Glass = simscape.Value(5e-3,"m");
modelData.ControlParam.Room.Thickness.Floor = simscape.Value(0.11,"m");
modelData.ControlParam.Room.Thickness.Roof = simscape.Value(0.08,"m");
modelData.ControlParam.Room.Transmissivity.Glass = 0.45;
modelData.ControlParam.Room.Wall1FracWindow = 0.75;
modelData.ControlParam.Room.Wall2FracWindow = 0.01;
modelData.ControlParam.Room.Wall3FracWindow = 0.75;
modelData.ControlParam.Room.Wall4FracWindow = 0.01;
modelData.ControlParam.Room.RoomVolFracAsset = 0.8;
modelData.ControlParam.Chiller.COP = 4;
modelData.ControlParam.PercentEff.HVAC = 78;
modelData.ControlParam.PercentEff.PUMP = 80;
modelData.ControlParam.CoolingTower.Trange = simscape.Value(8,"K");
modelData.ControlParam.CoolingTower.TowerFanPowerRatio = 0.02;
