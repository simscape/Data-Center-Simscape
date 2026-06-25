%% WallModel.slx parameters

% Copyright 2024 The MathWorks, Inc.

win.area = 25; % m^2
win.thickness = 7e-3; % m
win.mass = 2500*win.area*win.thickness;
win.Cp = 787;
win.K = 1;
win.absorp = 0.35;
win.trans = 0.45;

wall.area = 70; % m^2
wall.thickness = 0.3; % m
wall.mass = 2400*wall.area*wall.thickness;
wall.Cp = 1870;
wall.K = 2;
wall.absorp = 0.5;

flow.htc.int = 5;
flow.htc.ext = 5;
flow.iniT = 300;
flow.vent.area = 1e-10;
flow.airDen = 1.28;
flow.airCp = 700;

roomHeight = 5;