function specifyDateTimeOnLibBlk(NameValueArgs)
% Specify datetime on library block
%
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.EndTime datetime {mustBeNonempty}
        NameValueArgs.CustomLibBlkPath string {mustBeNonempty}
        NameValueArgs.CustomLibBlkName string {mustBeNonempty}
    end

    nHours = hours(NameValueArgs.EndTime-NameValueArgs.StartTime);
    nDays = ceil(nHours/24)+1;

    val = getParamStr(num2str(year(NameValueArgs.StartTime)));
    set_param(NameValueArgs.CustomLibBlkPath,"startYear",val);
    val = getParamStr(num2str(month(NameValueArgs.StartTime)));
    set_param(NameValueArgs.CustomLibBlkPath,"startMonth",val);
    val = getParamStr(num2str(day(NameValueArgs.StartTime)));
    set_param(NameValueArgs.CustomLibBlkPath,"startDay",val);
    val = getParamStr(num2str(hour(NameValueArgs.StartTime)));
    set_param(NameValueArgs.CustomLibBlkPath,"startHr",val);
    
    
    if NameValueArgs.CustomLibBlkName == "buildingEnergy_lib/Temperature Source"+newline+"(LUT)"
        val = getParamStr(num2str(nDays));
        set_param(NameValueArgs.CustomLibBlkPath,"numDaysData",val);
    else
        % "SolarRadiationOnSurface_lib", "SolarRadiationAtLocation_lib", "ExternalWall_lib"
        val = getParamStr(num2str(nHours));
        set_param(NameValueArgs.CustomLibBlkPath,"numHrsData",val);
    end
end