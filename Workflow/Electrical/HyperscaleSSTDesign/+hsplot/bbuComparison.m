function bbuComparison(simOut_noBBU, simOut_BBU, zoomRange, timeRange)
%BBUCOMPARISON Compare DC bus voltage and BBU current with/without BBU.
%
%   hsplot.bbuComparison(simOut_noBBU, simOut_BBU) plots voltage overlay
%   and difference with shaded fills.
%
%   hsplot.bbuComparison(simOut_noBBU, simOut_BBU, zoomRange) zooms to [tStart tStop].
%
%   hsplot.bbuComparison(..., [tStart tStop]) sets full-range limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_noBBU
    simOut_BBU
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

Vdc_no = simOut_noBBU.logsout.get('Vdc800V').Values;
Vdc_yes = simOut_BBU.logsout.get('Vdc800V').Values;

tStart = max(timeRange(1), Vdc_no.Time(1));
tStop = min(timeRange(2), Vdc_no.Time(end));

if ~isempty(zoomRange)
    tStart = zoomRange(1);
    tStop = zoomRange(2);
end

[tPlot_no, idx_no] = hsplot.utils.sliceTime(Vdc_no.Time, tStart, tStop);
[tPlot_yes, idx_yes] = hsplot.utils.sliceTime(Vdc_yes.Time, tStart, tStop);
vNo = double(Vdc_no.Data(idx_no));
vYes = double(Vdc_yes.Data(idx_yes));

maxPts = 2000;
[tDs_no, vDs_no] = hsplot.utils.downsample(tPlot_no, maxPts, vNo);
[tDs_yes, vDs_yes] = hsplot.utils.downsample(tPlot_yes, maxPts, vYes);

dip_no = 800 - min(vNo);
dip_yes = 800 - min(vYes);
overshoot_no = max(vNo) - 800;
overshoot_yes = max(vYes) - 800;

fig = figure('Name', 'BBU Comparison');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 50 1200 400]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Top: voltage overlay with band
nexttile;
hold on;
fill([tDs_no(1) tDs_no(end) tDs_no(end) tDs_no(1)], [760 760 840 840], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs_no, vDs_no, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
plot(tDs_yes, vDs_yes, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
yline(800, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('Voltage (V)');
legend(sprintf('No BBU (dip=%.1fV, overshoot=%.1fV)', dip_no, overshoot_no), ...
    sprintf('With BBU (dip=%.1fV, overshoot=%.1fV)', dip_yes, overshoot_yes), ...
    'Location', 'best');
title('800V DC Bus Voltage');
xlim([tDs_no(1) tDs_no(end)]);
grid on; hold off;

% Bottom: difference with shaded fill
nexttile;
hold on;
t_common = linspace(tStart, tStop, 2000)';
vNo_interp = interp1(Vdc_no.Time, double(Vdc_no.Data), t_common);
vYes_interp = interp1(Vdc_yes.Time, double(Vdc_yes.Data), t_common);
dV = vYes_interp - vNo_interp;

posIdx = dV >= 0;
negIdx = dV < 0;
if any(posIdx)
    tPos = t_common; dVpos = dV; dVpos(negIdx) = 0;
    fill([tPos(1); tPos(:); tPos(end)], [0; dVpos(:); 0], ...
        [0.00 0.45 0.74], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
if any(negIdx)
    tNeg = t_common; dVneg = dV; dVneg(posIdx) = 0;
    fill([tNeg(1); tNeg(:); tNeg(end)], [0; dVneg(:); 0], ...
        [0.85 0.33 0.10], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
plot(t_common, dV, 'LineWidth', 1, 'Color', [0.2 0.2 0.2]);
yline(0, '-', 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off');
xlabel('Time (s)'); ylabel('\DeltaV (V)');
title('V_{BBU} - V_{noBBU} (blue = BBU raised V, orange = BBU lowered V)');
xlim([t_common(1) t_common(end)]);
grid on; hold off;

sgtitle('BBU Comparison — 800V DC Bus', 'FontSize', 14);
end
