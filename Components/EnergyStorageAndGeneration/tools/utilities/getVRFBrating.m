function rating = getVRFBrating(NameValueArgs)
% Get VRFB kW rating
% 
% Copyright 2026 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.NominalCurrent simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.NominalCurrent, "A")}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end
    
    Nc = str2num(get_param(NameValueArgs.BlockPath,"Nc"));
    Ns = str2num(get_param(NameValueArgs.BlockPath,"Ns"));
    Np = str2num(get_param(NameValueArgs.BlockPath,"Np"));
    V0 = str2num(get_param(NameValueArgs.BlockPath,"V0"));
    V0_unit = get_param(NameValueArgs.BlockPath,"V0_unit");
    V0 = simscape.Value(V0,V0_unit);
    V0 = simscape.Value(value(V0,"V"),"V");
    kW = NameValueArgs.NominalCurrent*V0*Ns*Nc;
    kW = value(kW,"kW");
    rating.kW = simscape.Value(kW,"kW");

    rating.ampHour = Np*getAhrVRFB(NameValueArgs.BlockPath);
    
    rating.opTime = rating.ampHour/NameValueArgs.NominalCurrent;

    if NameValueArgs.Diagnostics
        disp(strcat("*** VRFB rating = ",num2str(round(value(rating.kW,"kW"),1)),"kW, ",num2str(round(value(rating.ampHour,"A*hr"),1)),"Ahr."));
        disp(strcat("*** Operation duration ~ ",num2str(round(value(rating.opTime,"hr"),1)),"hr."));
    end
end