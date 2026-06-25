% Script to generate different fidilities of building room walls.

% Copyright 2024 The MathWorks, Inc.

% Load Model
load_system('WallModel')

% Generate SSC code for wall with windows and vents. Captures solar impact
subsystem2ssc('WallModel/WallSolarWithWindowsAndVents')

% Generate SSC code for wall with windows only. Captures solar impact
subsystem2ssc('WallModel/WallSolarWithWindows')

% Generate SSC code for wall with vents only. Captures solar impact
subsystem2ssc('WallModel/WallSolarWithVents')

% Generate SSC code for wall with vents only.
subsystem2ssc('WallModel/WallWithVents')

% Generate SSC code for wall only. Captures solar impact
subsystem2ssc('WallModel/WallSolar')

% Generate SSC code for wall only. Does not model Solar impact. Suited for
% internal walls, roofs, and floors.
subsystem2ssc('WallModel/Wall')

% Close Model
close_system('WallModel')
