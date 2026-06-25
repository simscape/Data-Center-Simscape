function lvrtProfile = buildLvrtProfile(gridCode, sampleTime, simDuration, faultStartTime)
%BUILDLVRTPROFILE Generate LVRT voltage profile timeseries from a grid code definition.
%
%   lvrtProfile = buildLvrtProfile(gridCode, sampleTime, simDuration, faultStartTime)
%
%   INPUTS:
%     gridCode       - struct defining the voltage ride-through envelope:
%                        .name          - descriptive name (e.g., 'ERCOT')
%                        .faultTime     - time breakpoints relative to fault onset (s)
%                        .voltagePu     - voltage at each breakpoint (pu)
%                        .interpolation - 'step' or 'linear' for all segments,
%                                         or a cell array with one entry per segment
%                                         e.g., {'step', 'linear', 'step'}
%     sampleTime     - simulation time step (s)
%     simDuration    - total simulation duration (s)
%     faultStartTime - absolute time when the fault begins (s)
%
%   OUTPUT:
%     lvrtProfile    - timeseries of grid voltage (pu), 1.0 before fault
%
%   EXAMPLE - Define a custom grid code:
%     myGridCode.name          = 'Custom';
%     myGridCode.faultTime     = [0, 0.15, 0.5, 2.0, 4.0];
%     myGridCode.voltagePu     = [0.15, 0.50, 0.80, 0.90, 1.0];
%     myGridCode.interpolation = 'step';
%     lvrtProfile = buildLvrtProfile(myGridCode, 5e-5, 10, 2.0);

% Copyright 2026 The MathWorks, Inc.

    timeVector = 0:sampleTime:simDuration;
    numSamples = numel(timeVector);
    voltageVector = ones(1, numSamples);

    faultBreakpoints = gridCode.faultTime;
    voltageBreakpoints = gridCode.voltagePu;
    numBreakpoints = numel(faultBreakpoints);
    numSegments = numBreakpoints - 1;

    if iscell(gridCode.interpolation)
        segmentInterp = gridCode.interpolation;
    else
        segmentInterp = repmat({gridCode.interpolation}, 1, numSegments);
    end

    for sampleIdx = 1:numSamples
        relativeTime = timeVector(sampleIdx) - faultStartTime;

        if relativeTime < 0
            voltageVector(sampleIdx) = 1.0;
            continue;
        end

        if relativeTime >= faultBreakpoints(numBreakpoints)
            voltageVector(sampleIdx) = voltageBreakpoints(numBreakpoints);
            continue;
        end

        for segIdx = 1:numSegments
            segStart = faultBreakpoints(segIdx);
            segEnd = faultBreakpoints(segIdx + 1);

            if relativeTime >= segStart && relativeTime < segEnd
                if strcmpi(segmentInterp{segIdx}, 'linear')
                    fraction = (relativeTime - segStart) / (segEnd - segStart);
                    voltageVector(sampleIdx) = voltageBreakpoints(segIdx) + ...
                        fraction * (voltageBreakpoints(segIdx + 1) - voltageBreakpoints(segIdx));
                else
                    voltageVector(sampleIdx) = voltageBreakpoints(segIdx);
                end
                break;
            end
        end
    end

    lvrtProfile = timeseries(voltageVector(:), timeVector(:), 'Name', 'LvrtVoltage');

end
