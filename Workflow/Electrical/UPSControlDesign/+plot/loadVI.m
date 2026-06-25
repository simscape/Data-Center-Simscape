function loadVI(logsout,zoomRange,voltageLimit)
% loadVI  Plot load voltage and current (RMS and instantaneous).
%
%   plot.loadVI(logsout) plots RMS voltage (top) and RMS current (bottom)
%   in a 2x1 layout. Voltage includes a yellow-gold shaded acceptable band;
%   trace segments outside the band are red.
%
%   plot.loadVI(logsout, zoomRange) expands to a 3x2 layout:
%     - (1,1) RMS Voltage — full range     (1,2) Zoomed RMS Voltage
%     - (2,1) RMS Current — full range     (2,2) Zoomed RMS Current
%     - (3,1) Instantaneous Voltage        (3,2) Instantaneous Current
%   Instantaneous voltage includes separate positive/negative bands and
%   red shading on half-cycles with peak violations.
%   zoomRange = [tStart tStop] specifies the time window.
%
%   plot.loadVI(__, 'max', val, 'min', val) sets voltage limit band
%   boundaries. Default: max = 1.1, min = 0.9 (pu).
%
%   Required logsout signals: 'loadVoltage', 'loadCurrent'
%
%   Examples:
%     plot.loadVI(logsout)
%     plot.loadVI(logsout, [3 5])
%     plot.loadVI(logsout, [3 5], 'max', 1.05, 'min', 0.95)

% Copyright 2026 The MathWorks, Inc.

arguments
    logsout
    zoomRange double = [];
    voltageLimit.max double = 1.1;
    voltageLimit.min double = 0.9;
end

hasZoom = ~isempty(zoomRange);

fig = figure('Name', 'loadVI');
if length(dbstack) > 1
    if hasZoom
        set(fig, 'Units', 'pixels', 'Position', [100 50 1200 800]);
    else
        set(fig, 'Units', 'pixels', 'Position', [100 100 900 600]);
    end
end

vMax = voltageLimit.max;
vMin = voltageLimit.min;
maxPts = 2000;

loadVoltage = squeeze(logsout.get('loadVoltage').Values.Data);
loadCurrent = squeeze(logsout.get('loadCurrent').Values.Data);
voltageData = reshape(squeeze(logsout.get('rmsVoltage').Values.Data(1, 1, :)), 1, []) * sqrt(2);
currentData = logsout.get('rmsCurrent').Values.Data*sqrt(2);

timeData = logsout.get('loadVoltage').Values.Time;
[tPlot, timeIdx] = plot.utils.sliceTime(timeData, 1.5, 10);
tStartPlot = tPlot(1);
tStopPlot = tPlot(end);

vPlot = voltageData(:,timeIdx);
cPlot = currentData(:,timeIdx);

[tPd, vPd, cPd] = plot.utils.downsample(tPlot, maxPts, vPlot, cPlot);

if hasZoom
    numRows = 3;
    numCols = 2;
    zoomMask = tPlot > zoomRange(1) & tPlot < zoomRange(2);
    tZoom = tPlot(zoomMask);
    [tZd] = plot.utils.downsample(tZoom, maxPts);
else
    numRows = 2;
    numCols = 1;
end

%% (1,1) RMS Voltage — full range
subplot(numRows, numCols, 1);
hold on

plot.utils.voltageBand(gca, [tStartPlot tStopPlot], vMin, vMax);
plot.utils.plotWithViolations(gca, tPd, vPd, vMin, vMax);

if hasZoom
    plot.utils.highlightZoom(gca, zoomRange);
end

grid on;
axis([tStartPlot tStopPlot 0.5 1.5]);
title('Load Voltage (RMS)')
ylabel('Voltage (pu)')
xlabel('Time (s)')

%% (2,1) RMS Current — full range
if hasZoom
    subplot(numRows, numCols, 3);
else
    subplot(numRows, numCols, 2);
end
hold on

plot(tPd, cPd, 'LineWidth', 2, 'Color', [0 0.45 0.74])

if hasZoom
    plot.utils.highlightZoom(gca, zoomRange);
end

grid on
[currentMin, currentMax] = plot.utils.autoMargin(cPd);
axis([tStartPlot tStopPlot currentMin currentMax]);
title('Load Current (RMS)')
ylabel('Current (pu)')
xlabel('Time (s)')

if hasZoom
    vZoom = vPlot(:,zoomMask);
    [~, vZd] = plot.utils.downsample(tZoom, maxPts, vZoom);
    cZoom = cPlot(:,zoomMask);
    [~, cZd] = plot.utils.downsample(tZoom, maxPts, cZoom);

    %% (1,2) Zoomed RMS Voltage
    subplot(numRows, numCols, 2);
    hold on

    plot.utils.voltageBand(gca, zoomRange, vMin, vMax);
    plot.utils.plotWithViolations(gca, tZd, vZd, vMin, vMax);
    grid on;
    axis([zoomRange(1) zoomRange(2) 0.5 1.5]);
    title(sprintf('RMS Voltage (%.1fs - %.1fs)', zoomRange(1), zoomRange(2)))
    ylabel('Voltage (pu)')
    xlabel('Time (s)')

    %% (2,2) Zoomed RMS Current
    subplot(numRows, numCols, 4);
    hold on

    plot(tZd, cZd, 'LineWidth', 2, 'Color', [0 0.45 0.74])
    grid on
    [cZoomMin, cZoomMax] = plot.utils.autoMargin(cZd);
    axis([zoomRange(1) zoomRange(2) cZoomMin cZoomMax]);
    title(sprintf('RMS Current (%.1fs - %.1fs)', zoomRange(1), zoomRange(2)))
    ylabel('Current (pu)')
    xlabel('Time (s)')

    %% (3,1) Instantaneous Voltage — zoomed
    subplot(numRows, numCols, 5);
    hold on
    plot.utils.voltageBand(gca, zoomRange, vMin, vMax);
    plot.utils.voltageBand(gca, zoomRange, -vMax, -vMin);
    vZoomInst = loadVoltage(:,zoomMask);

    yLimits = [-1.5, 1.5];
    numViolations = 0;
    for phIdx = 1:size(vZoomInst, 1)
        phaseData = vZoomInst(phIdx,:);
        idx = 2:length(phaseData)-1;
        posM = phaseData(idx) > phaseData(idx-1) & phaseData(idx) > phaseData(idx+1);
        posLocs = idx(posM);
        posPeaks = phaseData(posLocs);
        negM = phaseData(idx) < phaseData(idx-1) & phaseData(idx) < phaseData(idx+1);
        negLocs = idx(negM);
        negPeaks = phaseData(negLocs);

        posViolation = posPeaks > vMax | posPeaks < vMin;
        negViolation = negPeaks < -vMax | negPeaks > -vMin;

        violationLocs = [posLocs(posViolation), negLocs(negViolation)];
        numViolations = numViolations + length(violationLocs);
        allLocs = sort([posLocs, negLocs]);
        for vIdx = 1:length(violationLocs)
            loc = violationLocs(vIdx);
            locPos = find(allLocs == loc);
            if locPos > 1
                tLeft = tZoom(allLocs(locPos-1));
            else
                tLeft = tZoom(1);
            end
            if locPos < length(allLocs)
                tRight = tZoom(allLocs(locPos+1));
            else
                tRight = tZoom(end);
            end
            tMid = tZoom(loc);
            tRegionStart = (tLeft + tMid) / 2;
            tRegionStop = (tMid + tRight) / 2;
            patchX = [tRegionStart, tRegionStop, tRegionStop, tRegionStart];
            patchY = [yLimits(1), yLimits(1), yLimits(2), yLimits(2)];
            fill(patchX, patchY, [1 0 0], 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        end
    end

    dsInst = max(1, floor(size(vZoomInst, 2) / maxPts));
    plot(tZoom(1:dsInst:end), vZoomInst(:,1:dsInst:end), 'LineWidth', 1)
    grid on
    axis([zoomRange(1) zoomRange(2) yLimits(1) yLimits(2)]);
    if numViolations > 0
        title(sprintf('Instantaneous Voltage (%.1fs - %.1fs) — %d peak violation(s)', ...
            zoomRange(1), zoomRange(2), numViolations), 'Color', 'red')
    else
        title(sprintf('Instantaneous Voltage (%.1fs - %.1fs) — Within Limits', ...
            zoomRange(1), zoomRange(2)), 'Color', [0 0.5 0])
    end
    ylabel('Voltage (pu)')
    xlabel('Time (s)')

    %% (3,2) Instantaneous Current — zoomed
    subplot(numRows, numCols, 6);
    cZoomInst = loadCurrent(:,zoomMask);
    plot(tZoom(1:dsInst:end), cZoomInst(:,1:dsInst:end), 'LineWidth', 1)
    grid on
    [instCurrentMin, instCurrentMax] = plot.utils.autoMargin(cZoomInst);
    axis([zoomRange(1) zoomRange(2) instCurrentMin instCurrentMax]);
    title(sprintf('Instantaneous Current (%.1fs - %.1fs)', zoomRange(1), zoomRange(2)))
    ylabel('Current (pu)')
    xlabel('Time (s)')
end

sgtitle('Load Voltage and Current','Fontsize',15);
end
