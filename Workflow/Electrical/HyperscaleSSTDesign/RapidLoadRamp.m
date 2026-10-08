% RapidLoadRamp - Configure model for unbalanced ramp
% Training ramps from 10% to 95% over 1 second; inference stays at 10%.
% This creates a severe load imbalance that stresses the SST's PFC controller
% (unity PF across a wide power range) and CHB per-phase DC voltage balancing.

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

dt = 0.010; N = 1000;
rampStart = 3.0;
rampDuration = 1.0;

startIdx = round(rampStart / dt);
rampSamples = round(rampDuration / dt);

% Training: ramp from 10% to 95%
util_train = zeros(1, N);
util_train(1:startIdx) = 0.10;
rampIdx = startIdx + (1:rampSamples);
util_train(rampIdx) = linspace(0.10, 0.95, rampSamples);
util_train(startIdx + rampSamples + 1:end) = 0.95;

% Inference: constant 10% (light load)
util_infer = 0.10 * ones(1, N);

set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(util_train, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(util_infer, 4), 'tsamp', num2str(dt));
