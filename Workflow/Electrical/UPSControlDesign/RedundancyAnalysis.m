% Copyright 2026 The MathWorks, Inc.

% N+1 redundancy
model = "UPSControl";
blockPath = strcat(model,'/','Server Load','/','UPS Units');
set_param(blockPath,'upsConfiguration','Three UPS Parallel');
loadPower = 10e6;
lvrtProfileName = 'None';
utilizationFactor = 1;
parasiticConductance = 0;
breaker.grid = 40;
breaker.generator = 45;
breaker.UPS = 5;
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtTest.getLVRTProfile('None'), Ts, 10, lvrt.startTime);