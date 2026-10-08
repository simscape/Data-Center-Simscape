function kbalPower(simOut_kbal, simOut_nokbal, tRange, faultZoom)
%KBALPOWER Grid & load power during L-G fault: with vs without balancing (2x2).
%
%   Row 1: Full timeline — grid power + load power
%   Row 2: Fault zoom with region shading

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut_kbal
    simOut_nokbal
    tRange (1,2) double = [3.5 8]
    faultZoom (1,2) double = [3.9 4.4]
end

maxPts = 3000;
faultTime = 4.0;
clearTime = 4.1;

% --- Extract signals ---
pGrid1 = simOut_kbal.logsout.get('pGrid').Values;
pLoad1 = simOut_kbal.logsout.get('pLoad').Values;
pGrid2 = simOut_nokbal.logsout.get('pGrid').Values;
pLoad2 = simOut_nokbal.logsout.get('pLoad').Values;

% --- Full-range data ---
[tP1, idxP1] = hsplot.utils.sliceTime(pGrid1.Time, tRange(1), tRange(2));
[tP2, idxP2] = hsplot.utils.sliceTime(pGrid2.Time, tRange(1), tRange(2));
pG1 = double(pGrid1.Data(idxP1));
pG2 = double(pGrid2.Data(idxP2));
[tDsP1, pDsG1] = hsplot.utils.downsample(tP1, maxPts, pG1);
[tDsP2, pDsG2] = hsplot.utils.downsample(tP2, maxPts, pG2);

[tL1, idxL1] = hsplot.utils.sliceTime(pLoad1.Time, tRange(1), tRange(2));
[tL2, idxL2] = hsplot.utils.sliceTime(pLoad2.Time, tRange(1), tRange(2));
pL1 = double(pLoad1.Data(idxL1));
pL2 = double(pLoad2.Data(idxL2));
[tDsL1, pDsL1] = hsplot.utils.downsample(tL1, maxPts, pL1);
[tDsL2, pDsL2] = hsplot.utils.downsample(tL2, maxPts, pL2);

% --- Fault-zoom data ---
[tFG1, idxFG1] = hsplot.utils.sliceTime(pGrid1.Time, faultZoom(1), faultZoom(2));
[tFG2, idxFG2] = hsplot.utils.sliceTime(pGrid2.Time, faultZoom(1), faultZoom(2));
pFG1 = double(pGrid1.Data(idxFG1));
pFG2 = double(pGrid2.Data(idxFG2));
[tDsFG1, pDsFG1] = hsplot.utils.downsample(tFG1, maxPts, pFG1);
[tDsFG2, pDsFG2] = hsplot.utils.downsample(tFG2, maxPts, pFG2);

[tFL1, idxFL1] = hsplot.utils.sliceTime(pLoad1.Time, faultZoom(1), faultZoom(2));
[tFL2, idxFL2] = hsplot.utils.sliceTime(pLoad2.Time, faultZoom(1), faultZoom(2));
pFL1 = double(pLoad1.Data(idxFL1));
pFL2 = double(pLoad2.Data(idxFL2));
[tDsFL1, pDsFL1] = hsplot.utils.downsample(tFL1, maxPts, pFL1);
[tDsFL2, pDsFL2] = hsplot.utils.downsample(tFL2, maxPts, pFL2);

% --- Figure ---
fig = figure('Name', 'Balancing Controller — Power & Load Continuity');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [80 50 1400 600]);
end
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Row 1, Col 1: Grid power (full)
nexttile;
hold on;
plot(tDsP1, pDsG1, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
plot(tDsP2, pDsG2, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
xline(faultTime, ':', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(clearTime, ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Power (MW)');
title('Grid Power');
xlim(tRange);
legend('With Balancing', 'Without Balancing', 'Location', 'northeast');
grid on; hold off;

% Row 1, Col 2: Load power (full)
nexttile;
hold on;
plot(tDsL1, pDsL1, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
plot(tDsL2, pDsL2, 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
xline(faultTime, ':', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal');
xline(clearTime, ':', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal');
xlabel('Time (s)'); ylabel('Power (MW)');
title('Load Power (server racks)');
xlim(tRange);
legend('With Balancing', 'Without Balancing', 'Location', 'southeast');
grid on; hold off;

% Row 2, Col 1: Fault zoom — Grid power
nexttile;
hold on;
pAllG = [pDsFG1; pDsFG2];
yLimsG = [min(pAllG)-1, max(pAllG)+1];
fill([faultTime clearTime clearTime faultTime], ...
    [yLimsG(1) yLimsG(1) yLimsG(2) yLimsG(2)], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([clearTime faultZoom(2) faultZoom(2) clearTime], ...
    [yLimsG(1) yLimsG(1) yLimsG(2) yLimsG(2)], ...
    [0.85 1.0 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
yline(0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
plot(tDsFG1, pDsFG1, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDsFG2, pDsFG2, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Power (MW)');
title('Grid Power — Fault Zoom');
xlim(faultZoom); ylim(yLimsG);
legend('With Balancing', 'Without Balancing', 'Location', 'southeast');
grid on; hold off;

% Row 2, Col 2: Fault zoom — Load power (uninterrupted)
nexttile;
hold on;
pAllL = [pDsFL1; pDsFL2];
yLimsL = [min(pAllL)-0.5, max(pAllL)+0.5];
fill([faultTime clearTime clearTime faultTime], ...
    [yLimsL(1) yLimsL(1) yLimsL(2) yLimsL(2)], ...
    [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([clearTime faultZoom(2) faultZoom(2) clearTime], ...
    [yLimsL(1) yLimsL(1) yLimsL(2) yLimsL(2)], ...
    [0.85 1.0 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDsFL1, pDsFL1, 'LineWidth', 1.5, 'Color', [0.00 0.45 0.74]);
plot(tDsFL2, pDsFL2, 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
xline(faultTime, '-', 'Fault', 'Color', [0.6 0 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xline(clearTime, '-', 'Clear', 'Color', [0 0.5 0], 'LabelOrientation', 'horizontal', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Power (MW)');
title('Load Power — Fault Zoom');
xlim(faultZoom); ylim(yLimsL);
legend('With Balancing', 'Without Balancing', 'Location', 'southeast');
grid on; hold off;

sgtitle('Grid and Load Power During L-G Fault', 'FontSize', 14);
end
