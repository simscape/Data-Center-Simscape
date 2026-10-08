function [yMin, yMax] = autoMargin(data, marginFraction)
%AUTOMARGIN Compute y-axis limits with a percentage margin.

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
