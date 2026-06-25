%% Set parameters for Data Center liquid cooling example

% Copyright 2026 The MathWorks, Inc.

%% Set environment (for ambient temperature profile generation)
env.location = getGeoLocationForMajorCities(CityName="London");

val = char(env.location.Latitude); 
env.latitude = str2double(val(1:end-1));
val = char(env.location.Longitude); 
env.longitude = str2double(val(1:end-1));
val = char(env.location.("Meredian (Time Zone)"));
env.refLongitude = str2double(val(1:end-1));

env.nDays = 8;
env.startYear = 2025;
env.startMonth = 6;
env.startDate = 1;
env.startHour = 1;
% The vector size below must be equal to env.nDays specified above.
env.dayTvec = [293 294 296 293 296 294 296 298];   % Day time average temperature, K
env.nightTvec = [291 293 290 289 291 289 288 293]; % Night time average temperature, K
clear val

%% CDU parameters
% Chiller Setpoint
cdu.T_chiller = 18; % degC

% Total connecting port areas
cdu.port_area = 0.2; % m^2

% Cooling tower
cdu.T_reservoir = 23; % degC
cdu.fan_area = 15; % m^2
cdu.tower_height = 3; % m
cdu.tower_area = 15; % m^2

% Refrigeration variant parameters
cdu.rho_pipe = 7800; % kg/m^3
cdu.cp_pipe = 500; % J/(kg*K)