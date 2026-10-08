function vRms = rmsEnvelope(t, v, windowDuration)
%RMSENVELOPE Compute sliding-window RMS of a signal.
%
%   vRms = hsplot.utils.rmsEnvelope(t, v, windowDuration) returns the RMS
%   computed over a moving window of windowDuration seconds.

% Copyright 2026 The MathWorks, Inc.

dt = median(diff(t));
winSamples = max(1, round(windowDuration / dt));

v2 = v(:).^2;
kernel = ones(winSamples, 1) / winSamples;
v2_avg = conv(v2, kernel, 'same');
vRms = sqrt(v2_avg);
end
