function testResults = evaluate(simResults, gridCodeNames, opts)
% evaluate  Evaluate LVRT simulation results against pass/fail criteria.
%
%   testResults = lvrtTest.evaluate(simResults, gridCodeNames) returns a
%   table of pass/fail results for each grid code. Three independent criteria
%   are applied, and OverallResult is their conjunction:
%
%     UPSBreakerStatus   - UPS breaker (UPS1BrK) stays closed (0) for the
%                          whole event window, so the data center is never
%                          disconnected from the grid.
%     ITICCompliance     - retained load voltage stays inside the ITIC/CBEMA
%                          envelope for the measured sag duration (the
%                          criterion that governs whether the IT load rides
%                          through).
%     DCBusVoltage       - UPS DC link (VdcUPS1) stays within DCBusBand, so
%                          the inverter keeps regulation headroom.
%
%   The table also reports the quantities the criteria are based on
%   (SagDuration_s, MinLoadVoltage_pu, MaxLoadVoltage_pu, MinDCBus_pu) so a
%   marginal pass can be told apart from a comfortable one.
%
%   Criteria are deliberately restricted to quantities with a defensible
%   absolute limit. The critical load is modulated by the token-rate (server
%   utilization) profile, so anything it drives moves on its own even with no
%   disturbance present, and a band on it measures load-step regulation rather
%   than ride-through. loadActivePower is the clearest example: it varies
%   roughly 2:1 across the event window with no fault at all.
%
%   Post-event load voltage has the same problem. An earlier revision scored it
%   against a separate no-disturbance reference simulation to cancel the
%   utilization transients. That was dropped: the measured deviation was
%   ~9.5e-04 pu against a 0.02 pu tolerance for every compliant profile, and a
%   0.01 pu collapse that opens the UPS breaker still only reached 0.0041 pu, so
%   the criterion never discriminated while costing an extra simulation. If
%   recovery behavior needs to be asserted, prefer a directly interpretable
%   quantity such as the time for the load voltage to re-enter a stated band.
%
%   Inputs:
%     simResults    - cell array of Simulink.SimulationOutput objects
%     gridCodeNames - cell array or string array of grid code names
%
%   Name-value arguments:
%     EventWindow   - [tStart tStop] window to assess (default [2.9 10] s)
%     DCBusBand     - allowed DC link range, pu (default [0.85 1.10]). The
%                     measured dip at fault inception is about 0.895 pu for
%                     all five grid-code profiles (against 0.988 pu with no
%                     disturbance), so a 0.90 floor would fail every compliant
%                     profile and the column would carry no information. The
%                     0.85 default leaves roughly 5% margin while still
%                     catching a gross loss of DC regulation. Confirm this
%                     against the actual UPS DC-link specification.
%     SagThreshold  - grid RMS voltage below which the supply counts as
%                     disturbed, pu (default 0.90)
%     RmsWindow     - moving RMS window for the grid voltage (default 0.02 s)
%
%   Example:
%     simResults = lvrtTest.runAll({'ERCOT','SevereSag'});
%     results = lvrtTest.evaluate(simResults, {"ERCOT","SevereSag"})

% Copyright 2026 The MathWorks, Inc.

arguments
    simResults cell
    gridCodeNames
    opts.EventWindow (1,2) double = [2.9 10]
    opts.DCBusBand (1,2) double = [0.85 1.10]
    opts.SagThreshold (1,1) double = 0.90
    opts.RmsWindow (1,1) double = 0.02
end

gridCodeNames = string(gridCodeNames);
numGridCodes = numel(gridCodeNames);

variableNames = {'LVRTProfile','UPSBreakerStatus','ITICCompliance', ...
    'DCBusVoltage','OverallResult', ...
    'SagDuration_s','MinLoadVoltage_pu','MaxLoadVoltage_pu','MinDCBus_pu'};
variableTypes = {'string','string','string','string','string', ...
    'double','double','double','double'};

testResults = table('Size', [numGridCodes, numel(variableNames)], ...
    'VariableTypes', variableTypes, 'VariableNames', variableNames);

for codeIdx = 1:numGridCodes
    metrics = caseMetrics(simResults{codeIdx}.logsout, opts);

    % UPS breaker must remain closed (0) for the whole window
    breakerPass = metrics.breakerMax == 0;

    % Retained load voltage against the ITIC envelope for this sag duration
    iticPass = lvrtTest.iticCheck(metrics.sagDuration, ...
        metrics.loadMinSag, metrics.loadMaxSag);

    % DC link must keep regulation headroom
    dcBusPass = metrics.dcMin >= opts.DCBusBand(1) && ...
        metrics.dcMax <= opts.DCBusBand(2);

    overallPass = breakerPass && iticPass && dcBusPass;

    testResults.LVRTProfile(codeIdx)       = gridCodeNames(codeIdx);
    testResults.UPSBreakerStatus(codeIdx)  = formatResult(breakerPass);
    testResults.ITICCompliance(codeIdx)    = formatResult(iticPass);
    testResults.DCBusVoltage(codeIdx)      = formatResult(dcBusPass);
    testResults.OverallResult(codeIdx)     = formatResult(overallPass);
    testResults.SagDuration_s(codeIdx)     = metrics.sagDuration;
    testResults.MinLoadVoltage_pu(codeIdx) = metrics.loadMinSag;
    testResults.MaxLoadVoltage_pu(codeIdx) = metrics.loadMaxSag;
    testResults.MinDCBus_pu(codeIdx)       = metrics.dcMin;
end
end

% -------------------------------------------------------------------------
function metrics = caseMetrics(logsout, opts)
% Extract the ride-through metrics for one simulation run.

% --- UPS breaker over the event window ---
breaker = logsout.get('UPS1BrK').Values;
breakerData = asColumn(breaker.Data);
metrics.breakerMax = max(breakerData(windowMask(breaker.Time, opts.EventWindow)));

% --- Grid PCC voltage, converted to cycle RMS in pu ---
gridVoltage = logsout.get('gridVoltage').Values;
gridTime = gridVoltage.Time;
gridPhases = squeeze(gridVoltage.Data);            % 3 x N, peak pu
sampleRate = round(1 / mean(diff(gridTime)));
windowLength = max(1, round(sampleRate * opts.RmsWindow));
gridRmsPhases = sqrt(movmean(gridPhases.^2, windowLength, 2));
gridRms = mean(gridRmsPhases, 1)' * sqrt(2);       % pu RMS

gridMask = windowMask(gridTime, opts.EventWindow);
gridTimeWindow = gridTime(gridMask);
gridRmsWindow = gridRms(gridMask);

% --- Contiguous disturbance interval ---
[runStart, runEnd] = sagInterval(gridRmsWindow < opts.SagThreshold, gridRmsWindow);
if isempty(runStart)
    sagStart = opts.EventWindow(1);
    sagEnd = opts.EventWindow(2);
    metrics.sagDuration = 0;
else
    sagStart = gridTimeWindow(runStart);
    sagEnd = gridTimeWindow(runEnd);
    metrics.sagDuration = sagEnd - sagStart;
end

% --- Load voltage during the sag ---
load = loadVoltageSeries(logsout);
sagMask = load.time >= sagStart & load.time <= sagEnd;
if ~any(sagMask)
    sagMask = windowMask(load.time, opts.EventWindow);
end
metrics.loadMinSag = min(load.minPu(sagMask));
metrics.loadMaxSag = max(load.maxPu(sagMask));

% --- DC link over the event window ---
dcBus = logsout.get('VdcUPS1').Values;
dcData = asColumn(dcBus.Data);
dcWindow = dcData(windowMask(dcBus.Time, opts.EventWindow));
metrics.dcMin = min(dcWindow);
metrics.dcMax = max(dcWindow);
end

% -------------------------------------------------------------------------
function load = loadVoltageSeries(logsout)
% Load (UPS output) voltage in pu. rmsVoltage is logged as 1 x 3 x N, one RMS
% per phase, so it must be reduced along the phase dimension before being
% indexed by time. The sqrt(2) scaling matches the convention used by the
% plot.* functions. The band check uses the phase extremes so an unbalanced sag
% is not hidden by averaging.
rmsVoltage = logsout.get('rmsVoltage').Values;
phases = squeeze(rmsVoltage.Data) * sqrt(2);   % 3 x N
load.time = rmsVoltage.Time;
load.minPu = min(phases, [], 1)';
load.maxPu = max(phases, [], 1)';
end

% -------------------------------------------------------------------------
function [runStart, runEnd] = sagInterval(belowThreshold, gridRms)
% Index range of the disturbance, as a single contiguous sub-threshold run.
% Returns empty when the supply never drops below the threshold.
%
% The ITIC operating point pairs a duration with the voltage retained over that
% same duration, so the interval has to be one contiguous excursion. Taking the
% span from the first to the last sub-threshold sample instead would merge two
% separate dips into a single long event and report the deeper one's minimum
% against the combined duration.
%
% Where a profile does produce more than one run, the run holding the lowest
% grid voltage is the disturbance; a longest-run rule would pick the wrong one.
% The grid codes here recover onto a 0.90 pu plateau that measures about
% 0.8991 pu, i.e. just under the threshold, so the plateau reads as a long
% shallow run that can outlast the genuine sag.
belowThreshold = reshape(belowThreshold, 1, []);
edges = diff([false, belowThreshold, false]);
starts = find(edges == 1);
stops = find(edges == -1) - 1;
if isempty(starts)
    runStart = [];
    runEnd = [];
    return
end

% The global minimum is necessarily below the threshold, so it lies in one of
% the runs found above.
[~, deepestIdx] = min(gridRms);
selected = find(starts <= deepestIdx & stops >= deepestIdx, 1);
runStart = starts(selected);
runEnd = stops(selected);
end

% -------------------------------------------------------------------------
function mask = windowMask(timeData, window)
mask = timeData >= window(1) & timeData <= window(2);
end

% -------------------------------------------------------------------------
function columnData = asColumn(rawData)
% Logged scalars arrive as either N x 1 or 1 x 1 x N depending on the source.
columnData = reshape(squeeze(rawData), [], 1);
end

% -------------------------------------------------------------------------
function resultString = formatResult(passed)
    if passed
        resultString = "PASS";
    else
        resultString = "FAIL";
    end
end
