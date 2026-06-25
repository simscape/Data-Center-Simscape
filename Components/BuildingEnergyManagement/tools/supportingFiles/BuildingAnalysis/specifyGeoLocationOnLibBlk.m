function specifyGeoLocationOnLibBlk(NameValueArgs)
% Specify location on library block
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Location table {mustBeNonempty}
        NameValueArgs.DayLightSavingHrs (1,1) {mustBeNonnegative}
        NameValueArgs.CustomLibBlkPath string {mustBeNonempty}
    end

    % Process geographic data
    geoLocation = NameValueArgs.Location;
    geoLat = str2double(geoLocation.Latitude{1,1}(1,1:end-1));
    geoLong = str2double(geoLocation.Longitude{1,1}(1,1:end-1));
    stdTimeZone = str2double(geoLocation.("Meredian (Time Zone)"){1,1}(1,1:end-1));
    if strcmp("N",geoLocation.Latitude{1,1}(end)) || strcmp("n",geoLocation.Latitude{1,1}(end))
        % hemisphereNS = "Northern";
    else
        % hemisphereNS = "Southern";
        geoLat = -1*geoLat;
    end
    if strcmp("E",geoLocation.Longitude{1,1}(end)) || strcmp("e",geoLocation.Longitude{1,1}(end))
        % hemisphereEW = "Eastern";
    else
        % hemisphereEW = "Western";
        geoLong = -1*geoLong;
        stdTimeZone = -1*stdTimeZone;
    end
    val = getParamStr(num2str(geoLat));
    set_param(NameValueArgs.CustomLibBlkPath,"latitude",val);
    val = getParamStr(num2str(geoLong));
    set_param(NameValueArgs.CustomLibBlkPath,"longitude",val);
    val = getParamStr(num2str(stdTimeZone));
    set_param(NameValueArgs.CustomLibBlkPath,"localTime",val);
    val = getParamStr(num2str(NameValueArgs.DayLightSavingHrs));
    set_param(NameValueArgs.CustomLibBlkPath,"dayLightS",val);
end