function [timeOut, varargout] = downsample(timeIn, maxPoints, varargin)
%DOWNSAMPLE Decimate time series data to a maximum number of points.

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
