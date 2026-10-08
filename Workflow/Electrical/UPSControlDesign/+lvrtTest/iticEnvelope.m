function [timeLower, voltageLower, timeUpper, voltageUpper] = iticEnvelope()
%ITICENVELOPE Breakpoints of the ITIC/CBEMA voltage tolerance envelope.
%
%   [tLower, vLower, tUpper, vUpper] = lvrtTest.iticEnvelope() returns the
%   lower and upper ITIC envelope breakpoints, in seconds and pu.
%
%   Lower bound: 0% for <=20 ms, 70% to 0.5 s, 80% to 10 s, 90% steady state.
%   Upper bound: 500% instantaneous, 200% at 1 ms, 140% at 3 ms, 120% to
%   0.5 s, 110% steady state.
%
%   Defined per the ITI (CBEMA) curve as described in IEEE Std 1100. This is
%   the single definition used by both lvrtTest.iticCheck and
%   plot.lvrtAssessment, so the reported verdict and the plotted envelope
%   cannot drift apart.
%
%   Example:
%     [tL, vL, tU, vU] = lvrtTest.iticEnvelope();

% Copyright 2026 The MathWorks, Inc.

timeLower    = [1e-5  0.02   0.0201  0.5   0.501  10];
voltageLower = [0.00  0.00   0.70    0.70  0.80   0.80];

timeUpper    = [1e-5  0.001  0.003   0.5   0.501  10];
voltageUpper = [5.00  2.00   1.40    1.20  1.10   1.10];

end
