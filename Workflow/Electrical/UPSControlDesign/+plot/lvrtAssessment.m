function lvrtAssessment(logsout, operatorIdx, operatorName, timeRange)
% lvrtAssessment  Four-panel LVRT ride-through and ITIC compliance assessment.
%
%   plot.lvrtAssessment(logsout, operatorIdx, operatorName, timeRange)
%
%   Panel 1: PCC grid voltage RMS (actual measured disturbance)
%   Panel 2: Load voltage with nominal operating band
%   Panel 3: UPS breaker status (ride-through continuity)
%   Panel 4: ITIC/CBEMA envelope with extracted sag operating point
%
%   The ITIC operating point is extracted as:
%     x = contiguous duration below sag threshold
%     y = minimum retained RMS voltage during that interval
%   This follows the PQ analyzer method per IEEE Std 1100.
%
%   Inputs:
%     logsout      - Simulink.SimulationData.Dataset from simulation
%     operatorIdx  - grid code index (1=ERCOT, 2=RTE France, 3=Eir Grid,
%                    4=ATC, 5=AESO)
%     operatorName - string name of the grid code
%     timeRange    - [tStart tStop] event window for plotting
%
%   Example:
%     plot.lvrtAssessment(simResults{1}.logsout, 1, "ERCOT", [2.9 10])

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    operatorIdx (1,1) double
    operatorName (1,1) string
    timeRange (1,2) double
end

maxPts = 2000;

% --- Extract load voltage ---
rmsVoltage = logsout.get('rmsVoltage').Values;
rmsTime = rmsVoltage.Time;
rmsData = rmsVoltage.Data * sqrt(2);

[tPlot, timeIdx] = plot.utils.sliceTime(rmsTime, timeRange(1), timeRange(2));
rmsPlot = rmsData(timeIdx);
[tDs, rmsDs] = plot.utils.downsample(tPlot, maxPts, rmsPlot);

% --- Extract grid PCC voltage and compute RMS ---
gridVoltage = logsout.get('gridVoltage').Values;
gridTime = gridVoltage.Time;
gridRaw = squeeze(gridVoltage.Data); % 3 x N (3-phase, peak pu)
Fs = round(1 / mean(diff(gridTime)));
cycleLen = round(Fs * 0.02); % one cycle at 50 Hz
gridRms3ph = sqrt(movmean(gridRaw.^2, cycleLen, 2));
gridData = mean(gridRms3ph, 1)' * sqrt(2); % normalize to pu RMS

[tGridPlot, gridIdx] = plot.utils.sliceTime(gridTime, timeRange(1), timeRange(2));
gridPlot = gridData(gridIdx);
[tGridDs, gridDs] = plot.utils.downsample(tGridPlot, maxPts, gridPlot);

% --- Extract breaker status ---
brk = logsout.get('UPS1BrK').Values;
brkTime = brk.Time;
brkData = brk.Data;

[tBrkPlot, brkIdx] = plot.utils.sliceTime(brkTime, timeRange(1), timeRange(2));
brkPlot = brkData(brkIdx);

% --- Characterize grid disturbance duration ---
sagThreshold = 0.9;
gridBelowIdx = find(gridPlot < sagThreshold);
if ~isempty(gridBelowIdx)
    distStart = tGridPlot(gridBelowIdx(1));
    distEnd = tGridPlot(gridBelowIdx(end));
    distDuration = distEnd - distStart;
else
    distStart = timeRange(1);
    distEnd = timeRange(2);
    distDuration = 0;
end

% --- Load voltage during disturbance window ---
distMask = tPlot >= distStart & tPlot <= distEnd;
loadDuringDist = rmsPlot(distMask);
loadMinDist = min(loadDuringDist);
loadMaxDist = max(loadDuringDist);
loadMeanDist = mean(loadDuringDist);

% --- ITIC envelope (per ITI/CBEMA curve, IEEE Std 1100) ---
% Lower: 0% for <=20ms, 70% to 0.5s, 80% to 10s, 90% steady state
tIticLower = [1e-5  0.02  0.0201  0.5  0.501  10];
vIticLower = [0.00  0.00  0.70    0.70 0.80   0.80];
% Upper: 500% instantaneous, 200% at 1ms, 140% at 3ms, 120% to 0.5s, 110% steady state
tIticUpper = [1e-5  0.001  0.003  0.5  0.501  10];
vIticUpper = [5.00  2.00   1.40   1.20 1.10   1.10];

% --- ITIC pass/fail ---
iticLowerAtDist = interp1(tIticLower, vIticLower, distDuration, 'previous', 0.9);
iticUpperAtDist = interp1(tIticUpper, vIticUpper, distDuration, 'previous', 1.1);
iticPass = loadMinDist >= iticLowerAtDist && loadMaxDist <= iticUpperAtDist;

% Minimum load voltage
[minV, minIdx] = min(rmsDs);

% =====================================================================
% Single figure, 2x2 panels
% =====================================================================
figure('Name', sprintf('LVRT Assessment — %s', operatorName), ...
    'Position', [100 50 1200 700], 'Color', 'w');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- Panel 1: Grid PCC Voltage ---
nexttile
hold on
% Shade disturbance window
if distDuration > 0
    fill([distStart distEnd distEnd distStart], [0 0 1.2 1.2], ...
        [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', ...
        'HandleVisibility', 'off');
    xline(distStart, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    xline(distEnd, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    text((distStart + distEnd)/2, 1.14, 'Grid Disturbance', ...
        'FontSize', 7, 'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
end
plot(tGridDs, gridDs, 'LineWidth', 1.8, 'Color', [0.85 0.33 0.10], ...
    'DisplayName', 'Grid PCC Voltage (RMS)');
yline(1.0, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.8, ...
    'HandleVisibility', 'off');
grid on; box on
xlim(timeRange);
ylim([0 1.2]);
xlabel('Time (s)')
ylabel('Voltage (pu)')
title(sprintf('Grid PCC Voltage — %s', operatorName))

% --- Panel 2: Load Voltage ---
nexttile
hold on
% Shade disturbance window
if distDuration > 0
    fill([distStart distEnd distEnd distStart], [0.85 0.85 1.15 1.15], ...
        [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none', ...
        'HandleVisibility', 'off');
    xline(distStart, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    xline(distEnd, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    text((distStart + distEnd)/2, 1.13, 'Grid Disturbance', ...
        'FontSize', 7, 'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
end
fill([timeRange(1) timeRange(2) timeRange(2) timeRange(1)], ...
    [0.9 0.9 1.1 1.1], [0.85 1 0.85], 'FaceAlpha', 0.15, ...
    'EdgeColor', 'none', 'DisplayName', 'Nominal Operating Band');
plot(tDs, rmsDs, 'LineWidth', 2, 'Color', [0.00 0.45 0.74], ...
    'DisplayName', 'Load Voltage');
yline(1.1, '--', 'Color', [0.8 0.2 0.2], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off');
plot(tDs(minIdx), minV, 'v', 'MarkerSize', 8, ...
    'MarkerFaceColor', [0 0.45 0.74], 'MarkerEdgeColor', 'k', ...
    'HandleVisibility', 'off');
text(tDs(minIdx), minV - 0.01, sprintf('Min: %.3f pu', minV), ...
    'FontSize', 7, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Color', [0 0.35 0.6]);
grid on; box on
xlim(timeRange);
ylim([0.85 1.15]);
xlabel('Time (s)')
ylabel('Voltage (pu)')
title('Load Voltage')

% --- Panel 3: UPS Breaker Status ---
nexttile
hold on
area(tBrkPlot, brkPlot, 'FaceColor', [0.90 0.25 0.20], 'FaceAlpha', 0.4, ...
    'EdgeColor', [0.90 0.25 0.20], 'LineWidth', 1.5);
plot(tBrkPlot, brkPlot, 'LineWidth', 1.5, 'Color', [0.90 0.25 0.20]);
ylim([-0.1 1.1]);
yticks([0 1]);
yticklabels({'Closed', 'Open'});
xlim(timeRange);
grid on; box on
xlabel('Time (s)')
ylabel('Breaker')
title('UPS Breaker Status')

% --- Panel 4: ITIC/CBEMA Curve ---
nexttile
hold on
set(gca, 'XScale', 'log');

% Shaded regions
fill([tIticLower fliplr(tIticLower)], ...
    [vIticLower zeros(1, numel(tIticLower))], ...
    [0.9 0.9 1.0], 'FaceAlpha', 0.3, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
fill([tIticUpper fliplr(tIticUpper)], ...
    [vIticUpper ones(1, numel(tIticUpper))*5], ...
    [1 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
tCommon = logspace(-5, 1, 500);
vLowerInterp = interp1(tIticLower, vIticLower, tCommon, 'previous', 0.90);
vUpperInterp = interp1(tIticUpper, vIticUpper, tCommon, 'previous', 1.10);
fill([tCommon fliplr(tCommon)], [vLowerInterp fliplr(vUpperInterp)], ...
    [0.85 1 0.85], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

% Envelope lines
plot(tIticLower, vIticLower, '-', 'LineWidth', 2, 'Color', [0 0.4 0.8], ...
    'HandleVisibility', 'off');
plot(tIticUpper, vIticUpper, '-', 'LineWidth', 2, 'Color', [0.8 0 0], ...
    'HandleVisibility', 'off');

% Region labels
text(0.3, 0.35, 'No Damage', 'FontSize', 7, ...
    'Color', [0.2 0.2 0.6], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.01, 1.45, 'Prohibited', 'FontSize', 7, ...
    'Color', [0.7 0 0], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.3, 0.95, 'No Interruption', 'FontSize', 7, ...
    'Color', [0 0.5 0], 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Operating point: minimum retained voltage at disturbance duration
if distDuration > 0
    scatter(distDuration, loadMinDist, 80, [0 0.45 0.74], 'filled', 'o', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1);
    text(distDuration, loadMinDist - 0.08, ...
        sprintf('%.2f pu @ %.1f s', loadMinDist, distDuration), ...
        'FontSize', 7, 'FontWeight', 'bold', 'Color', [0 0.35 0.6], ...
        'HorizontalAlignment', 'center');
end

% Verdict
if iticPass
    verdictStr = 'PASS — within ITIC envelope';
    verdictColor = [0.13 0.55 0.13];
else
    verdictStr = 'FAIL — exceeds ITIC limit';
    verdictColor = [0.8 0 0];
end

text(0.002, 0.12, verdictStr, 'FontSize', 7, 'FontWeight', 'bold', ...
    'Color', verdictColor, 'BackgroundColor', 'w', ...
    'EdgeColor', verdictColor, 'LineWidth', 1.5, 'Margin', 3);

grid on; box on
xlim([1e-3 10]);
ylim([0 1.5]);
xlabel('Disturbance Duration (s)')
ylabel('Retained Voltage (pu)')
title('ITIC/CBEMA Voltage Tolerance Envelope')

sgtitle(sprintf('LVRT Ride-Through Assessment — %s', operatorName), ...
    'FontSize', 15);

end
