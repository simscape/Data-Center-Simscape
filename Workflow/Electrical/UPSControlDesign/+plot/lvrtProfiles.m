% lvrtProfiles  Plot LVRT voltage profiles for all grid operators.
%
%   plot.lvrtProfiles
%
%   Digitised from OCP DCF LVDC White Paper Figure 28, March 2026.

% Copyright 2026 The MathWorks, Inc.

dt = 0.001;
tau = 0:dt:3.999;
nPts = numel(tau);
yTop = 1.1;

operators = {"ERCOT", "RTE France", "Eir Grid", "ATC", "AESO"};
colors = [0.20 0.66 0.33;
          0.93 0.69 0.13;
          0.75 0.00 0.75;
          0.00 0.45 0.74;
          0.85 0.33 0.10];
nOps = numel(operators);

V = ones(nOps, nPts);

for i = 1:nPts
    tt = tau(i);
    if tt < 0
        continue
    end

    % ERCOT
    if tt < 0.15
        V(1,i) = 0.11;
    elseif tt < 0.5
        V(1,i) = 0.50;
    elseif tt < 2.00
        V(1,i) = 0.8;
    elseif tt < 4
        V(1,i) = 0.9;
    else
        V(1,i) = 1;
    end

    % RTE France
    if tt < 0.15
        V(2,i) = 0.00;
    elseif tt < 1.2
        V(2,i) = 0.9 * (tt - 0.15) / (1.2 - 0.15);
    elseif tt < 4
        V(2,i) = 0.9;
    else
        V(2,i) = 1;
    end

    % Eir Grid
    if tt < 0.15
        V(3,i) = 0.00;
    elseif tt < 0.50
        V(3,i) = 0.5;
    elseif tt < 2
        V(3,i) = 0.8;
    elseif tt < 4
        V(3,i) = 0.9;
    else
        V(3,i) = 1;
    end

    % ATC
    if tt < 0.15
        V(4,i) = 0.00;
    elseif tt < 1.2
        V(4,i) = 0.25;
    elseif tt < 2.5
        V(4,i) = 0.5;
    elseif tt < 3
        V(4,i) = 0.7;
    elseif tt < 4
        V(4,i) = 0.9;
    else
        V(4,i) = 1;
    end

    % AESO
    if tt < 0.15
        V(5,i) = 0.00;
    elseif tt < 0.3
        V(5,i) = 0.45;
    elseif tt < 2
        V(5,i) = 0.65;
    elseif tt < 3
        V(5,i) = 0.75;
    elseif tt < 4
        V(5,i) = 0.9;
    else
        V(5,i) = 1;
    end
end

[~, sortIdx] = sort(mean(V,2), 'descend');

fig = figure('Name', 'LVRT Profiles');
if length(dbstack) > 1
    set(fig, 'Units', 'pixels', 'Position', [100 50 1200 700]);
end

hAx = axes;
hold(hAx, 'on')

for j = 1:nOps
    k = sortIdx(j);
    fill(hAx, [tau fliplr(tau)], [V(k,:) zeros(1,nPts)], ...
        colors(k,:), 'FaceAlpha', 0.35, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end

h = gobjects(1, nOps);
for k = 1:nOps
    h(k) = builtin('plot', hAx, tau, V(k,:), 'LineWidth', 2.5, 'Color', colors(k,:));
end

text(2.5, 0.08, 'May Disconnect', 'FontSize', 16, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.15 0.15 0.15], 'Parent', hAx);
text(2.5, 1.02, 'Ride Through', 'FontSize', 16, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.5 0.5 0.5], 'Parent', hAx);

set(hAx, 'XGrid', 'on', 'YGrid', 'on')
axis(hAx, [0 4 0 yTop])
title(hAx, 'Low Voltage Ride-Through Profiles', 'FontSize', 15)
xlabel(hAx, 'Time (s)')
ylabel(hAx, 'Voltage (pu)')
legend(hAx, h, operators, 'Location', 'best', 'FontSize', 11)
