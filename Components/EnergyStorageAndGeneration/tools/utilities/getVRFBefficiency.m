function eff = getVRFBefficiency(NameValueArgs)
% Calculates the VRFB rating.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.NominalCurrent (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.NominalCurrent, "A")}
        NameValueArgs.NominalFlowrate (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.NominalFlowrate, "lpm")}
        NameValueArgs.AmbientTemperature (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.AmbientTemperature, "K")}
        NameValueArgs.ModelOptions string {mustBeMember(NameValueArgs.ModelOptions,["Open Model","Open and Close Model","Load and Close Model"])} = "Open Model"
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.ScaleSolverTime (1,1) {mustBeNonnegative} = 1.25
    end
    
    [ModelNameStr,ModelBlockName] = getBlockAndModelNameFromBlockPath(BlockPath=NameValueArgs.BlockPath);

    if or(NameValueArgs.ModelOptions=="Open Model",NameValueArgs.ModelOptions=="Open and Close Model")
        open_system(ModelNameStr);
    end

    if NameValueArgs.ModelOptions=="Load and Close Model"
        load_system(ModelNameStr);
    end
    
    rating = simscape.Value([0;0],"kW");
    maxStackTemp = simscape.Value([0;0],"K");

    Np = str2double(get_param(ModelNameStr+"/"+ModelBlockName,"Np"));
    
    ampHrBlk = getAhrVRFB(ModelNameStr+"/"+ModelBlockName);
    amprCurr = value(ampHrBlk,"A*hr")/(value(NameValueArgs.NominalCurrent,"A")/Np);
    runTimeVal = NameValueArgs.ScaleSolverTime*round(3600*amprCurr,1);
    set_param(ModelNameStr,"StopTime"',num2str(runTimeVal));

    set_param(ModelNameStr+"/stopUponBatterySOCdepletion","Value",getParameterizationStr(num2str(1)));
    set_param(ModelNameStr+"/flowrate","constant",getParameterizationStr(num2str(value(NameValueArgs.NominalFlowrate,"lpm"))));

    set_param(ModelNameStr+"/"+ModelBlockName,"initialTsys",getParameterizationStr(num2str(value(NameValueArgs.AmbientTemperature,"K"))));
    if get_param(ModelNameStr+"/"+ModelBlockName,"thermalManagement")=="vanadiumRedoxFlowThermalModel.enabled"
        set_param(ModelNameStr+"/Amb","temperature",num2str(value(NameValueArgs.AmbientTemperature,"K")));
        % No comment added to temperature source param as it is used in get_param from another function.
    end

    % Discharging (1) & Charging (2)
    for chg = 1:2
        if NameValueArgs.Diagnostics
            if chg==1, disp("*** Start discharge test."); else, disp("*** Start charge test."); end
        end
        if chg == 1, initialSOC = 0.99; else, initialSOC = 0.01; end
        set_param(ModelNameStr+"/"+ModelBlockName,"SOC",getParameterizationStr(num2str(initialSOC)));
        set_param(ModelNameStr+"/curr","initialSOC",getParameterizationStr(num2str(initialSOC)));
        if chg == 1, currSign = -1; else, currSign = 1; end
        set_param(ModelNameStr+"/curr","current",getParameterizationStr(num2str(currSign*abs(value(NameValueArgs.NominalCurrent,"A")))));
        sim(ModelNameStr);
        v = simlog_vrfbResults.Vanadium_Redox_Flow_Battery.v.series.values;
        i = simlog_vrfbResults.Vanadium_Redox_Flow_Battery.i.series.values;
        p = abs(v.*i)-simlog_vrfbResults.Vanadium_Redox_Flow_Battery.pump_power.series.values;
        t = simlog_vrfbResults.Vanadium_Redox_Flow_Battery.i.series.time;
        rating(chg,1) = simscape.Value(round((sum(diff(t).*p(2:end))/t(end))/1000,2),"kW");
        maxStackTemp(chg,1) = simscape.Value(max(max(simlog_vrfbResults.Vanadium_Redox_Flow_Battery.stackCellT.series.values)),"K");
        if NameValueArgs.Diagnostics
            if chg==1, disp("*** Completed discharge test."); else, disp("*** Completed charge test."); end
        end
    end
    
    eff = round(100*value(rating(1,1),"kW")/value(rating(2,1),"kW"),1);

    if NameValueArgs.Diagnostics
        disp(strcat("VRFB discharge power ~ ",num2str(value(rating(1,1),"kW")),"kW."));
        disp(strcat("VRFB charge power ~ ",num2str(value(rating(2,1),"kW")),"kW."));
        disp(strcat("VRFB discharge energy ~ ",num2str(value(rating(1,1),"kW")*t(end)/3600),"kWhr."));
        disp(strcat("VRFB charge energy ~ ",num2str(value(rating(2,1),"kW")*t(end)/3600),"kWhr."));
        disp(strcat("Efficiency ~ ",num2str(eff),"%."));
        disp(strcat("Max. stack temperature during discharge ~ ",num2str(round(value(maxStackTemp(1,1),"K"),0)),"K."));
        disp(strcat("Max. stack temperature during charge ~ ",num2str(round(value(maxStackTemp(2,1),"K"),0)),"K."));
    end

    set_param(ModelNameStr+"/stopUponBatterySOCdepletion","Value",getParameterizationStr(num2str(0)));

    if or(NameValueArgs.ModelOptions=="Load and Close Model",NameValueArgs.ModelOptions=="Open and Close Model")
        bdclose(ModelNameStr);
    end
end