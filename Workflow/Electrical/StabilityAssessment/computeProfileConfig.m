%% computeProfileConfig.m — Configure the Compute Profile Source block
% Sets workload parameters and derives GPU count, nTray, and all timings.
% Run AFTER opening the model (DataCenterParamScan must have run first).

%% === GPU HARDWARE ===
gpu.model       = 'B200';        % 'B200','H200','H100','A100','MI300X','MI325X','Gaudi3','Rubin_Ultra','Custom'
gpu.peakTFLOPS  = 2250;          % BF16 dense TFLOPS (auto-filled from preset, editable)
gpu.hbmBW       = 8e12;          % HBM bandwidth (bytes/s)
gpu.hbmCapacity = 192;           % HBM per GPU (GB)
gpu.interNodeBW = 1800e9;        % NVLink / InfiniBand bandwidth per GPU (bytes/s)
gpu.TDP         = 1000;          % Thermal design power (W)

%% === CLUSTER ===
cluster.gpusPerNode = 8;         % GPUs per node (DGX = 8)
% Specify ONE of these (leave the other empty):
cluster.numNodes = [];           % Physical nodes — OR —
cluster.DP       = 162;          % Data parallelism degree

%% === LLM MODEL ===
llm.model       = 'Llama_70B';  % 'Llama_7B','Llama_13B','Llama_70B','GPT_175B','Llama_405B','Custom'
llm.numParams_B = 70;           % Billion parameters (auto-filled from preset, editable)
llm.numLayers   = 80;           % Transformer layers
llm.precision   = 2;            % Bytes per param (2=BF16, 1=FP8, 4=FP32)

%% === PARALLELISM ===
parallel.TP = 8;                 % Tensor parallelism
parallel.PP = 4;                 % Pipeline parallelism

%% === WORKLOAD ===
workload.type       = 'Training'; % 'Training', 'Inference', 'FineTuning'
workload.timeScale  = 10;         % Time compression (1=real-time)
workload.microBatch = 8;
workload.globalBatch = 12288;
workload.seqLength  = 2048;

% Training phase utilizations (calibrated to Ko & Zhu Table I)
workload.idleUtil     = 0.60;     % Pipeline bubble / data load (HBM+leakage keep floor ~60%)
workload.fwdUtil      = 0.92;     % Forward pass (near saturation)
workload.bwdUtil      = 0.98;     % Backward pass (peak — activation recompute)
workload.commSyncUtil = 0.65;     % Allreduce + optimizer (NVLink/HBM active)

%% === INFERENCE ===
inference.promptTokens  = 512;
inference.outputTokens  = 256;
inference.numConcurrent = 8;
inference.batchSize     = 8;
inference.allreduceLatency = 5e-6; % s per layer
inference.baseUtil      = 0.08;    % Idle/teardown utilization
inference.baseFrac      = 0.10;    % Fraction of period at base load

%% === EFFICIENCY ===
efficiency.MFU                = 0.85;
efficiency.checkpointOverhead = 0.03;
efficiency.stragglerOverhead  = 0.02;
efficiency.trainableParamFrac = 0.02;  % LoRA
efficiency.evalInterval       = 5;
efficiency.evalBatches        = 2;
efficiency.ftCheckpointOverhead = 0.05;

%% === OUTPUT FILTER ===
filter.enable       = false;
filter.timeConstant = 0.01;      % s

%% ========================================================================
%  RESOLVE & DERIVE (do not edit below)
%  ========================================================================
% --- Auto-fill GPU specs from preset ---
gpuDB = struct( ...
    'Rubin_Ultra', [4500, 12e12, 288, 3600e9, 1400], ...
    'B200',        [2250, 8e12,  192, 1800e9, 1000], ...
    'H200',        [990,  4.8e12,141, 900e9,  700], ...
    'H100',        [990,  3.35e12,80, 900e9,  700], ...
    'A100',        [312,  2e12,  80,  600e9,  400], ...
    'MI300X',      [1307, 5.3e12,192, 896e9,  750], ...
    'MI325X',      [1307, 6e12,  256, 896e9,  750], ...
    'Gaudi3',      [1835, 3.7e12,128, 2400e9, 900]);
if ~strcmp(gpu.model, 'Custom') && isfield(gpuDB, gpu.model)
    s = gpuDB.(gpu.model);
    gpu.peakTFLOPS = s(1); gpu.hbmBW = s(2); gpu.hbmCapacity = s(3);
    gpu.interNodeBW = s(4); gpu.TDP = s(5);
end

% --- Auto-fill LLM specs from preset ---
llmDB = struct( ...
    'Llama_7B',   [7,   32,  2], ...
    'Llama_13B',  [13,  40,  2], ...
    'Llama_70B',  [70,  80,  2], ...
    'GPT_175B',   [175, 96,  2], ...
    'Llama_405B', [405, 126, 2]);
if ~strcmp(llm.model, 'Custom') && isfield(llmDB, llm.model)
    s = llmDB.(llm.model);
    llm.numParams_B = s(1); llm.numLayers = s(2); llm.precision = s(3);
end
llm.numParams = llm.numParams_B * 1e9;

% --- Resolve cluster size ---
if ~isempty(cluster.numNodes)
    cluster.numGPUs = cluster.numNodes * cluster.gpusPerNode;
    parallel.DP = max(1, floor(cluster.numGPUs / (parallel.TP * parallel.PP)));
elseif ~isempty(cluster.DP)
    parallel.DP = cluster.DP;
    cluster.numGPUs = parallel.DP * parallel.TP * parallel.PP;
    cluster.numNodes = cluster.numGPUs / cluster.gpusPerNode;
else
    error('Set cluster.numNodes or cluster.DP');
end

% --- Propagate to physical model ---
Ngpu = cluster.numGPUs;
numGPUs = cluster.numGPUs;
nTray = ceil(numGPUs / (itRack.numRack * itTray.nGPU(1)));
itTray.dcdc.P_rated = nTray * itTray.nGPU * 1200;

% --- Derived timings ---
gradBytes  = llm.precision * llm.numParams;
T_ref      = 6 * llm.numParams / 1e12;
rateNorm   = parallel.TP * gpu.peakTFLOPS * efficiency.MFU;

T_microbatch = T_ref * workload.microBatch * workload.seqLength / rateNorm;
T_bubble     = T_microbatch * max(parallel.PP - 1, 0);
gradAccumSteps = max(1, workload.globalBatch / (workload.microBatch * parallel.DP));

T_allreduce = 2*(parallel.DP-1)/max(parallel.DP,1) * gradBytes / (parallel.DP * gpu.interNodeBW);
T_allreduce = max(0.001, min(T_allreduce, T_microbatch));
T_optimizer = 6 * gradBytes / (parallel.TP * gpu.hbmBW);

T_step = (T_bubble + T_microbatch*gradAccumSteps + T_allreduce + T_optimizer) / ...
         max(0.5, 1 - efficiency.checkpointOverhead - efficiency.stragglerOverhead);

% Memory
memModel_GB = llm.numParams * llm.precision / 1e9 / parallel.TP;
memOptim_GB = llm.numParams * 12 / 1e9 / parallel.TP;
memFits = (memModel_GB + memOptim_GB) < gpu.hbmCapacity;

%% === SUMMARY ===
fprintf('\n  GPU: %s (%d TFLOPS, %d GB HBM)\n', gpu.model, gpu.peakTFLOPS, gpu.hbmCapacity);
fprintf('  Cluster: %d GPUs (%d nodes) | TP=%d PP=%d DP=%d\n', ...
    cluster.numGPUs, cluster.numNodes, parallel.TP, parallel.PP, parallel.DP);
fprintf('  LLM: %s (%.0fB params, %d layers)\n', llm.model, llm.numParams_B, llm.numLayers);
fprintf('  nTray = %d | Ngpu = %d\n\n', nTray, Ngpu);
fprintf('  Training step: %.3f s (%.3f s compressed)\n', T_step, T_step/workload.timeScale);
fprintf('    microbatch=%.3fs  bubble=%.3fs  allreduce=%.3fs  optimizer=%.3fs\n', ...
    T_microbatch, T_bubble, T_allreduce, T_optimizer);
fprintf('  Memory/GPU: %.1f GB model + %.1f GB optim = %.1f / %d GB [%s]\n', ...
    memModel_GB, memOptim_GB, memModel_GB+memOptim_GB, gpu.hbmCapacity, ...
    char("FITS"*(memFits) + "OOM!"*(~memFits)));
fprintf('  Peak power: %.2f MW (%d GPUs × %d W)\n\n', cluster.numGPUs*gpu.TDP/1e6, cluster.numGPUs, gpu.TDP);

if ~memFits
    warning('Model does NOT fit in GPU memory! Increase TP or reduce model size.');
end

%% === APPLY TO BLOCK ===
blk = find_system('DataCenterStability', 'LookUnderMasks', 'all', ...
    'MatchFilter', @Simulink.match.allVariants, 'RegExp', 'on', 'Name', '.*Compute.*');
blk = blk{1};

gpuEnum = ['GPUModel.' gpu.model];
llmEnum = ['LLMModelSize.' llm.model];
wlEnum  = ['WorkloadType.' workload.type];
knownTP_PP = {[8,4],[4,8],[8,8],[4,4]};
tppp = [parallel.TP, parallel.PP];
if any(cellfun(@(x) isequal(x, tppp), knownTP_PP))
    parEnum = sprintf('ParallelismStrategy.TP%d_PP%d', parallel.TP, parallel.PP);
else
    parEnum = 'ParallelismStrategy.Custom';
end

set_param(blk, ...
    'gpuModel', gpuEnum, 'numGPUs', num2str(Ngpu), ...
    'workloadType', wlEnum, 'timeScale', num2str(workload.timeScale), ...
    'showAdvanced', 'true', ...
    'customPeakTFLOPS', num2str(gpu.peakTFLOPS), ...
    'customHbmBW', num2str(gpu.hbmBW), ...
    'hbmBW', num2str(gpu.hbmBW), ...
    'interNodeBW', num2str(gpu.interNodeBW), ...
    'llmSize', llmEnum, ...
    'customNumParams_B', num2str(llm.numParams_B), ...
    'customNumLayers', num2str(llm.numLayers), ...
    'customPrecision', num2str(llm.precision), ...
    'parallelism', parEnum, ...
    'customTP', num2str(parallel.TP), ...
    'customPP', num2str(parallel.PP), ...
    'microBatch', num2str(workload.microBatch), ...
    'globalBatch', num2str(workload.globalBatch), ...
    'seqLength', num2str(workload.seqLength), ...
    'idleUtil', num2str(workload.idleUtil), ...
    'fwdUtil', num2str(workload.fwdUtil), ...
    'bwdUtil', num2str(workload.bwdUtil), ...
    'commSyncUtil', num2str(workload.commSyncUtil), ...
    'prompt_tokens', num2str(inference.promptTokens), ...
    'output_tokens', num2str(inference.outputTokens), ...
    'num_concurrent', num2str(inference.numConcurrent), ...
    'batch_size', num2str(inference.batchSize), ...
    'allreduce_latency', num2str(inference.allreduceLatency), ...
    'baseInfUtil', num2str(inference.baseUtil), ...
    'baseInfFrac', num2str(inference.baseFrac), ...
    'MFU', num2str(efficiency.MFU), ...
    'checkpointOverhead', num2str(efficiency.checkpointOverhead), ...
    'stragglerOverhead', num2str(efficiency.stragglerOverhead), ...
    'trainableParamFrac', num2str(efficiency.trainableParamFrac), ...
    'evalInterval', num2str(efficiency.evalInterval), ...
    'evalBatches', num2str(efficiency.evalBatches), ...
    'ft_checkpointOverhead', num2str(efficiency.ftCheckpointOverhead), ...
    'enableFilter', mat2str(filter.enable), ...
    'filterTimeConstant', num2str(filter.timeConstant));

fprintf('  Block updated.\n');
