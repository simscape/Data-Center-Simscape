% Copyright 2026 The MathWorks, Inc.

% Severe Sag
lvrtProfileName = 'SevereSag';
lvrt.startTime = 3;
lvrtCode = lvrtTest.getLVRTProfile(lvrtProfileName);
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtCode, Ts, 10, lvrt.startTime);