% LoadShedding - Configure model for load shedding scenario
% Both racks running at 90% utilization, then drop to 5% at t=1.0s
% This represents a coordinated workload migration or emergency power reduction

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

dt = 0.010; N = 1000;
stepTime = 3.0;
stepIdx = round(stepTime / dt);

util_shed = [0.90*ones(1, stepIdx), 0.05*ones(1, N - stepIdx)];

set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(util_shed, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(util_shed, 4), 'tsamp', num2str(dt));
