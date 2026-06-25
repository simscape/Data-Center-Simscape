% Copyright 2026 The MathWorks, Inc.

% LVRT Parameters
lvrt.startTime = 3;
loadPower = 5e6;
lvrtCode = lvrtTest.getLVRTProfile(lvrtProfileName);
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtCode, Ts, 10, lvrt.startTime);
