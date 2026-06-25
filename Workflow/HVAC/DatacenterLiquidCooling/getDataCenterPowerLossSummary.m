function data = getDataCenterPowerLossSummary(NameValueArgs)

% Copyright 2026 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.MeasurementData {mustBeNonempty}
    end
    
    data.result = NameValueArgs.MeasurementData.extractTimetable;
    tm  = seconds(data.result.Time);

    pow = data.result.Pow(:,4);
    data.avgAuxLosses_kW.compressor = simscape.Value(round(sum(pow(2:end).*diff(tm))/tm(end),1),"kW");

    pow = data.result.Pow(:,1);
    data.avgAuxLosses_kW.condenser = simscape.Value(round(sum(pow(2:end).*diff(tm))/tm(end),1),"kW");

    pow = data.result.Pow(:,3);
    data.avgAuxLosses_kW.chiller = simscape.Value(round(sum(pow(2:end).*diff(tm))/tm(end),1),"kW");

    pow = data.result.Pow(:,2);
    data.avgAuxLosses_kW.fan = simscape.Value(round(sum(pow(2:end).*diff(tm))/tm(end),1),"kW");
   
    data.avgAuxLosses_kW.total = data.avgAuxLosses_kW.compressor + ...
                                 data.avgAuxLosses_kW.condenser + ...
                                 data.avgAuxLosses_kW.chiller + ...
                                 data.avgAuxLosses_kW.fan;
    
    % Server T, Evaporator Outlet T, Condenser Outlet T, Ambient T, Cooling Tower Outlet T, Server Coolant Outlet T
    data.temperature_degC.serverRackMax = simscape.Value(round(data.result.T(:,1),1),"degC");
    data.temperature_degC.evaporatorOutlet = simscape.Value(round(data.result.T(:,2),1),"degC");
    data.temperature_degC.condenserOutlet = simscape.Value(round(data.result.T(:,3),1),"degC");
    data.temperature_degC.ambient = simscape.Value(round(data.result.T(:,4),1),"degC");
    data.temperature_degC.coolingTowerOutlet = simscape.Value(round(data.result.T(:,5),1),"degC");
    data.temperature_degC.serverCoolantOutlet = simscape.Value(round(data.result.T(:,6),1),"degC");
end