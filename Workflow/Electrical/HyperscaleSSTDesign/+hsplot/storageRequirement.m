function storageRequirement(simOut, timeRange)
%STORAGEREQUIREMENT Plot energy storage needed to flatten grid power swings.
%
%   hsplot.storageRequirement(simOut) shows what a rack-level BESS would need
%   to absorb to stabilize the grid-side waveform (Paper [5], Fig. 7).
%
%   hsplot.storageRequirement(simOut, [tStart tStop]) analyzes a specific window.
%
%   Computes: moving-average target, required charge/discharge power,
%   cumulative energy capacity, and SOC swing.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
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

% Moving average as the "ideal flat" target (window = 2 training steps)
dt_med = median(diff(t_active));
avgWindow = round(1.6 / dt_med);  % 1.6s = 2 training steps
pGrid_smooth = movmean(pGrid_active, avgWindow);

% Storage power = difference between actual and smoothed
pStorage = pGrid_active - pGrid_smooth;  % positive = charge, negative = discharge

% Cumulative energy (integrate power over time) in MJ and kWh
dt_vec = [0; diff(t_active)];
energy_cumulative = cumsum(pStorage .* dt_vec);  % MW*s = MJ
energy_cumulative_kWh = energy_cumulative / 3.6;  % MJ -> kWh

% Required capacity = total swing of cumulative energy
capacity_MJ = max(energy_cumulative) - min(energy_cumulative);
capacity_kWh = capacity_MJ / 3.6;
peak_charge_MW = max(pStorage);
peak_discharge_MW = min(pStorage);

% SOC simulation (assume storage sized to exactly this capacity)
if capacity_MJ > 0
    soc = 50 + 100 * (energy_cumulative - min(energy_cumulative)) / capacity_MJ;
else
    soc = 50 * ones(size(energy_cumulative));
end

maxPts = 2000;
[tDs, pGDs, pSmoothDs, pStorDs, socDs] = hsplot.utils.downsample( ...
    t_active, maxPts, pGrid_active, pGrid_smooth, pStorage, soc);

fig = figure('Name', 'Energy Storage Requirement');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 50 1300 700]);
end
tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panel 1: Original vs smoothed grid power
nexttile([1 2]);
hold on;
plot(tDs, pGDs, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.8);
plot(tDs, pSmoothDs, 'Color', [0.00 0.45 0.74], 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Power (MW)');
title('Grid Power: Actual vs Smoothed (storage target)');
legend('Actual Grid Power', 'Smoothed (2-step moving avg)', 'Location', 'northeast');
xlim([tDs(1) tDs(end)]); grid on; hold off;

% Panel 2: Storage charge/discharge power
nexttile;
hold on;
fill([tDs(1); tDs(:); tDs(end)], [0; pStorDs(:); 0], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
plot(tDs, pStorDs, 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
yline(0, ':k');
xlabel('Time (s)'); ylabel('Power (MW)');
title(sprintf('Storage Power (peak: +%.1f / %.1f MW)', peak_charge_MW, peak_discharge_MW));
xlim([tDs(1) tDs(end)]); grid on; hold off;

% Panel 3: SOC over time
nexttile;
hold on;
plot(tDs, socDs, 'Color', [0.47 0.67 0.19], 'LineWidth', 1.2);
yline(50, '--k', 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('SOC (%)');
title(sprintf('Storage SOC (capacity needed: %.1f kWh = %.2f MJ)', capacity_kWh, capacity_MJ));
ylim([0 100]);
xlim([tDs(1) tDs(end)]); grid on; hold off;

% Panel 4: Zoom into 2 training cycles
nexttile;
hold on;
zoomStart = t_active(1) + 2.0;
zoomEnd = zoomStart + 2.0;
zIdx = t_active >= zoomStart & t_active <= zoomEnd;
plot(t_active(zIdx), pGrid_active(zIdx), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
plot(t_active(zIdx), pGrid_smooth(zIdx), 'Color', [0.00 0.45 0.74], 'LineWidth', 1.5);
area_t = t_active(zIdx);
area_actual = pGrid_active(zIdx);
area_smooth = pGrid_smooth(zIdx);
fill([area_t; flipud(area_t)], [area_actual; flipud(area_smooth)], ...
    [0.85 0.33 0.10], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
xlabel('Time (s)'); ylabel('Power (MW)');
title('Zoom: Storage absorbs shaded area');
xlim([zoomStart zoomEnd]); grid on; hold off;

% Panel 5: Summary annotation
nexttile;
axis off;
textStr = { ...
    sprintf('Required Storage Capacity:'), ...
    sprintf('  %.2f MJ (%.1f kWh)', capacity_MJ, capacity_kWh), ...
    '', ...
    sprintf('Peak Charge Rate:  +%.1f MW', peak_charge_MW), ...
    sprintf('Peak Discharge Rate: %.1f MW', peak_discharge_MW), ...
    '', ...
    sprintf('SOC Swing: %.0f%% - %.0f%%', min(soc), max(soc)), ...
    '', ...
    'At 100k GPU scale (x21.7):', ...
    sprintf('  Capacity: %.0f kWh (%.1f MJ)', capacity_kWh*21.7, capacity_MJ*21.7), ...
    sprintf('  Peak rate: +%.0f / %.0f MW', peak_charge_MW*21.7, peak_discharge_MW*21.7), ...
    '', ...
    'Technology fit:', ...
    '  Supercapacitor: high power, low energy', ...
    '  Li-ion battery: moderate power, high energy', ...
    '  Hybrid (this model): both'};
text(0.05, 0.95, textStr, 'VerticalAlignment', 'top', 'FontSize', 9, ...
    'FontName', 'FixedWidth', 'Units', 'normalized');
title('Storage Sizing Summary');

sgtitle('Rack-Level Energy Storage Requirement for Power Smoothing [5, Sec. IV-C]', 'FontSize', 12);
end
