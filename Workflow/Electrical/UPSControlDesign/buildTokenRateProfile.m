function tokenRateProfile = buildTokenRateProfile(waypoints, sampleTime, simDuration)
%BUILDTOKENRATEPROFILE Generate smooth server utilization profile from waypoints.
%
%   tokenRateProfile = buildTokenRateProfile(waypoints, sampleTime, simDuration)
%
%   INPUTS:
%     waypoints   - struct with fields:
%                     .time     - waypoint arrival times (s)
%                     .rate     - normalized token rate at each waypoint (0-1)
%                     .riseTime - S-curve transition duration (s)
%     sampleTime  - time step for the profile (s)
%     simDuration - total simulation duration (s)
%
%   OUTPUT:
%     tokenRateProfile - timeseries of server utilization (0-1)

% Copyright 2026 The MathWorks, Inc.

    timeVector = 0:sampleTime:simDuration;
    numSamples = numel(timeVector);
    utilVector = zeros(1, numSamples);

    waypointTimes = waypoints.time;
    waypointRates = waypoints.rate;
    riseTime = waypoints.riseTime;
    numWaypoints = numel(waypointTimes);

    for sampleIdx = 1:numSamples
        currentTime = timeVector(sampleIdx);
        utilValue = waypointRates(numWaypoints);

        for segIdx = 1:numWaypoints - 1
            segStart = waypointTimes(segIdx);
            segEnd = waypointTimes(segIdx + 1);
            levelFrom = waypointRates(segIdx);
            levelTo = waypointRates(segIdx + 1);
            transitionStart = segEnd - riseTime;

            if currentTime >= segStart && currentTime < segEnd
                if currentTime < transitionStart
                    utilValue = levelFrom;
                else
                    alpha = max(0, min(1, (currentTime - transitionStart) / riseTime));
                    utilValue = levelFrom + (levelTo - levelFrom) * 0.5 * (1 - cos(pi * alpha));
                end
                break;
            end
        end

        utilVector(sampleIdx) = max(0, min(1, utilValue));
    end

    tokenRateProfile = timeseries(utilVector(:), timeVector(:), 'Name', 'TokenRate');

end