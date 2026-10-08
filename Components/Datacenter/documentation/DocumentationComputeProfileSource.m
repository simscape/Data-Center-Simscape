%% Compute Profile Source (LLM Workload Generator) Block
% This block generates a time-varying compute demand signal (TFLOPS) that
% replicates the training, inference, or fine-tuning cycle of large language
% models. It supports NVIDIA (Rubin Ultra, B200, H200, H100, A100), AMD
% (MI300X, MI325X), Intel (Gaudi3), and custom GPU specifications.
%
% <<computeProfileSource.png>>

%

%% Overview
% The Compute Profile Source produces a periodic utilization waveform that
% drives GPU power consumption in data center electrical simulations. The
% output captures the load transitions that stress power delivery networks:
% bus capacitors, battery backup units, cable ratings, and PFC controllers.
%
% *Training* uses a 4-stage model calibrated against measured GPU power
% traces (Ko & Zhu, 2024). The output follows a periodic cycle where each
% training step contains four distinct power phases:
%
% * *Stage 1: Idle/Bubble* --- Data loading overlapped with CPU/NIC
%   activity; GPU near idle power. Duration set by pipeline parallelism
%   depth (PP - 1 micro-batches). This is the lowest-power phase.
% * *Stage 2: Forward Pass* --- High GEMM utilization with steady GPU
%   power draw. Tensor cores are active; power is dominated by compute.
% * *Stage 3: Backward Pass* --- Peak power phase from activation
%   recompute and memory pressure. The forward/backward split within each
%   micro-batch is 45/55%. This stage drives the worst-case bus capacitor
%   sizing.
% * *Stage 4: Communication + Sync* --- Ring all-reduce gradient
%   synchronization, Adam optimizer step, and cleanup. Network-burst
%   dominated; GPU compute drops back toward idle.
%
% This 4-stage model captures the three load transitions that drive
% electrical design decisions:
%
% * *Idle to Forward (inrush)* --- rapid ramp from near-idle to high
%   compute; sizes PFC bus capacitors and cable current ratings.
% * *Forward to Backward (peak)* --- transition to peak power; determines
%   worst-case voltage droop on the DC bus.
% * *Backward to Communication (load dump)* --- sudden drop from peak
%   compute to communication-dominated; drives voltage overshoot and BBU
%   energy absorption.
%
% *Inference* uses a roofline-based 4-stage model:
%
% * *Stage 1: Base Load* --- KV cache maintenance, background tasks.
%   Minimal GPU compute activity.
% * *Stage 2: Prefill* --- Compute-bound forward pass on the prompt
%   (GEMM, high tensor core utilization). Duration scales with prompt
%   token length. This produces a sharp power spike.
% * *Stage 3: Decode* --- Memory-bound autoregressive token generation
%   (HBM-limited). Steady, moderate power plateau. Duration scales with
%   output token count.
% * *Stage 4: Teardown* --- Output flush, return to baseline.
%
% Token lengths can be set via the |promptTokens| parameter (|tokenSource|
% = Fixed) or driven by an external signal connected to the |Tn(in)| input
% port (|tokenSource| = External). Use External mode to simulate
% time-varying request distributions.
%
% *Fine-Tuning* models LoRA/adapter training with periodic evaluation passes,
% reduced all-reduce payloads, and distinct compute/communication phases.

%% Ports
% *Outputs:*
%
% * *C* (|compute|) --- Total cluster compute demand in TFLOPS.
% * *U* (|U|) --- Cluster utilization fraction [0, 1].
%
% *Inputs:*
%
% * *Tn(in)* (|promptLenIn|) --- External prompt token length (used when
%   |tokenSource| = External). Connect a signal source or leave
%   unconnected when using Fixed token length.

%% Parameters
% *Configuration (always visible):*
%
% * *GPU model*, |gpuModel|, enumeration. Selects hardware preset for peak
%   TFLOPS, HBM bandwidth, and inter-node bandwidth. Options:
%   |RubinUltra|, |B200|, |H200|, |H100|, |A100|, |MI300X|, |MI325X|,
%   |Gaudi3|, |Custom|. Default: |B200|.
% * *Total GPU count*, |numGPUs|, scalar. Default: |288|.
% * *Workload type*, |workloadType|, enumeration. Options: |Training|,
%   |Inference|, |FineTuning|. Default: |Training|.
% * *Time compression factor*, |timeScale|, scalar. 1 = real-time,
%   12 = compress 178 s cycle into ~15 s. Default: |1|.
% * *Token length source*, |tokenSource|, enumeration. |Fixed| uses the
%   |promptTokens| parameter; |External| reads from the input port.
%   Default: |Fixed|.
% * *Show advanced parameters*, |showAdvanced|, logical. Reveals hardware,
%   training, inference, efficiency, fine-tuning, and output groups.
%   Default: |false|.
%
% *Hardware (advanced):*
%
% * *Peak TFLOPS*, |customPeakTFLOPS|. Used when GPU model = Custom.
%   Default: |1000|.
% * *HBM bandwidth*, |customHbmBW|, in bytes/s. Default: |4e12|.
% * *Inter-node bandwidth*, |interNodeBW|, in bytes/s. Default: |50e9|.
% * *LLM model size*, |llmSize|, enumeration. Options: |Llama7B|,
%   |Llama13B|, |Llama70B|, |GPT175B|, |Llama405B|, |Custom|.
%   Default: |Llama70B|.
% * *Billion parameters*, |customNumParamsB|. Default: |70|.
% * *Transformer layers*, |customNumLayers|. Default: |80|.
% * *Bytes per param*, |customPrecision|. 2 = BF16, 1 = FP8, 4 = FP32.
%   Default: |2|.
% * *Parallelism strategy*, |parallelism|, enumeration. Options:
%   |TP8PP4|, |TP4PP8|, |TP8PP8|, |TP4PP4|, |Custom|.
%   Default: |TP8PP4|.
% * *Tensor parallelism*, |customTP|. Default: |8|.
% * *Pipeline parallelism*, |customPP|. Default: |4|.
%
% *Training (advanced):*
%
% * *Micro-batch size*, |microBatch|. Default: |8|.
% * *Global batch size*, |globalBatch|. Default: |2048|.
% * *Sequence length*, |seqLength|, in tokens. Default: |2048|.
% * *Stage 1: Idle utilization*, |idleUtil|. Pipeline bubble + data load.
%   Default: |0.05|.
% * *Stage 2: Forward pass utilization*, |fwdUtil|. Default: |0.85|.
% * *Stage 3: Backward pass utilization*, |bwdUtil|. Peak power stage.
%   Default: |0.92|.
% * *Stage 4: Communication utilization*, |commSyncUtil|. All-reduce +
%   optimizer + cleanup. Default: |0.15|.
%
% *Inference (advanced):*
%
% * *Prompt length*, |promptTokens|, in tokens. Default: |512|.
% * *Output length*, |outputTokens|, in tokens. Default: |256|.
% * *Concurrent requests*, |numConcurrent|. Default: |8|.
% * *Batch size*, |batchSize|. Default: |8|.
% * *AllReduce latency per layer*, |allreduceLatency|, in s. Default: |5e-6|.
% * *Base inference utilization*, |baseInfUtil|. Default: |0.08|.
% * *Base load fraction*, |baseInfFrac|. Fraction of inference period for
%   base load (split equally before prefill and after decode). Default: |0.10|.
%
% *Efficiency (advanced):*
%
% * *Model FLOP Utilization*, |MFU|. Compute-phase efficiency. Default: |0.85|.
% * *Checkpoint overhead*, |checkpointOverhead|. Time fraction. Default: |0.03|.
% * *Straggler overhead*, |stragglerOverhead|. Time fraction. Default: |0.02|.
%
% *Fine-Tuning (advanced):*
%
% * *Trainable parameter fraction*, |trainableParamFrac|. LoRA ~2%.
%   Default: |0.02|.
% * *Eval interval*, |evalInterval|, in training steps. Default: |5|.
% * *Eval batches*, |evalBatches|. Default: |2|.
% * *Fine-tune checkpoint overhead*, |ftCheckpointOverhead|. Default: |0.05|.
%
% *Output (advanced):*
%
% * *Enable noise*, |enableNoise|, logical. Adds quasi-random variation
%   from 7 incommensurate sine oscillators (realistic DVFS + straggler
%   jitter). Default: |true|.
% * *Noise amplitude*, |noiseAmplitude|. Peak fraction of nominal.
%   Default: |0.08|.
% * *Step jitter*, |stepJitter|. Step period variation fraction.
%   Default: |0.15|.
% * *Enable filter*, |enableFilter|, logical. Low-pass smoothing on output.
%   Default: |false|.
% * *Filter time constant*, |filterTimeConstant|, in s. Default: |0.01|.

%% Observable Variables
% The following signals are available for logging via Simscape data logging
% (|ExternalAccess = observe|):
%
% * |phaseId| --- Integer phase identifier (1 = forward, 2 = backward,
%   4 = comm/sync, 6 = idle, 7 = prefill, 8 = decode, 13 = base load).
% * |utilization| --- Cluster utilization fraction [0, 1].
% * |stepCount| --- Approximate training step counter.
% * |tcUtilization| --- Tensor core utilization (inference roofline).
% * |hbmUtilization| --- HBM bandwidth utilization (inference roofline).
% * |tokensPerSecObs| --- Token throughput (inference, tokens/s).
% * |ttftObs| --- Time to first token (inference, s).

%% See Also
% * |datacenter.pfcStage| --- PFC boost rectifier that regulates the DC bus
%   voltage supplying the IT load driven by this compute profile.
% * |DocumentationUtilizationConverter| --- Utility for converting rack
%   utilization matrices.
