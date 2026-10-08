% Copyright 2026 The MathWorks, Inc.

function matFFtbl = setDesignParameterVariation(NameValueArgs)
    arguments (Input)
        NameValueArgs.RoomSetPointTemperature_K (1,:) {mustBeNonnegative} = 290
        NameValueArgs.RoomOperationHVAC (1,:) {mustBeNonnegative} = 1
        NameValueArgs.RoomWallWindowFraction (1,:) {mustBeNonnegative} = 0.8
        NameValueArgs.RoomOrientationAngle_deg (1,:) {mustBeNonnegative} = 0
        NameValueArgs.RoomGlassTransmissivity (1,:) {mustBeNonnegative} = 0.45
        NameValueArgs.RoomWallThickness_m (1,:) {mustBeNonnegative} = 0.10
        NameValueArgs.RoomRoofThickness_m (1,:) {mustBeNonnegative} = 0.08
        NameValueArgs.RoomFloorThickness_m (1,:) {mustBeNonnegative} = 0.12
        NameValueArgs.RoomWindowGlassThickness_m (1,:) {mustBeNonnegative} = 0.005
        NameValueArgs.ServerSetPointTemperature_K (1,:) {mustBeNonnegative} = 300
        NameValueArgs.ChillerCOP (1,:) {mustBeNonnegative} = 4
        NameValueArgs.CoolingTowerFanPowerRatio (1,:) {mustBeNonnegative} = 0.02
        NameValueArgs.CoolingTowerTemperatureRange_K (1,:) {mustBeNonnegative} = 8
        NameValueArgs.PumpEfficiencyPercentHVAC (1,:) {mustBeNonnegative} = 78
        NameValueArgs.PumpEfficiencyPercentCoolTwr (1,:) {mustBeNonnegative} = 80

        NameValueArgs.Diagnostics logical {mustBeNonNan} = true
    end

    DesignOption.Room.Tset = NameValueArgs.RoomSetPointTemperature_K;
    DesignOption.Room.HVAC = NameValueArgs.RoomOperationHVAC;
    DesignOption.Room.WinFrac = NameValueArgs.RoomWallWindowFraction;
    DesignOption.Room.OrientAng = NameValueArgs.RoomOrientationAngle_deg;
    DesignOption.Room.GlassTrans = NameValueArgs.RoomGlassTransmissivity;
    DesignOption.Room.ThicknessWall = NameValueArgs.RoomWallThickness_m;
    DesignOption.Room.ThicknessRoof = NameValueArgs.RoomRoofThickness_m;
    DesignOption.Room.ThicknessFloor = NameValueArgs.RoomFloorThickness_m;
    DesignOption.Room.ThicknessGlass = NameValueArgs.RoomWindowGlassThickness_m;

    DesignOption.PDU.Tset = NameValueArgs.ServerSetPointTemperature_K;
    DesignOption.Chiller.COP = NameValueArgs.ChillerCOP;
    DesignOption.CoolTwr.Trange = NameValueArgs.CoolingTowerTemperatureRange_K;
    DesignOption.CoolTwr.FanPowRatio = NameValueArgs.CoolingTowerFanPowerRatio;
    DesignOption.PumpEfficiency.HVAC = NameValueArgs.PumpEfficiencyPercentHVAC;
    DesignOption.PumpEfficiency.CoolTwr = NameValueArgs.PumpEfficiencyPercentCoolTwr;

    matFFtbl = getDesignOptionScenarioTbl(DesignOption,NameValueArgs.Diagnostics);

end