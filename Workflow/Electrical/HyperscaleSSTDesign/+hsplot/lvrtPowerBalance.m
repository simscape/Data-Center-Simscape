function lvrtPowerBalance(simOut, gridCode, faultStartTime, timeRange)
%LVRTPOWERBALANCE Plot grid/BESS power with OCP LVRT range shading (2x2 full/zoom).
%
%   hsplot.lvrtPowerBalance(simOut, gridCode, faultStartTime) shows a 2x2 grid:
%     Left column:  Full simulation timeline
%     Right column: Zoomed to the LVRT event window
%     Top row:      Grid power (SST contribution)
%     Bottom row:   BESS power (supplements during sag)
%
%   OCP LVRT ranges shown as distinct color shading:
%     Range 2 (Vac < 0.5 pu): SST freezes, BESS provides 100% load power
%     Range 1 (0.5 <= Vac < 0.9 pu): SST resumes, BESS supplements
%     Normal  (Vac >= 0.9 pu): SST takes over completely, BESS standby

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    gridCode struct
    faultStartTime (1,1) double
    timeRange (1,2) double = [1 inf]
end

maxPts = 2000;

% Extract signals
pGrid = simOut.logsout.get('pGrid').Values;
pBESS = simOut.logsout.get('pBESSUPS').Values;

tStart = max(timeRange(1), pGrid.Time(1));
tStop = min(timeRange(2), pGrid.Time(end));

% Zoom range: pre-fault through shortly after SST-only region starts
faultTime = gridCode.faultTime;
voltagePu = gridCode.voltagePu;
tAbs = faultTime + faultStartTime;
% Find where SST-only starts (>=0.9 pu), show 1s into that region
idxSstOnly = find(voltagePu >= 0.9, 1, 'first');
if ~isempty(idxSstOnly)
    zoomEnd = min(tAbs(idxSstOnly) + 1.0, tStop);
else
    zoomEnd = min(tAbs(end) + 1.0, tStop);
end
zoomStart = faultStartTime - 0.5;

% --- Full-range data ---
[tPf, idxPf] = hsplot.utils.sliceTime(pGrid.Time, tStart, tStop);
pGf = double(pGrid.Data(idxPf));
[tDsPf, pDsGf] = hsplot.utils.downsample(tPf, maxPts, pGf);

[tBf, idxBf] = hsplot.utils.sliceTime(pBESS.Time, tStart, tStop);
pBf = double(pBESS.Data(idxBf));
[tDsBf, pDsBf] = hsplot.utils.downsample(tBf, maxPts, pBf);

% --- Zoomed data ---
[tPz, idxPz] = hsplot.utils.sliceTime(pGrid.Time, zoomStart, zoomEnd);
pGz = double(pGrid.Data(idxPz));
[tDsPz, pDsGz] = hsplot.utils.downsample(tPz, maxPts, pGz);

[tBz, idxBz] = hsplot.utils.sliceTime(pBESS.Time, zoomStart, zoomEnd);
pBz = double(pBESS.Data(idxBz));
[tDsBz, pDsBz] = hsplot.utils.downsample(tBz, maxPts, pBz);

% Range thresholds (OCP)
vRange2 = 0.5;   % Below: BESS only (SST frozen)
vNormal = 0.9;   % Above: SST only

% Build time intervals for each range
range2_intervals = {};
range1_intervals = {};
normal_intervals = {};

for k = 1:numel(voltagePu)
    if k < numel(voltagePu)
        tSeg = [tAbs(k), tAbs(k+1)];
    else
        tSeg = [tAbs(k), tStop];
    end
    if voltagePu(k) < vRange2
        range2_intervals{end+1} = tSeg; %#ok<AGROW>
    elseif voltagePu(k) < vNormal
        range1_intervals{end+1} = tSeg; %#ok<AGROW>
    else
        normal_intervals{end+1} = tSeg; %#ok<AGROW>
    end
end

% Colors
colRange2 = [0.85 0.33 0.10];
colRange1 = [0.93 0.69 0.13];
colNormal = [0.47 0.67 0.19];

% Figure
fig = figure('Name', 'LVRT Power Balance');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [50 30 1300 700]);
end
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- (1,1) Grid Power — Full ---
nexttile;
hold on;
plot(tDsPf, pDsGf, 'LineWidth', 1.5, 'Color', [0.47 0.67 0.19], ...
    'DisplayName', 'Grid Power (SST)');
yline(0, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, [zoomStart zoomEnd]);

xlabel('Time (s)'); ylabel('Power (MW)');
title('Grid Power — Full Timeline');
legend('Location', 'southeast', 'FontSize', 7);
xlim([tDsPf(1) tDsPf(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(pDsGf);
ylim([min(yLo, -0.5) yHi]);
grid on; hold off;

% --- (1,2) Grid Power — Zoom ---
nexttile;
hold on;
shadeRanges(gca, range2_intervals, colRange2, 0.25, 'BESS Only (<0.5 pu)');
shadeRanges(gca, range1_intervals, colRange1, 0.18, 'BESS + SST (0.5-0.9 pu)');
shadeRanges(gca, normal_intervals, colNormal, 0.18, 'SST Only (\geq0.9 pu)');

plot(tDsPz, pDsGz, 'LineWidth', 2, 'Color', [0.47 0.67 0.19], ...
    'DisplayName', 'Grid Power (SST)');
yline(0, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');

xlabel('Time (s)'); ylabel('Power (MW)');
title('Grid Power — LVRT Event Zoom');
legend('Location', 'southeast', 'FontSize', 7);
xlim([zoomStart zoomEnd]);
[yLo, yHi] = hsplot.utils.autoMargin(pDsGz);
ylim([min(yLo, -0.5) yHi]);
grid on; hold off;

% --- (2,1) BESS Power — Full ---
nexttile;
hold on;
fill([tDsBf(1); tDsBf(:); tDsBf(end)], [0; pDsBf(:); 0], ...
    [0.49 0.18 0.56], 'FaceAlpha', 0.12, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
plot(tDsBf, pDsBf, 'LineWidth', 1.5, 'Color', [0.49 0.18 0.56], ...
    'DisplayName', 'BESS Power');
yline(0, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
hsplot.utils.highlightZoom(gca, [zoomStart zoomEnd]);

xlabel('Time (s)'); ylabel('Power (MW)');
title('BESS Power — Full Timeline');
legend('Location', 'southeast', 'FontSize', 7);
xlim([tDsBf(1) tDsBf(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(pDsBf);
ylim([min(yLo, -1) max(yHi, 0.5)]);
grid on; hold off;

% --- (2,2) BESS Power — Zoom ---
nexttile;
hold on;
shadeRanges(gca, range2_intervals, colRange2, 0.25, 'BESS Only (<0.5 pu)');
shadeRanges(gca, range1_intervals, colRange1, 0.18, 'BESS + SST (0.5-0.9 pu)');
shadeRanges(gca, normal_intervals, colNormal, 0.18, 'SST Only (\geq0.9 pu)');

fill([tDsBz(1); tDsBz(:); tDsBz(end)], [0; pDsBz(:); 0], ...
    [0.49 0.18 0.56], 'FaceAlpha', 0.12, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
plot(tDsBz, pDsBz, 'LineWidth', 2, 'Color', [0.49 0.18 0.56], ...
    'DisplayName', 'BESS Power');
yline(0, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');

xlabel('Time (s)'); ylabel('Power (MW)');
title('BESS Power — LVRT Event Zoom');
legend('Location', 'southeast', 'FontSize', 7);
xlim([zoomStart zoomEnd]);
[yLo, yHi] = hsplot.utils.autoMargin(pDsBz);
ylim([min(yLo, -1) max(yHi, 0.5)]);
grid on; hold off;

sgtitle(sprintf('OCP LVRT Power Balance — %s (fault at t=%.1f s)', ...
    gridCode.name, faultStartTime), 'FontSize', 13);
end

function shadeRanges(ax, intervals, color, alpha, legendLabel)
    yBounds = [-1e6, 1e6];
    for k = 1:numel(intervals)
        iv = intervals{k};
        if k == 1 && ~isempty(legendLabel)
            fill(ax, [iv(1) iv(2) iv(2) iv(1)], ...
                [yBounds(1) yBounds(1) yBounds(2) yBounds(2)], ...
                color, 'FaceAlpha', alpha, 'EdgeColor', 'none', ...
                'DisplayName', legendLabel);
        else
            fill(ax, [iv(1) iv(2) iv(2) iv(1)], ...
                [yBounds(1) yBounds(1) yBounds(2) yBounds(2)], ...
                color, 'FaceAlpha', alpha, 'EdgeColor', 'none', ...
                'HandleVisibility', 'off');
        end
    end
end
