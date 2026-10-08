function rampRateCompliance(simOut, rampLimit, timeRange)
%RAMPRATECOMPLIANCE Plot grid power ramp rate vs utility spec limits.
%
%   hsplot.rampRateCompliance(simOut, rampLimit) plots dP/dt against rampLimit
%   (MW/s). The limit is utility-specific and must be provided by the user.
%
%   hsplot.rampRateCompliance(simOut, rampLimit, [tStart tStop]) sets window.
%
%   The ramp rate limit represents the utility time-domain specification
%   (Choukse et al. [5], Sec. III-A): maximum permitted rate of change in
%   power demand. Actual values vary by utility and region — there is no
%   universal default.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    rampLimit (1,1) double
    timeRange (1,2) double = [2.5 inf]
end

pGrid_ts = simOut.logsout.get('pGrid').Values;
t = pGrid_ts.Time;
pGrid = double(pGrid_ts.Data);

tStart = max(timeRange(1), t(1));
tStop = min(timeRange(2), t(end));
idx = t >= tStart & t <= tStop;
t_active = t(idx);
pGrid_active = pGrid(idx);

% Compute ramp rate (MW/s) by resampling to 100ms intervals
% (matches utility SCADA/telemetry granularity and paper's monitoring interval)
dt_ramp = 0.100;
t_ramp_vec = (t_active(1):dt_ramp:t_active(end))';
pGrid_resampled = interp1(t_active, pGrid_active, t_ramp_vec, 'linear');
rampRate = diff(pGrid_resampled) / dt_ramp;  % MW/s
t_ramp = t_ramp_vec(1:end-1) + dt_ramp/2;

% Violation detection
violUp = rampRate > rampLimit;
violDown = rampRate < -rampLimit;
pctViolation = 100 * sum(violUp | violDown) / length(rampRate);

% Downsample for plotting
maxPts = 3000;
[tDs, rrDs] = hsplot.utils.downsample(t_ramp, maxPts, rampRate);

fig = figure('Name', 'Ramp Rate Compliance');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 1200 500]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panel 1: Ramp rate time series with limits
nexttile;
hold on;
fill([tDs(1); tDs(:); tDs(end)], [0; rrDs(:); 0], ...
    [0.00 0.45 0.74], 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs, rrDs, 'Color', [0.00 0.45 0.74], 'LineWidth', 0.8);
yline(rampLimit, '-', 'Color', [0.8 0 0], 'LineWidth', 1.5, 'Label', sprintf('+%.0f MW/s limit', rampLimit));
yline(-rampLimit, '-', 'Color', [0.8 0 0], 'LineWidth', 1.5, 'Label', sprintf('-%.0f MW/s limit', rampLimit));
yline(0, ':k', 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Ramp Rate (MW/s)');
title(sprintf('Grid Power Ramp Rate (violations: %.1f%% of time)', pctViolation));
xlim([tDs(1) tDs(end)]);
grid on; hold off;

% Panel 2: Histogram of ramp rates
nexttile;
hold on;
edges = linspace(min(rampRate), max(rampRate), 80);
histogram(rampRate, edges, 'FaceColor', [0.00 0.45 0.74], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7, 'Normalization', 'probability');
xline(rampLimit, '-', 'Color', [0.8 0 0], 'LineWidth', 1.5);
xline(-rampLimit, '-', 'Color', [0.8 0 0], 'LineWidth', 1.5);
xlabel('Ramp Rate (MW/s)'); ylabel('Probability');
title(sprintf('Ramp Rate Distribution (max: +%.1f / %.1f MW/s)', ...
    max(rampRate), min(rampRate)));
grid on; hold off;

sgtitle(sprintf('Utility Ramp Rate Compliance (spec: \\pm%.0f MW/s)', rampLimit), 'FontSize', 12);
end
