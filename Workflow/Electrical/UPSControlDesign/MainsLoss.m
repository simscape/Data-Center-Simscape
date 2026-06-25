% Copyright 2026 The MathWorks, Inc.

breaker.grid = 4;
breaker.generator = 4.5;
breaker.UPS = 5;
gridCode = 6;
lvrt.startTime = 4;
lvrtProfileName = 'MainsLoss';
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtTest.getLVRTProfile('MainsLoss'), Ts, 10, lvrt.startTime);