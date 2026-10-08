% NormalOperation - Configure model for steady-state operation
% Sets both racks to constant 45% utilization (typical datacenter baseline)

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

steadyUtil = 0.45;
N = 1000; dt = 0.010;
util_const = steadyUtil * ones(1, N);

set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(util_const, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(util_const, 4), 'tsamp', num2str(dt));
