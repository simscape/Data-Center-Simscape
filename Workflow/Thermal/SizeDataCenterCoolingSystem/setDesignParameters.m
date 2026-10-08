% Copyright 2026 The MathWorks, Inc.

function setDesignParameters(modelName,controlParam,msg)
    genericMsg = strcat(" % ",msg);

    set_param(modelName+"/on-off","Value",strcat(num2str(controlParam.HVACswitch),genericMsg));

    set_param(modelName+"/pduTset","Value",strcat(num2str(value(controlParam.Tset.PDU,"K")),genericMsg));
    set_param(modelName+"/roomTset","Value",strcat(num2str(value(controlParam.Tset.ROOM,"K")),genericMsg));
    set_param(modelName+"/Chiller","COP",strcat(num2str(controlParam.Chiller.COP),genericMsg));
    set_param(modelName+"/HVAC (Room)","effHeatExchanger",strcat(num2str(controlParam.PercentEff.HVAC),genericMsg));
    
    set_param(modelName+"/Cooling Tower","pumpEff",strcat(num2str(controlParam.PercentEff.PUMP),genericMsg));
    set_param(modelName+"/Cooling Tower","twrRangeDT",strcat(num2str(value(controlParam.CoolingTower.Trange,"K")),genericMsg));
    set_param(modelName+"/Cooling Tower","twrFanRatio",strcat(num2str(controlParam.CoolingTower.TowerFanPowerRatio),genericMsg));

    set_param(modelName+"/Data Center in Building/Data Center Room","roomLength",strcat(num2str(value(controlParam.Room.Length,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","roomWidth",strcat(num2str(value(controlParam.Room.Width,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","roomHeight",strcat(num2str(value(controlParam.Room.Height,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","fracDCvol",strcat(num2str(controlParam.Room.RoomVolFracAsset),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","rotateDeg",strcat(num2str(value(controlParam.Room.OrientationAngle,"deg")),genericMsg));
    
    set_param(modelName+"/Data Center in Building/Data Center Room","wallThickness",strcat(num2str(value(controlParam.Room.Thickness.Wall,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","roofThickness",strcat(num2str(value(controlParam.Room.Thickness.Roof,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","floorThickness",strcat(num2str(value(controlParam.Room.Thickness.Floor,"m")),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","glassThickness",strcat(num2str(value(controlParam.Room.Thickness.Glass,"m")),genericMsg));

    set_param(modelName+"/Data Center in Building/Data Center Room","glassTransmissivity",strcat(num2str(controlParam.Room.Transmissivity.Glass),genericMsg));

    set_param(modelName+"/Data Center in Building/Data Center Room","windowFracWall1",strcat(num2str(controlParam.Room.Wall1FracWindow),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","windowFracWall2",strcat(num2str(controlParam.Room.Wall2FracWindow),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","windowFracWall3",strcat(num2str(controlParam.Room.Wall3FracWindow),genericMsg));
    set_param(modelName+"/Data Center in Building/Data Center Room","windowFracWall4",strcat(num2str(controlParam.Room.Wall4FracWindow),genericMsg));
    
    set_param(modelName+"/HVAC (Room)","roomLen",strcat(num2str(value(controlParam.Room.Length,"m")),genericMsg));
    set_param(modelName+"/HVAC (Room)","roomWid",strcat(num2str(value(controlParam.Room.Width,"m")),genericMsg));
    set_param(modelName+"/HVAC (Room)","roomHt",strcat(num2str(value(controlParam.Room.Height,"m")),genericMsg));
    set_param(modelName+"/HVAC (Room)","fracRoomVolDC",strcat(num2str(controlParam.Room.RoomVolFracAsset),genericMsg));
    
end