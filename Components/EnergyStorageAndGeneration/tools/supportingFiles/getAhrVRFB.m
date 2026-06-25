function Ahr = getAhrVRFB(BlockPath)
% Get VRFB Ahr rating
% 
% Copyright 2026 The MathWorks, Inc.

    arguments
        BlockPath string {mustBeNonempty}
    end
    
    F = simscape.Value(26.80, "A*hr/mol"); % 26.80 = 96485/3600
    MolarConc = str2num(get_param(BlockPath,"molar"));
    MolarConc_unit = get_param(BlockPath,"molar_unit");
    MolarConc = simscape.Value(MolarConc,MolarConc_unit);
    MolarConc = simscape.Value(value(MolarConc,"mol/m^3"),"mol/m^3");
      
    StackLen = str2num(get_param(BlockPath,"stackLen"));
    StackLen_unit = get_param(BlockPath,"stackLen_unit");
    StackLen = simscape.Value(StackLen,StackLen_unit);
    StackLen = simscape.Value(value(StackLen,"m"),"m");

    StackWid = str2num(get_param(BlockPath,"stackWid"));
    StackWid_unit = get_param(BlockPath,"stackWid_unit");
    StackWid = simscape.Value(StackWid,StackWid_unit);
    StackWid = simscape.Value(value(StackWid,"m"),"m");

    StackHgt = str2num(get_param(BlockPath,"stackHgt"));
    StackHgt_unit = get_param(BlockPath,"stackHgt_unit");
    StackHgt = simscape.Value(StackHgt,StackHgt_unit);
    StackHgt = simscape.Value(value(StackHgt,"m"),"m");

    StackVol = StackLen*StackWid*StackHgt;
    
    Ahr = F*MolarConc*StackVol;
end