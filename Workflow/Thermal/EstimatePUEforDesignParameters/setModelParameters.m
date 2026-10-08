% Copyright 2026 The MathWorks, Inc.

function modelData = setModelParameters(inputModelData,dailyTprofile,designOptions)
    modelData = inputModelData;

    modelData.AvgDayT = dailyTprofile.AvgDayT;
    modelData.AvgDayTvar = dailyTprofile.AvgDayTvar;
    modelData.AvgNightT = dailyTprofile.AvgNightT;
    modelData.AvgNightTvar = dailyTprofile.AvgNightTvar;

    modelData.ControlParam.Tset.PDU  = simscape.Value(designOptions.("PDU Tset"),"K");
    modelData.ControlParam.Tset.ROOM = simscape.Value(designOptions.("Room Tset"),"K");
    
    modelData.ControlParam.Room.RoomVolFracAsset = 0.8;
    modelData.ControlParam.Room.Length = simscape.Value(100,"m");
    modelData.ControlParam.Room.Width = simscape.Value(40,"m");
    modelData.ControlParam.Room.Height = simscape.Value(5,"m");
    modelData.ControlParam.Room.OrientationAngle = simscape.Value(designOptions.("Room Orientation Angle"),"deg");
    
    modelData.ControlParam.Room.Wall1FracWindow = designOptions.("Wall Window Fraction");
    modelData.ControlParam.Room.Wall2FracWindow = designOptions.("Wall Window Fraction");
    modelData.ControlParam.Room.Wall3FracWindow = designOptions.("Wall Window Fraction");
    modelData.ControlParam.Room.Wall4FracWindow = designOptions.("Wall Window Fraction");

    modelData.ControlParam.Room.Thickness.Wall = simscape.Value(designOptions.("Room Wall Thickness"),"m");
    modelData.ControlParam.Room.Thickness.Glass = simscape.Value(designOptions.("Room Window Glass Thickness"),"m");
    modelData.ControlParam.Room.Transmissivity.Glass = designOptions.("Glass Transmissivity");
    modelData.ControlParam.Room.Thickness.Floor = simscape.Value(designOptions.("Room Floor Thickness"),"m");
    modelData.ControlParam.Room.Thickness.Roof = simscape.Value(designOptions.("Room Roof Thickness"),"m");
    
    modelData.ControlParam.Chiller.COP = designOptions.("Chiller COP");
    modelData.ControlParam.PercentEff.HVAC = designOptions.("HVAC Pump Efficiency");
    modelData.ControlParam.PercentEff.PUMP = designOptions.("Cooling Tower Pump Efficiency");
    
    modelData.ControlParam.CoolingTower.Trange = simscape.Value(designOptions.("Cooling Tower T-range"),"K");
    modelData.ControlParam.CoolingTower.TowerFanPowerRatio = designOptions.("Cooling Tower Fan Power Ratio");
        
    modelData.Place.Latitude  = getGeographicalCoordinates(modelData.Location.Latitude);
    modelData.Place.Longitude = getGeographicalCoordinates(modelData.Location.Longitude);
    modelData.Place.Meredian  = getGeographicalCoordinates(modelData.Location.("Meredian (Time Zone)"));
    
    modelData.ControlParam.HVACswitch = designOptions.("Room HVAC"); % 1 is ON, 0 is OFF

    if ~bdIsLoaded(modelData.SLXModelName)
        open_system(modelData.SLXModelName);
    end
    
    set_param(modelData.SLXModelName, 'StopTime', strcat(num2str((length(hour(modelData.DateTimeVec))-1)*3600),"% hours ~ ",num2str(length(hour(modelData.DateTimeVec))-1)));
    
    setDesignParameters(modelData.SLXModelName,modelData.ControlParam,string(datetime("now")));
end