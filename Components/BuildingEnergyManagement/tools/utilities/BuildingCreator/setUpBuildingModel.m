function setUpBuildingModel(NameValueArgs)
% Setup template model for Building analysis.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.NewModelName string {mustBeNonempty} = "BuildingModel"
        NameValueArgs.BuildingLibName string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.LibDisplaySize (1,1) {mustBeNonnegative} = 100
        NameValueArgs.LibStartPositionOnCanvas (1,2) {mustBeNonempty} = [400 200]
        NameValueArgs.AddEnvironmentBlocks logical {mustBeNumericOrLogical} = true
        NameValueArgs.EnvLibDisplaySize (1,1) {mustBeNonnegative} = 50
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.EndTime datetime {mustBeNonempty}
        NameValueArgs.DayLightSavingHours (1,1) {mustBeNonempty} = 0
        NameValueArgs.GeoLocation table {mustBeNonempty}
        NameValueArgs.DayTimeTemperature (1,:) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.DayTimeTemperature, "K")}
        NameValueArgs.DayTimeTemperatureVar (1,1) {mustBeNonnegative} = 2
        NameValueArgs.NightTimeTemperature (1,:) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.NightTimeTemperature, "K")}
        NameValueArgs.NightTimeTemperatureVar (1,1) {mustBeNonnegative} = 2
    end

    % Check temperature data type and accuracy
    nDays = days(NameValueArgs.EndTime-NameValueArgs.StartTime);
    lenTempDay = size(NameValueArgs.DayTimeTemperature,2);
    lenTempNight = size(NameValueArgs.NightTimeTemperature,2);
    singleTemperatureSpecified = false;
    if lenTempDay == lenTempNight
        dayTimeTemperature = NameValueArgs.DayTimeTemperature;
        nightTimeTemperature = NameValueArgs.NightTimeTemperature;
        if lenTempDay == 1
            singleTemperatureSpecified = true;
            tempValue = value(NameValueArgs.DayTimeTemperature,"K");
            dayTimeTemperature = simscape.Value(tempValue*ones(1,nDays),"K");
            tempValue = value(NameValueArgs.NightTimeTemperature,"K");
            nightTimeTemperature = simscape.Value(tempValue*ones(1,nDays),"K");
        end
    else
        error("The length of data for Day and Night temperatures must match.");
    end

    % Add building library blocks on Simulink to help create a good
    % starting point.
    success = setUpBuildingEnergyManagmentSystem(...
        NewModelName=NameValueArgs.NewModelName,...
        BuildingLibName=NameValueArgs.BuildingLibName,...
        StartTime=NameValueArgs.StartTime,...
        EndTime=NameValueArgs.EndTime,...
        SingleTemperatureModel=singleTemperatureSpecified,...
        SingleTemperatureInit=(dayTimeTemperature(1,1)+nightTimeTemperature(1,1))/2);
    % Parameterize and assign initial temperature values.
    if ~success
        error("Failed to set up the building energy management system, setUpBuildingEnergyManagmentSystem().");
    else
        setDateTimeAndGeoLocation(...
            BuildingModel=NameValueArgs.NewModelName,...
            DayLightSavingHours=NameValueArgs.DayLightSavingHours,...
            Diagnostics=NameValueArgs.Diagnostics,...
            GeoLocation=NameValueArgs.GeoLocation,...
            StartTime=NameValueArgs.StartTime,...
            EndTime=NameValueArgs.EndTime,...
            DayTimeTemperatureVec=dayTimeTemperature,...
            DayTimeTemperatureVar=NameValueArgs.DayTimeTemperatureVar,...
            NightTimeTemperatureVec=nightTimeTemperature,...
            NightTimeTemperatureVar=NameValueArgs.NightTimeTemperatureVar,...
            CalcBuildingIniTemperature=true);
        set_param(NameValueArgs.NewModelName,"StopTime",num2str(max(hours(NameValueArgs.EndTime-NameValueArgs.StartTime)-1,1)*3600));
    end
end