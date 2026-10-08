% VoltageRideThrough - Configure model for LVRT scenario
% Applies a three-phase voltage sag to the grid source using lvrtProfile.
% Moderate constant load: training 80%, inference 60%.

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

dt = 0.010; N = 1000;

% Moderate constant load
util_train = 0.80 * ones(1, N);
util_infer = 0.60 * ones(1, N);

set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(util_train, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(util_infer, 4), 'tsamp', num2str(dt));
