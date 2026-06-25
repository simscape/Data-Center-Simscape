% Script to generate building room heating and cooling models.

% Copyright 2024- 2025 The MathWorks, Inc.

% Load Model
load_system('RoomModel')

% Generate SSC code for rooms (heating elements)
subsystem2ssc('RoomModel/RoomUnderFloorPiping');
subsystem2ssc('RoomModel/RoomRadiatorPiping');
subsystem2ssc('RoomModel/RoomHVAC');

% Close Model
close_system('RoomModel')