function bbuHandoff(simOut, zoomRange)
%BBUHANDOFF Plot supercap-to-battery current handoff during BBU island event.
%
%   hsplot.bbuHandoff(simOut, [tStart tStop]) shows the complementary filter
%   current sharing between supercap (HPF path) and battery (LPF path)
%   overlaid with rack DC bus voltage.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange (1,2) double = [4.0 4.2]
end

BattIref = simOut.logsout.get('BattIrefTrain').Values;
BattIrefBatt = simOut.logsout.get('BattIrefBattTrain').Values;
VdcTrain = simOut.logsout.get('VdcTrain').Values;

% Slice to zoom range
[tSc, idxSc] = hsplot.utils.sliceTime(BattIref.Time, zoomRange(1), zoomRange(2));
iSc = double(BattIref.Data(idxSc));

[tBt, idxBt] = hsplot.utils.sliceTime(BattIrefBatt.Time, zoomRange(1), zoomRange(2));
iBt = double(BattIrefBatt.Data(idxBt));

[tV, idxV] = hsplot.utils.sliceTime(VdcTrain.Time, zoomRange(1), zoomRange(2));
vdc = double(VdcTrain.Data(idxV));

maxPts = 3000;
[tDsSc, iDsSc] = hsplot.utils.downsample(tSc, maxPts, iSc);
[tDsBt, iDsBt] = hsplot.utils.downsample(tBt, maxPts, iBt);
[tDsV, vDsV] = hsplot.utils.downsample(tV, maxPts, vdc);

fig = figure('Name', 'BBU Current Handoff');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 80 1200 450]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panel 1: Current sharing
nexttile;
hold on;
fill([tDsSc(1); tDsSc(:); tDsSc(end)], [0; iDsSc(:); 0], ...
    [0.93 0.69 0.13], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([tDsBt(1); tDsBt(:); tDsBt(end)], [0; iDsBt(:); 0], ...
    [0.00 0.45 0.74], 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
p1 = plot(tDsSc, iDsSc, 'LineWidth', 1.5, 'Color', [0.93 0.69 0.13]);
p2 = plot(tDsBt, iDsBt, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');

% Find crossover point
iScInterp = interp1(tDsSc, iDsSc, tDsBt, 'linear', 0);
crossIdx = find(abs(iDsBt) > abs(iScInterp) & iDsBt ~= 0, 1, 'first');
if ~isempty(crossIdx)
    xline(tDsBt(crossIdx), ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, ...
        'Label', sprintf('Crossover %.0f ms', (tDsBt(crossIdx)-zoomRange(1))*1000), ...
        'HandleVisibility', 'off');
end

xlabel('Time (s)'); ylabel('Current (A)');
title('Complementary Filter Current Sharing (Training Rack BBU)');
legend([p1 p2], {'SuperCap (HPF — transient)', 'Battery (LPF — steady-state)'}, ...
    'Location', 'southeast');
xlim(zoomRange); grid on; hold off;

% Panel 2: Rack voltage
nexttile;
hold on;
fill([tDsV(1) tDsV(end) tDsV(end) tDsV(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.12, 'EdgeColor', 'none', ...
    'DisplayName', '\pm5% Band (760-840 V)');
plot(tDsV, vDsV, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10], ...
    'DisplayName', 'Training Rack V_{dc}');
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Rack DC Bus Voltage During Island');
legend('Location', 'southeast');
xlim(zoomRange); grid on; hold off;

sgtitle('BBU Handoff: SuperCap \rightarrow Battery', 'FontSize', 13);
end
