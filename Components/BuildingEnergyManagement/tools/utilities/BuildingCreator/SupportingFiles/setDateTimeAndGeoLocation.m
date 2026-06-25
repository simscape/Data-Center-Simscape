function setDateTimeAndGeoLocation(NameValueArgs)
% Set time and location.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingModel string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.EndTime datetime {mustBeNonempty}
        NameValueArgs.DayLightSavingHours (1,1) {mustBeNonempty} = 0
        NameValueArgs.GeoLocation table {mustBeNonempty}
        NameValueArgs.DayTimeTemperatureVec (1,:) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.DayTimeTemperatureVec, "K")} = simscape.Value(300*ones(1,1),"K")
        NameValueArgs.DayTimeTemperatureVar (1,1) {mustBeNonnegative} = 2
        NameValueArgs.NightTimeTemperatureVec (1,:) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.NightTimeTemperatureVec, "K")} = simscape.Value(300*ones(1,1),"K")
        NameValueArgs.NightTimeTemperatureVar (1,1) {mustBeNonnegative} = 2
        NameValueArgs.CalcBuildingIniTemperature logical {mustBeNumericOrLogical} = true
    end

    if bdIsLoaded(NameValueArgs.BuildingModel)
        listOfBlocksToParameterize = ["SolarRadiationAtLocation_lib",...
                                      "SolarRadiationOnSurface_lib",...
                                      "ExternalWall_lib",...
                                      "TemperatureSource_lib"];
        listOfLibBlocks = libinfo(NameValueArgs.BuildingModel);
        blkTemperatureSource = false;
        for i = 1:size(listOfLibBlocks,1)
            if listOfLibBlocks(i,1).Library == "TemperatureSource_lib"
                blkTemperatureSource = true;
                disp("*** Block <TemperatureSource_lib> found in the model.");
            end
        end
        
        % Analyze temperature variation data
        nDays = days(NameValueArgs.EndTime-NameValueArgs.StartTime);
        if blkTemperatureSource
            % Do this ONLY if TemperatureSource_lib Block is present in the model. 
            lenDayTimeTvec = size(NameValueArgs.DayTimeTemperatureVec,2);
            lenNightTimeTvec = size(NameValueArgs.NightTimeTemperatureVec,2);
            if and(lenDayTimeTvec~=nDays,lenNightTimeTvec~=nDays)
                usrDataMissing = true;
            elseif and(lenDayTimeTvec~=nDays,lenNightTimeTvec==nDays)
                usrDataMissing = true;
            elseif and(lenDayTimeTvec==nDays,lenNightTimeTvec~=nDays)
                usrDataMissing = true;
            else
                usrDataMissing = false;
            end
            if usrDataMissing
                dayTimeTvec = 300*ones(1,nDays);
                nightTimeTvec = 300*ones(1,nDays);
                disp(" ");
                disp(strcat("*** WARNING *** Missing inputs for daily average temperature vector values. Assuming 300K for day and night temperatures for all ",num2str(nDays),"-days of simulation. You must ensure that the building initial temperature is set to the same value."));
                disp(" ");
            else
                dayTimeTvec = value(NameValueArgs.DayTimeTemperatureVec,"K");
                nightTimeTvec = value(NameValueArgs.NightTimeTemperatureVec,"K");
            end
            % Time varaying temperature profile
            if NameValueArgs.CalcBuildingIniTemperature
                [t,Tamb] = getHourlyTemperatureVectorData(...
                    year(NameValueArgs.StartTime),...
                    month(NameValueArgs.StartTime),...
                    day(NameValueArgs.StartTime),...
                    nDays,...
                    hour(NameValueArgs.StartTime),...
                    str2double(NameValueArgs.GeoLocation.Latitude{1,1}),...
                    str2double(NameValueArgs.GeoLocation.Longitude{1,1}),...
                    str2double(NameValueArgs.GeoLocation.("Meredian (Time Zone)"){1,1}),...
                    NameValueArgs.DayLightSavingHours,...
                    dayTimeTvec,...
                    NameValueArgs.DayTimeTemperatureVar/100,...
                    nightTimeTvec,...
                    NameValueArgs.NightTimeTemperatureVar/100);
                iniTemperature = round(interp1(t,Tamb,hour(NameValueArgs.StartTime)*3600),1);
                disp(strcat("*** Set initial temperature for Building Library to ",num2str(iniTemperature),"K."));
                % Set building initial temperature
                setBuildingInitialTemperature(BuildingModel=NameValueArgs.BuildingModel,...
                                              InitialTemperature=simscape.Value(iniTemperature,"K"));
            end
        end
        % Start parameterizing
        count = 0;
        for i = 1:size(listOfLibBlocks,1)
            libName = listOfLibBlocks(i,1).Library;
            libPath = listOfLibBlocks(i,1).Block;
            % All block parameters for location and datetime.
            [success,whichOne] = ismember(libName,listOfBlocksToParameterize);
            if success
                count = count + 1;
                if NameValueArgs.Diagnostics
                    disp(strcat("(",num2str(count),") Parameterize Block ",libName,", at path ",libPath));
                end
                % Latitude
                strNew = NameValueArgs.GeoLocation.Latitude{1,1};
                val = getParamStr(strNew(1:end-1));
                set_param(libPath,"latitude",val);
                % Longitude
                strNew = NameValueArgs.GeoLocation.Longitude{1,1};
                val = getParamStr(strNew(1:end-1));
                set_param(libPath,"longitude",val);
                % Local Time
                strNew = NameValueArgs.GeoLocation.("Meredian (Time Zone)"){1,1};
                val = getParamStr(strNew(1:end-1));
                set_param(libPath,"localTime",val);
                % Local Time
                strNew = NameValueArgs.GeoLocation.("Meredian (Time Zone)"){1,1};
                val = getParamStr(strNew(1:end-1));
                set_param(libPath,"localTime",val);
                % Year
                val = getParamStr(num2str(year(NameValueArgs.StartTime)));
                set_param(libPath,"startYear",val);
                % Month
                val = getParamStr(num2str(month(NameValueArgs.StartTime)));
                set_param(libPath,"startMonth",val);
                % Day
                val = getParamStr(num2str(day(NameValueArgs.StartTime)));
                set_param(libPath,"startDay",val);
                % Hour
                val = getParamStr(num2str(hour(NameValueArgs.StartTime)));
                set_param(libPath,"startHr",val);
                % Daylight Savings
                val = getParamStr(num2str(NameValueArgs.DayLightSavingHours));
                set_param(libPath,"dayLightS",val);
                if whichOne == 4
                    % It must be kept in mind that the Temperature block
                    % may or may not be used by the user.
                    % TemperatureSource_lib requires numDaysData. Rest of the
                    % blocks require numHrsData parameter
                    val = getParamStr(num2str(nDays));
                    set_param(libPath,"numDaysData",val);
                    % Set Temperature vector data
                    val = getParamStr(strcat("[",num2str(dayTimeTvec),"]"));
                    set_param(libPath,"avgDayTvec",val);
                    val = getParamStr(strcat("[",num2str(nightTimeTvec),"]"));
                    set_param(libPath,"avgNightTvec",val);
                    val = getParamStr(num2str(NameValueArgs.DayTimeTemperatureVar));
                    set_param(libPath,"pcDayTvar",val);
                    val = getParamStr(num2str(NameValueArgs.NightTimeTemperatureVar));
                    set_param(libPath,"pcNightTvar",val);
                else
                    % All other blocks required this data in terms of hours
                    % and not days.
                    val = getParamStr(num2str(hours(NameValueArgs.EndTime-NameValueArgs.StartTime)));
                    set_param(libPath,"numHrsData",val);
                end
                
            end
        end
    else
        disp(strcat("*** Error: The model ",NameValueArgs.BuildingModel," must be loaded."));
    end
end