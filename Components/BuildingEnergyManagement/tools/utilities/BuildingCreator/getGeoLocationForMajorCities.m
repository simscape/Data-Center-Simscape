function geoLocation = getGeoLocationForMajorCities(NameValueArgs)
% Function to specify geographical location of interest and load relevant 
% data from the excel file.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.CityName string = "Blank Template"
    end

    if strcmp(NameValueArgs.CityName,"Blank Template")
        tblData = load ('geographicalLocationData.mat');
        
        cityNameList = getAllCityNamesDB(tblData);
        disp(strcat("You can provide one of these locations as input to the function :",cityNameList));
        disp("Or, if your location data is not available, then you can specify it by creating a data template and providing relevant data.");
        disp(" ");
        location     = "Need to Specify Name";
        degLongitude = {'0E'};
        degLatitude  = {'0N'};
        stdTimeZone  = {'0E'};
        geoLocation = table(degLatitude,degLongitude,stdTimeZone,...
            'VariableNames',{'Latitude','Longitude','Meredian (Time Zone)'},...
            'RowNames',location);
        disp("You must add data to this template. Add data of type cell, with N/E/S/W added to the degree values. Check any pre-popluated field data for reference");
        displayDocExample();
    else
        tblData = load ('geographicalLocationData.mat');
        location     = tblData.data(:,1).Variables;
        degLongitude = tblData.data(:,3).Variables;
        degLatitude  = tblData.data(:,2).Variables;
        stdTimeZone  = tblData.data(:,4).Variables;
        allDataSize  = [length(location),length(degLongitude),length(degLatitude),length(stdTimeZone)];
        if all(allDataSize == allDataSize(1))
            % Return tabular Data
            allGeoLocation = table(degLatitude,degLongitude,stdTimeZone,...
                                  'VariableNames',{'Latitude','Longitude','Meredian (Time Zone)'},...
                                  'RowNames',location);
            isLocationAvailable = contains(location,NameValueArgs.CityName,'IgnoreCase',true);
            locID = find(isLocationAvailable==1);
            if isempty(locID)
                % Display error
                cityNameList = getAllCityNamesDB(tblData);
                disp(strcat('Location name :',NameValueArgs.CityName,' not found in internal database'));
                disp(strcat("You can provide one of these locations as input to the function :",cityNameList));
                disp("Or, if your location data is not available, then you can specify it by creating a data template and providing relevant data.");
                disp(" ");
                disp('*** Please run getGeoLocationForMajorCities() with no arguments to create a template, which you could populate with your own data.');
                displayDocExample();
                geoLocation = [];
            else
                geoLocation = allGeoLocation(locID,:);
            end
        else
            % Display error
            disp('Error: data missing for some locations.');
            geoLocation  = [];
        end
    end
end

function displayDocExample()
    disp(' ');
    disp('EXAMPLE. Store output of getGeoLocationForMajorCities in geoLocation, and then update:');
    disp('>> geoLocation = getGeoLocationForMajorCities()');
    disp(strcat('>> geoLocation.Row = ',string("'"),'MyCityName',string("'")));
    disp(strcat('>> geoLocation.Longitude = {',string("'"),num2str(5),'W',string("'"),'}'));
    disp(strcat('>> geoLocation.Latitude = {',string("'"),num2str(25),'N',string("'"),'}'));
    disp(strcat('>> geoLocation.(',string("'"),'Meredian (Time Zone)',string("'"),') = {',string("'"),num2str(5),'W',string("'"),'}'));
    disp(' ');
    disp('See: ListOfUsefulFunctions for documentation on getGeoLocationForMajorCities().');
end

function cityNameList = getAllCityNamesDB(tblData)
    locationExample = tblData.data(:,1).Variables;
    len = length(locationExample);
    cityNameList = locationExample{1,1};
    for i = 2:len
        cityNameList = strcat(cityNameList,", ",locationExample{i,1});
    end
    cityNameList = strcat(cityNameList,".");
end