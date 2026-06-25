function highlightZoom(axHandle, zoomRange)
%HIGHLIGHTZOOM Draw a translucent blue rectangle marking a zoom region.
%
%   plot.utils.highlightZoom(ax, [tStart tStop]) shades the specified time
%   range on the given axes with a semi-transparent blue overlay.
%
%   Example:
%     plot.utils.highlightZoom(gca, [3 5]);

% Copyright 2026 The MathWorks, Inc.

yLimits = ylim(axHandle);
fill(axHandle, ...
    [zoomRange(1) zoomRange(2) zoomRange(2) zoomRange(1)], ...
    [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
    [0.3 0.6 0.9], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
