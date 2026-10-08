function iticCompliance(simOut, faultTime)
%ITICCOMPLIANCE Plot DC bus load voltage against ITIC/CBEMA envelope.
%
%   hsplot.iticCompliance(simOut, faultTime) assesses whether the Training
%   Rack DC bus voltage remains within the ITIC/CBEMA voltage tolerance
%   envelope during a breaker trip or fault event.
%
%   The load voltage is normalized to per-unit (800 V = 1.0 pu).
%   The disturbance duration is measured from faultTime to end of sim.
%
%   Inputs:
%     simOut    - Simulink.SimulationOutput from HyperscalarDataCenter
%     faultTime - scalar, time (s) when the disturbance begins

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    faultTime (1,1) double
end

Vnom = 800;
maxPts = 2000;

VdcTrain = simOut.logsout.get('VdcTrain').Values;
tAll = VdcTrain.Time;
vAll = double(VdcTrain.Data);

% Normalize to per-unit
vPu = vAll / Vnom;

% Post-fault segment
[tPost, idxPost] = hsplot.utils.sliceTime(tAll, faultTime, tAll(end));
vPost = vPu(idxPost);

distDuration = tPost(end) - tPost(1);
vMin = min(vPost);
vMax = max(vPost);
vMean = mean(vPost);

% Full timeline for left panel
[tDs, vDs] = hsplot.utils.downsample(tAll, maxPts, vPu);

% ITIC envelope breakpoints (per ITI/CBEMA curve, IEEE Std 1100)
tIticLower = [1e-5  0.02  0.0201  0.5  0.501  10];
vIticLower = [0.00  0.00  0.70    0.70 0.80   0.80];
tIticUpper = [1e-5  0.001  0.003  0.5  0.501  10];
vIticUpper = [5.00  2.00   1.40   1.20 1.10   1.10];

% ITIC pass/fail
iticLowerAtDist = interp1(tIticLower, vIticLower, distDuration, 'previous', 0.9);
iticUpperAtDist = interp1(tIticUpper, vIticUpper, distDuration, 'previous', 1.1);
iticPass = vMin >= iticLowerAtDist && vMax <= iticUpperAtDist;

% Figure
fig = figure('Name', 'ITIC/CBEMA Load Voltage Compliance', ...
    'Position', [100 80 1100 500], 'Color', 'w');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 80 1100 500]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- Panel 1: Load Voltage Timeline ---
nexttile;
hold on;
fill([tDs(1) tDs(end) tDs(end) tDs(1)], [0.95 0.95 1.05 1.05], ...
    [0.85 1 0.85], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
    'DisplayName', sprintf('\\pm5%% Band (%.0f-%.0f V)', Vnom*0.95, Vnom*1.05));
fill([faultTime tDs(end) tDs(end) faultTime], [0.9 0.9 1.12 1.12], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.06, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
xline(faultTime, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off');
plot(tDs, vDs, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74], ...
    'DisplayName', 'Training Rack DC Bus');
yline(1.0, '--', 'Color', [0.6 0.6 0.6], 'HandleVisibility', 'off');

[~, minIdx] = min(vDs(tDs >= faultTime));
tPostDs = tDs(tDs >= faultTime);
vPostDs = vDs(tDs >= faultTime);
plot(tPostDs(minIdx), vPostDs(minIdx), 'v', 'MarkerSize', 8, ...
    'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerEdgeColor', 'k', ...
    'DisplayName', sprintf('Min: %.3f pu (%.1f V)', vMin, vMin*Vnom));

text(faultTime + 0.05, 1.11, 'Breaker Trip', 'FontSize', 8, ...
    'Color', [0.3 0.3 0.3]);

grid on; box on;
xlim([tDs(1) tDs(end)]);
ylim([0.9 1.12]);
xlabel('Time (s)');
ylabel('Voltage (pu)');
title('Training Rack Load Voltage');
legend('Location', 'southwest', 'FontSize', 7);
hold off;

% --- Panel 2: ITIC/CBEMA Envelope ---
nexttile;
hold on;
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
text(0.3, 0.35, 'No Damage', 'FontSize', 8, ...
    'Color', [0.2 0.2 0.6], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.01, 1.5, 'Prohibited', 'FontSize', 8, ...
    'Color', [0.7 0 0], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.3, 0.95, 'No Interruption', 'FontSize', 8, ...
    'Color', [0 0.5 0], 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Operating point: min and max retained voltage at disturbance duration
scatter(distDuration, vMin, 100, [0 0.45 0.74], 'filled', 'v', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1, ...
    'DisplayName', sprintf('Min: %.3f pu @ %.1f s', vMin, distDuration));
scatter(distDuration, vMax, 100, [0.85 0.33 0.10], 'filled', '^', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1, ...
    'DisplayName', sprintf('Max: %.3f pu @ %.1f s', vMax, distDuration));

% Verdict
if iticPass
    verdictStr = 'PASS — within ITIC envelope';
    verdictColor = [0.13 0.55 0.13];
else
    verdictStr = 'FAIL — exceeds ITIC limit';
    verdictColor = [0.8 0 0];
end
text(0.002, 0.12, verdictStr, 'FontSize', 8, 'FontWeight', 'bold', ...
    'Color', verdictColor, 'BackgroundColor', 'w', ...
    'EdgeColor', verdictColor, 'LineWidth', 1.5, 'Margin', 3);

grid on; box on;
xlim([1e-3 10]);
ylim([0 1.7]);
xlabel('Disturbance Duration (s)');
ylabel('Retained Voltage (pu)');
title('ITIC/CBEMA Voltage Tolerance Envelope');
legend('Location', 'northeast', 'FontSize', 7);
hold off;

sgtitle(sprintf('ITIC/CBEMA Compliance — Training Rack BBU Island (%.1f s disturbance)', ...
    distDuration), 'FontSize', 12);
end
