function lvrtProfile = buildProfile(gridCode, sampleTime, simDuration, faultStartTime)
%BUILDPROFILE Generate LVRT voltage profile timeseries from a grid code struct.
%
%   lvrtProfile = sstLvrt.buildProfile(gridCode, sampleTime, simDuration, faultStartTime)
%
%   INPUTS:
%     gridCode       - struct with fields: name, faultTime, voltagePu, interpolation
%     sampleTime     - simulation time step (s)
%     simDuration    - total simulation duration (s)
%     faultStartTime - absolute time when the fault begins (s)
%
%   OUTPUT:
%     lvrtProfile    - timeseries of grid voltage (pu), 1.0 before fault

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
