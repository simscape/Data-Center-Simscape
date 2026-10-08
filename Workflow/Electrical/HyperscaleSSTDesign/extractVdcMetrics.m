function m = extractVdcMetrics(simOut, eventTime)
%EXTRACTVDCMETRICS Extract DC bus voltage quality metrics from simulation.
%
%   m = extractVdcMetrics(simOut) returns basic Vdc stats (t >= 0.5s).
%   m = extractVdcMetrics(simOut, eventTime) also computes event metrics.
%
%   Returns struct with:
%     Vdc_mean, Vdc_std, Vdc_pp, Vdc_min, Vdc_max,
%     Vdc_maxDip, Vdc_maxOvershoot, withinBand,
%     event_dip, event_overshoot, event_settling (if eventTime given)

% Copyright 2026 The MathWorks, Inc.

Vdc = simOut.logsout.get('Vdc800V').Values;
tAnalysis = max(0.5, Vdc.Time(1));
idx = Vdc.Time >= tAnalysis;
vData = double(Vdc.Data(idx));

m.Vdc_mean = mean(vData);
m.Vdc_std = std(vData);
m.Vdc_pp = max(vData) - min(vData);
m.Vdc_min = min(vData);
m.Vdc_max = max(vData);
m.Vdc_maxDip = 800 - min(vData);
m.Vdc_maxOvershoot = max(vData) - 800;
m.withinBand = (min(vData) >= 760) && (max(vData) <= 840);

if nargin >= 2 && eventTime > 0
    eventWindow = Vdc.Time >= (eventTime - 0.1) & Vdc.Time <= (eventTime + 1.0);
    vEvent = double(Vdc.Data(eventWindow));
    if ~isempty(vEvent)
        m.event_dip = 800 - min(vEvent);
        m.event_overshoot = max(vEvent) - 800;
        m.event_settling = NaN;
        tEvent = Vdc.Time(eventWindow);
        settled = abs(vEvent - 800) < 8;
        if any(settled)
            lastUnsettled = find(~settled, 1, 'last');
            if ~isempty(lastUnsettled) && lastUnsettled < length(tEvent)
                m.event_settling = tEvent(lastUnsettled) - eventTime;
            else
                m.event_settling = 0;
            end
        end
    end
end
end
