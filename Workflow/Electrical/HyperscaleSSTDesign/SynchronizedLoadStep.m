% SynchronizedLoadStep - Configure model for coordinated load step
% Training rack steps from 10% idle into cycling fwd/bwd/comm stages (70-95%)
% Inference rack steps from 10% idle to moderate steady load (~45%)
% Both step simultaneously at t=3.0s — tests SST transient under asymmetric demand

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

rng(7);
dt = 0.010; N = 1000;
stepTime = 3.0;
stepIdx = round(stepTime / dt);

%% Training Rack — Step into cycling 4-stage pattern
U_fwd = 0.85;  U_bwd = 0.92;  U_comm = 0.15;  U_idle_stage = 0.05;
T_step_samples = 80;
n_idle_s = max(1, round(T_step_samples * 0.05));
n_fwd   = max(1, round(T_step_samples * 0.38));
n_bwd   = max(1, round(T_step_samples * 0.45));
n_comm  = T_step_samples - n_idle_s - n_fwd - n_bwd;

train_util = zeros(1, N);
train_util(1:stepIdx) = 0.10;

k = stepIdx + 1;
while k <= N
    n = min(n_idle_s, N - k + 1);
    train_util(k:k+n-1) = U_idle_stage + 0.01*randn(1, n);
    k = k + n; if k > N, break; end

    n = min(n_fwd, N - k + 1);
    train_util(k:k+n-1) = U_fwd + 0.02*randn(1, n);
    k = k + n; if k > N, break; end

    n = min(n_bwd, N - k + 1);
    train_util(k:k+n-1) = U_bwd + 0.02*randn(1, n);
    k = k + n; if k > N, break; end

    n = min(n_comm, N - k + 1);
    train_util(k:k+n-1) = U_comm + 0.015*randn(1, n);
    k = k + n;
end
train_util = max(0.01, min(1.0, train_util));

%% Inference Rack — Step to moderate steady load with noise
infer_util = zeros(1, N);
infer_util(1:stepIdx) = 0.10;
infer_util(stepIdx+1:N) = 0.45 + 0.03*randn(1, N - stepIdx);
infer_util = max(0.01, min(1.0, infer_util));

%% Apply to model
set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(train_util, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(infer_util, 4), 'tsamp', num2str(dt));
