function bbuMetrics(simOut_noBBU, simOut_BBU, timeRange)
%BBUMETRICS Bar chart comparing DC bus voltage metrics with/without BBU.
%
%   hsplot.bbuMetrics(simOut_noBBU, simOut_BBU) compares Vdc std, peak-peak,
%   max dip, and max overshoot as grouped bar charts.
%
%   hsplot.bbuMetrics(..., [tStart tStop]) limits analysis to a time window.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_noBBU
    simOut_BBU
    timeRange (1,2) double = [1 inf]
end

Vdc_no = simOut_noBBU.logsout.get('Vdc800V').Values;
Vdc_yes = simOut_BBU.logsout.get('Vdc800V').Values;

tStart = max(timeRange(1), Vdc_no.Time(1));
tStop = min(timeRange(2), Vdc_no.Time(end));

[~, idx_no] = hsplot.utils.sliceTime(Vdc_no.Time, tStart, tStop);
[~, idx_yes] = hsplot.utils.sliceTime(Vdc_yes.Time, tStart, tStop);
vNo = double(Vdc_no.Data(idx_no));
vYes = double(Vdc_yes.Data(idx_yes));

metrics_no = [std(vNo), max(vNo)-min(vNo), 800-min(vNo), max(vNo)-800];
metrics_yes = [std(vYes), max(vYes)-min(vYes), 800-min(vYes), max(vYes)-800];

metricNames = {'Std Dev (V)', 'Peak-Peak (V)', 'Max Dip (V)', 'Max Overshoot (V)'};
improvement = (metrics_no - metrics_yes) ./ metrics_no * 100;

fig = figure('Name', 'BBU Metrics');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 800 450]);
end
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Bar chart
nexttile;
barData = [metrics_no; metrics_yes]';
b = bar(barData);
b(1).FaceColor = [0.85 0.33 0.10];
b(2).FaceColor = [0.00 0.45 0.74];
set(gca, 'XTickLabel', metricNames);
ylabel('Voltage (V)');
title('DC Bus Voltage Quality Metrics');
legend('No BBU', 'With BBU', 'Location', 'northwest');
grid on;

% Improvement percentage
nexttile;
hold on;
colors = zeros(4, 3);
for k = 1:4
    if improvement(k) >= 0
        colors(k,:) = [0.47 0.67 0.19];
    else
        colors(k,:) = [0.85 0.33 0.10];
    end
end
bh = bar(improvement);
bh.FaceColor = 'flat';
bh.CData = colors;
set(gca, 'XTickLabel', metricNames);
ylabel('Improvement (%)');
title('BBU Impact (% change)');
yline(0, '-', 'Color', [0.5 0.5 0.5]);
grid on;
hold off;

sgtitle(sprintf('BBU Effect Summary (%.1fs - %.1fs)', tStart, tStop), 'FontSize', 14);

fprintf('\n  BBU Metrics Summary (%.1fs - %.1fs):\n', tStart, tStop);
fprintf('  %-20s  No BBU    With BBU  Improvement\n', 'Metric');
fprintf('  %-20s  --------  --------  -----------\n', '------');
for k = 1:4
    fprintf('  %-20s  %7.2f   %7.2f   %+.1f%%\n', ...
        metricNames{k}, metrics_no(k), metrics_yes(k), improvement(k));
end
fprintf('\n');
end
