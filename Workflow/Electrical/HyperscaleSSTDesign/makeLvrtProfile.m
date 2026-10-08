function lvrtProfile = makeLvrtProfile(sagDepth, sagStart, sagDuration, tEnd)
%MAKELVRTPROFILE Create a voltage sag timeseries for the Grid LVRT input.
%
%   lvrtProfile = makeLvrtProfile(sagDepth, sagStart, sagDuration)
%   creates a timeseries with a voltage sag from 1.0 to sagDepth (pu),
%   starting at sagStart (s) and lasting sagDuration (s).
%   Ramp-down = 1 cycle (16.7ms), ramp-up = 2 cycles (33.3ms).
%
%   lvrtProfile = makeLvrtProfile(sagDepth, sagStart, sagDuration, tEnd)
%   specifies the total profile duration (default: 10s).

% Copyright 2026 The MathWorks, Inc.

arguments
    sagDepth (1,1) double
    sagStart (1,1) double
    sagDuration (1,1) double
    tEnd (1,1) double = 10
end

dt = 5e-5;
t = (0:dt:tEnd)';
profile = ones(size(t));

rampDown = round(1/60/dt);
rampUp = round(2/60/dt);
startIdx = round(sagStart/dt);
holdSamples = round(sagDuration/dt) - rampDown - rampUp;

if holdSamples < 0
    holdSamples = 0;
end

profile(startIdx:startIdx+rampDown-1) = linspace(1.0, sagDepth, rampDown);
profile(startIdx+rampDown:startIdx+rampDown+holdSamples-1) = sagDepth;
profile(startIdx+rampDown+holdSamples:startIdx+rampDown+holdSamples+rampUp-1) = ...
    linspace(sagDepth, 1.0, rampUp);

lvrtProfile = timeseries(profile, t, 'Name', 'LvrtVoltage');
end
