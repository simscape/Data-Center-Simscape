function swingMetrics = gridPowerSwings(simOut, timeRange)
%GRIDPOWERSWINGS Analyze and plot grid power oscillations from AI training workloads.
%
%   hsplot.gridPowerSwings(simOut) plots time-domain power swings and FFT
%   frequency spectrum with critical grid frequency bands highlighted.
%
%   hsplot.gridPowerSwings(simOut, [tStart tStop]) analyzes a specific window.
%
%   metrics = hsplot.gridPowerSwings(...) returns a struct with swing analysis.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    timeRange (1,2) double = [2.5 inf]
end

pGrid_ts = simOut.logsout.get('pGrid').Values;
pLoad_ts = simOut.logsout.get('pLoad').Values;

t = pGrid_ts.Time;
pGrid = double(pGrid_ts.Data);
pLoad = double(pLoad_ts.Data);

tStart = max(timeRange(1), t(1));
tStop = min(timeRange(2), t(end));
idx = t >= tStart & t <= tStop;
t_active = t(idx);
pGrid_active = pGrid(idx);
pLoad_active = pLoad(idx);

% --- FFT computation ---
dt_resample = 1e-3;
t_uniform = (t_active(1):dt_resample:t_active(end))';
pGrid_uniform = interp1(t_active, pGrid_active, t_uniform, 'linear');
pGrid_ac = pGrid_uniform - mean(pGrid_uniform);

Nfft = length(pGrid_ac);
Y = fft(pGrid_ac);
f = (0:Nfft-1)' / (Nfft * dt_resample);
P1 = abs(Y(1:floor(Nfft/2)+1)) / Nfft;
P1(2:end-1) = 2*P1(2:end-1);
f1 = f(1:floor(Nfft/2)+1);

fMask = f1 >= 0.1 & f1 <= 20;
f_band = f1(fMask);
P_band = P1(fMask);

% --- Metrics ---
E_total = sum(P_band.^2);
E_sub1 = sum(P_band(f_band < 1).^2);
E_1to2p5 = sum(P_band(f_band >= 1 & f_band <= 2.5).^2);
E_7plus = sum(P_band(f_band >= 7).^2);

[P_sorted, sortIdx] = sort(P_band, 'descend');
f_sorted = f_band(sortIdx);

% --- Ramp rate computation (dP/dt in MW/s) ---
% Resample to 100ms intervals (utility SCADA/telemetry granularity)
dt_ramp = 0.100;
t_ramp_vec = (t_active(1):dt_ramp:t_active(end))';
pGrid_resampled = interp1(t_active, pGrid_active, t_ramp_vec, 'linear');
rampRate_smooth = diff(pGrid_resampled) / dt_ramp;  % MW/s at 100ms resolution

swingMetrics.pGrid_mean = mean(pGrid_active);
swingMetrics.pGrid_std = std(pGrid_active);
swingMetrics.pGrid_pp = max(pGrid_active) - min(pGrid_active);
swingMetrics.swing_pct = 100 * swingMetrics.pGrid_pp / swingMetrics.pGrid_mean;
swingMetrics.dominant_freq = f_sorted(1);
swingMetrics.dominant_mag = P_sorted(1);
swingMetrics.energy_sub1Hz = 100 * E_sub1 / E_total;
swingMetrics.energy_1to2p5Hz = 100 * E_1to2p5 / E_total;
swingMetrics.energy_7plusHz = 100 * E_7plus / E_total;
swingMetrics.top5_freq = f_sorted(1:min(5,end));
swingMetrics.top5_mag = P_sorted(1:min(5,end));
swingMetrics.max_ramp_rate = max(abs(rampRate_smooth));
swingMetrics.ramp_up_max = max(rampRate_smooth);
swingMetrics.ramp_down_max = min(rampRate_smooth);

% --- Figure ---
fig = figure('Name', 'Grid Power Swing Analysis');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 50 1300 750]);
end
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panel 1: Time-domain grid power
nexttile([1 2]);
hold on;
[tDs, pGDs, pLDs] = hsplot.utils.downsample(t_active, 2000, pGrid_active, pLoad_active);
plot(tDs, pGDs, 'Color', [0.00 0.45 0.74], 'LineWidth', 1);
plot(tDs, pLDs, 'Color', [0.85 0.33 0.10], 'LineWidth', 0.8);
yline(mean(pGrid_active), '--k', 'LineWidth', 1);
yline(max(pGrid_active), ':', 'Color', [0.8 0 0], 'LineWidth', 0.7);
yline(min(pGrid_active), ':', 'Color', [0.8 0 0], 'LineWidth', 0.7);
xlabel('Time (s)'); ylabel('Power (MW)');
title(sprintf('Grid Power Swings (pp = %.1f MW, %.0f%% of mean)', ...
    swingMetrics.pGrid_pp, swingMetrics.swing_pct));
legend('Grid Power (13.8 kV AC)', 'Load Power (800V DC)', 'Location', 'northeast');
xlim([tDs(1) tDs(end)]); grid on; hold off;

% Panel 2: FFT with training harmonics
nexttile;
hold on;
fMax = 15;
fIdx = f_band <= fMax;
stem(f_band(fIdx), P_band(fIdx), 'filled', 'MarkerSize', 3, ...
    'Color', [0.00 0.45 0.74], 'LineWidth', 0.8);
xline(1.25, '--r', 'LineWidth', 0.8);
xline(2.50, '--r', 'LineWidth', 0.8);
xline(3.75, '--r', 'LineWidth', 0.8);
text(1.25, max(P_band(fIdx))*0.95, ' 1.25 Hz', 'Color', 'r', 'FontSize', 8);
xlabel('Frequency (Hz)'); ylabel('Magnitude (MW)');
title('FFT of Grid Power (training step harmonics)');
xlim([0 fMax]); grid on; hold off;

% Panel 3: FFT with critical bands
nexttile;
hold on;
patch([0.1 1 1 0.1], [0 0 1.15 1.15], [1 0.8 0.8], ...
    'FaceAlpha', 0.25, 'EdgeColor', 'none');
patch([1 2.5 2.5 1], [0 0 1.15 1.15], [1 1 0.7], ...
    'FaceAlpha', 0.25, 'EdgeColor', 'none');
patch([7 15 15 7], [0 0 1.15 1.15], [0.7 1 0.7], ...
    'FaceAlpha', 0.25, 'EdgeColor', 'none');
P_norm = P_band(fIdx) / max(P_band(fIdx));
bar(f_band(fIdx), P_norm, 'FaceColor', [0.2 0.2 0.6], 'EdgeColor', 'none', 'BarWidth', 1);
xlabel('Frequency (Hz)'); ylabel('Normalized Magnitude');
title('Critical Grid Frequency Bands');
legend({sprintf('<1 Hz: Transmission (%.0f%%)', swingMetrics.energy_sub1Hz), ...
    sprintf('1-2.5 Hz: Inter-plant (%.0f%%)', swingMetrics.energy_1to2p5Hz), ...
    sprintf('7+ Hz: Shaft torsional (%.0f%%)', swingMetrics.energy_7plusHz), ...
    'FFT'}, 'Location', 'northeast', 'FontSize', 8);
xlim([0 fMax]); ylim([0 1.15]); grid on; hold off;

sgtitle('Power Stabilization Analysis — Grid Impact of AI Training Workloads', 'FontSize', 12);
end
