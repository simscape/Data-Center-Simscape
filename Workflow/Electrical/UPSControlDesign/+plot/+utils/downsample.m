function [timeOut, varargout] = downsample(timeIn, maxPoints, varargin)
%DOWNSAMPLE Decimate time series data to a maximum number of points.
%
%   [tOut, d1, d2, ...] = plot.utils.downsample(tIn, maxPoints, d1, d2, ...)
%   returns every Nth sample such that the output has at most maxPoints
%   elements. Handles both row and column time vectors. Data arguments can
%   be vectors (same length as tIn) or matrices (columns matching tIn length).
%
%   Example:
%     [tDs, vDs] = plot.utils.downsample(time, 2000, voltage);

% Copyright 2026 The MathWorks, Inc.

numPoints = numel(timeIn);
step = max(1, floor(numPoints / maxPoints));
indices = 1:step:numPoints;

timeOut = timeIn(indices);

varargout = cell(1, numel(varargin));
for argIdx = 1:numel(varargin)
    data = varargin{argIdx};
    if isvector(data)
        varargout{argIdx} = data(indices);
    else
        if size(data, 2) == numPoints
            varargout{argIdx} = data(:, indices);
        else
            varargout{argIdx} = data(indices, :);
        end
    end
end
end
