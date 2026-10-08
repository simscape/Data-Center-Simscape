% MixedWorkload - Configure model with realistic utilization profiles
% Training rack: 4-stage periodic (idle/fwd/bwd/comm) from NLR paper
% Inference rack: Request-driven (base/prefill/decode/teardown) from roofline model
%
% Profiles replicate what computeProfileSource.ssc produces, discretized at 10ms.

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

rng(42);
dt = 0.010; N = 1000;
warmup = 200; % 2s constant load for model startup stabilization

%% Training Rack — 4-Stage Periodic Structure
% NLR paper (Vercellino et al.) calibrated for Rubin_Ultra / Llama_405B / TP8_PP8:
%   Idle(5%) -> Forward(U=0.85) -> Backward(U=0.92) -> Comm(U=0.15)
% Checkpoint every 5 steps at U=0.03

U_idle = 0.05;  U_fwd = 0.85;  U_bwd = 0.92;  U_comm = 0.15;  U_ckpt = 0.03;

T_step_samples = 80;  % ~800ms training step
n_idle = max(1, round(T_step_samples * 0.05));
n_fwd  = max(1, round(T_step_samples * 0.38));
n_bwd  = max(1, round(T_step_samples * 0.45));
n_comm = T_step_samples - n_idle - n_fwd - n_bwd;

train_util = zeros(1, N);
train_util(1:warmup) = 0.45;

k = warmup + 1;
step_num = 0;
while k <= N
    step_num = step_num + 1;
    is_ckpt = (mod(step_num, 5) == 0);

    % Stage 1: Idle/bubble
    n = min(n_idle, N - k + 1);
    train_util(k:k+n-1) = U_idle + 0.01*randn(1, n);
    k = k + n; if k > N, break; end

    % Stage 2: Forward pass
    n = min(n_fwd, N - k + 1);
    train_util(k:k+n-1) = U_fwd + 0.02*randn(1, n);
    k = k + n; if k > N, break; end

    % Stage 3: Backward pass (peak)
    n = min(n_bwd, N - k + 1);
    train_util(k:k+n-1) = U_bwd + 0.02*randn(1, n);
    k = k + n; if k > N, break; end

    % Stage 4: Comm+Sync or Checkpoint
    n = min(n_comm, N - k + 1);
    if is_ckpt
        train_util(k:k+n-1) = U_ckpt + 0.01*randn(1, n);
    else
        train_util(k:k+n-1) = U_comm + 0.015*randn(1, n);
    end
    k = k + n;
end
train_util = max(0.01, min(1.0, train_util));

%% Inference Rack — Request-Driven 4-Stage Pattern
% Roofline model (Rubin_Ultra, Llama_70B, batch=8, prompt=512, output=256):
%   Base(U=0.08) -> Prefill(U=0.88) -> Decode(U=0.42) -> Teardown(U=0.08)
% Variable prompt/output lengths create irregular prefill spikes on decode plateau.

U_base = 0.08;  U_prefill = 0.88;  U_decode = 0.42;

prompt_lengths = [128 256 512 512 1024 1024 2048 4096];
output_lengths = [64  128 256 256 512  512  768  1024];
T_req_base = 22;  % samples (~220ms per request batch)

infer_util = zeros(1, N);
infer_util(1:warmup) = 0.45;

k = warmup + 1;
req_idx = 0;
while k <= N
    req_idx = req_idx + 1;

    p_len = prompt_lengths(mod(req_idx-1, length(prompt_lengths)) + 1);
    o_len = output_lengths(mod(req_idx-1, length(output_lengths)) + 1);
    prefill_scale = p_len / 512;
    decode_scale = o_len / 256;

    T_req = max(15, T_req_base + round(2*(rand - 0.5)));

    n_base = max(1, round(T_req * 0.05));
    n_prefill = max(1, round(T_req * 0.08 * prefill_scale));
    n_decode = max(1, round(T_req * 0.82 * decode_scale));
    n_teardown = max(1, T_req - n_base - n_prefill - n_decode);

    % Base load
    n = min(n_base, N - k + 1);
    infer_util(k:k+n-1) = U_base + 0.02*randn(1, n);
    k = k + n; if k > N, break; end

    % Prefill spike
    n = min(n_prefill, N - k + 1);
    infer_util(k:k+n-1) = U_prefill + 0.03*randn(1, n);
    k = k + n; if k > N, break; end

    % Decode plateau (slight upward drift as KV cache grows)
    n = min(n_decode, N - k + 1);
    drift = linspace(0, 0.04, n);
    infer_util(k:k+n-1) = U_decode + drift + 0.025*randn(1, n);
    k = k + n; if k > N, break; end

    % Teardown
    n = min(n_teardown, N - k + 1);
    infer_util(k:k+n-1) = U_base + 0.01*randn(1, n);
    k = k + n;
end
infer_util = max(0.01, min(1.0, infer_util));

%% Apply to model
set_param([modelName '/Server Load/Racks/Training Load Profile'], ...
    'OutValues', mat2str(train_util, 4), 'tsamp', num2str(dt));
set_param([modelName '/Server Load/Racks/Inference Load Profile'], ...
    'OutValues', mat2str(infer_util, 4), 'tsamp', num2str(dt));
