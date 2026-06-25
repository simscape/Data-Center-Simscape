function [yMin, yMax] = autoMargin(data, marginFraction)
%AUTOMARGIN Compute y-axis limits with a percentage margin.
%
%   [yMin, yMax] = plot.utils.autoMargin(data, marginFraction)
%   returns axis limits expanded by marginFraction (default 0.1 = 10%)
%   beyond the data range. Guarantees a minimum spread of 0.01.
%
%   Example:
%     [yLo, yHi] = plot.utils.autoMargin(powerData, 0.1);
%     ylim([yLo yHi]);

% Copyright 2026 The MathWorks, Inc.

if nargin < 2
    marginFraction = 0.1;
end

dataMin = min(data(:));
dataMax = max(data(:));
margin = marginFraction * max(abs(dataMax - dataMin), 0.01);

yMin = dataMin - margin;
yMax = dataMax + margin;
end
