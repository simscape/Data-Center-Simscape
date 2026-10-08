function dcBusVoltage(simOut, zoomRange, timeRange)
%DCBUSVOLTAGE Plot 800V DC bus voltage with acceptable band and optional zoom.
%
%   hsplot.dcBusVoltage(simOut) plots full timeline with +-5% band.
%
%   hsplot.dcBusVoltage(simOut, zoomRange) adds a zoomed subplot.
%
%   hsplot.dcBusVoltage(simOut, zoomRange, [tStart tStop]) sets full-range limits.

% Copyright 2026 The MathWorks, Inc.

arguments
    simOut
    zoomRange double = []
    timeRange (1,2) double = [1 inf]
end

Vdc = simOut.logsout.get('Vdc800V').Values;
tStart = max(timeRange(1), Vdc.Time(1));
tStop = min(timeRange(2), Vdc.Time(end));

[tPlot, idx] = hsplot.utils.sliceTime(Vdc.Time, tStart, tStop);
vData = double(Vdc.Data(idx));
maxPts = 2000;
[tDs, vDs] = hsplot.utils.downsample(tPlot, maxPts, vData);

vNom = 800;
vBandHi = 840; % +5%
vBandLo = 760; % -5%
vOcpHi = 824;  % +3% OCP spec limit
vOcpLo = 776;  % -3% OCP spec limit

hasZoom = ~isempty(zoomRange);
numCols = 1 + hasZoom;

fig = figure('Name', 'DC Bus Voltage');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 100 900 350]);
end
tiledlayout(1, numCols, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
hold on;
fill([tDs(1) tDs(end) tDs(end) tDs(1)], [vBandLo vBandLo vBandHi vBandHi], ...
    [0.47 0.67 0.19], 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(tDs, vDs, 'LineWidth', 1, 'Color', [0.00 0.45 0.74]);
yline(vNom, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(vOcpHi, '-', 'Color', [0.8 0 0], 'LineWidth', 0.8, 'Label', '+3%', ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
yline(vOcpLo, '-', 'Color', [0.8 0 0], 'LineWidth', 0.8, 'Label', '-3%', ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
if hasZoom
    hsplot.utils.highlightZoom(gca, zoomRange);
end
xlabel('Time (s)'); ylabel('Voltage (V)');
title(sprintf('800V DC Bus (\\mu=%.1fV, \\sigma=%.1fV)', mean(vData), std(vData)));
xlim([tDs(1) tDs(end)]);
[yLo, yHi] = hsplot.utils.autoMargin(vDs);
ylim([min(yLo, vBandLo-10) max(yHi, vBandHi+10)]);
grid on;
hold off;

if hasZoom
    nexttile;
    hold on;
    [tZ, zIdx] = hsplot.utils.sliceTime(Vdc.Time, zoomRange(1), zoomRange(2));
    vZ = double(Vdc.Data(zIdx));
    [tZd, vZd] = hsplot.utils.downsample(tZ, maxPts, vZ);
    fill([tZd(1) tZd(end) tZd(end) tZd(1)], [vBandLo vBandLo vBandHi vBandHi], ...
        [0.47 0.67 0.19], 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(tZd, vZd, 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
    yline(vNom, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
    yline(vOcpHi, '-', 'Color', [0.8 0 0], 'LineWidth', 0.8, 'Label', '+3%', ...
        'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    yline(vOcpLo, '-', 'Color', [0.8 0 0], 'LineWidth', 0.8, 'Label', '-3%', ...
        'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    xlabel('Time (s)'); ylabel('Voltage (V)');
    title(sprintf('Zoom: %.2fs - %.2fs', zoomRange(1), zoomRange(2)));
    xlim(zoomRange);
    [yLo, yHi] = hsplot.utils.autoMargin(vZd);
    ylim([min(yLo, vBandLo-10) max(yHi, vBandHi+10)]);
    grid on;
    hold off;
end

sgtitle('DC Bus Voltage', 'FontSize', 14);
end
