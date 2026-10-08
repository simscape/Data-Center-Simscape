function [passed, lowerLimit, upperLimit] = iticCheck(disturbanceDuration, ...
    loadVoltageMin, loadVoltageMax)
%ITICCHECK Test a sag operating point against the ITIC/CBEMA envelope.
%
%   passed = lvrtTest.iticCheck(duration, vMin, vMax) returns true when the
%   retained load voltage stays inside the ITIC envelope for a disturbance of
%   the given duration.
%
%   [passed, lowerLimit, upperLimit] = lvrtTest.iticCheck(...) also returns
%   the envelope limits (pu) that applied at that duration.
%
%   The operating point follows the PQ analyzer method per IEEE Std 1100:
%     duration - contiguous time the supply stayed below the sag threshold
%     vMin/vMax - extreme retained load voltages over that interval
%
%   A duration outside the tabulated range falls back to the steady-state
%   limits of 0.90 / 1.10 pu.
%
%   Example:
%     [pass, lo, hi] = lvrtTest.iticCheck(2.0, 0.93, 1.02)

% Copyright 2026 The MathWorks, Inc.

arguments
    disturbanceDuration (1,1) double
    loadVoltageMin (1,1) double
    loadVoltageMax (1,1) double
end

[timeLower, voltageLower, timeUpper, voltageUpper] = lvrtTest.iticEnvelope();

lowerLimit = interp1(timeLower, voltageLower, disturbanceDuration, 'previous', 0.90);
upperLimit = interp1(timeUpper, voltageUpper, disturbanceDuration, 'previous', 1.10);

passed = loadVoltageMin >= lowerLimit && loadVoltageMax <= upperLimit;

end
