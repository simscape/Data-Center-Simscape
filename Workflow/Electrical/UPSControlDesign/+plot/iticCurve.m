function iticCurve()
% iticCurve  Plot the ITIC/CBEMA voltage tolerance envelope.
%
%   plot.iticCurve() creates a standalone figure showing the three
%   ITIC regions: Prohibited, No Interruption in Function, and No Damage.
%
%   Example:
%     plot.iticCurve()

% Copyright 2026 The MathWorks, Inc.

% ITIC envelope breakpoints (per ITI/CBEMA curve, IEEE Std 1100)
tIticLower = [1e-5  0.02  0.0201  0.5  0.501  10];
vIticLower = [0.00  0.00  0.70    0.70 0.80   0.80];
tIticUpper = [1e-5  0.001  0.003  0.5  0.501  10];
vIticUpper = [5.00  2.00   1.40   1.20 1.10   1.10];

figure('Name', 'ITIC/CBEMA Curve', 'Position', [100 50 800 500], 'Color', 'w');
hold on
set(gca, 'XScale', 'log');

% Shaded regions
fill([tIticLower fliplr(tIticLower)], ...
    [vIticLower zeros(1, numel(tIticLower))], ...
    [0.9 0.9 1.0], 'FaceAlpha', 0.3, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
fill([tIticUpper fliplr(tIticUpper)], ...
    [vIticUpper ones(1, numel(tIticUpper))*5], ...
    [1 0.85 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
tCommon = logspace(-5, 1, 500);
vLowerInterp = interp1(tIticLower, vIticLower, tCommon, 'previous', 0.90);
vUpperInterp = interp1(tIticUpper, vIticUpper, tCommon, 'previous', 1.10);
fill([tCommon fliplr(tCommon)], [vLowerInterp fliplr(vUpperInterp)], ...
    [0.85 1 0.85], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

% Envelope lines
plot(tIticLower, vIticLower, '-', 'LineWidth', 2, 'Color', [0 0.4 0.8]);
plot(tIticUpper, vIticUpper, '-', 'LineWidth', 2, 'Color', [0.8 0 0]);

% Region labels
text(0.3, 0.35, 'No Damage', 'FontSize', 10, ...
    'Color', [0.2 0.2 0.6], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.01, 1.6, 'Prohibited', 'FontSize', 10, ...
    'Color', [0.7 0 0], 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(0.3, 0.95, 'No Interruption in Function', 'FontSize', 10, ...
    'Color', [0 0.5 0], 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

grid on; box on
xlim([1e-3 10]);
ylim([0 2.0]);
xlabel('Disturbance Duration (s)', 'FontSize', 10)
ylabel('Retained Voltage (pu)', 'FontSize', 10)
title('ITIC/CBEMA Voltage Tolerance Envelope', 'FontSize', 10)
legend('Lower Limit', 'Upper Limit', 'Location', 'northeast', 'FontSize', 8)

end
