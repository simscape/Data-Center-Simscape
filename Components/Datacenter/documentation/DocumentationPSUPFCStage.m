%% PSU PFC (Average Model) Block
% This block models an average-value PFC (Power Factor Correction) boost
% rectifier with PI voltage loop for data center power supply units. It
% converts single-phase AC input to regulated DC output at a target bus
% voltage, using physical inductor dynamics on the AC side and a controlled
% current source on the DC side.
%
% <<icon_psuPFC.png>>

% Copyright 2026 The MathWorks, Inc.

%% Overview
% The PSU PFC Stage block is an average-value representation of a PFC boost
% rectifier that avoids switching-level simulation while preserving the
% essential voltage-loop dynamics relevant for system-level stability
% analysis. The model captures:
%
% * *PI voltage loop* on the DC bus error (Vref - Vdc), producing a
%   power reference that commands the AC-side current.
% * *Inner current loop* with physical AC inductor dynamics (Lac, Rac)
%   and a bandwidth of approximately 10 kHz, providing unity power factor
%   tracking.
% * *Constant-power load (CPL) characteristic* on the DC side: the
%   controlled current source delivers I = Pref/Vdc, creating a negative
%   incremental conductance.
% * *Anti-windup integrator* that freezes when the power reference saturates
%   at the Pmax clamp or when AC voltage is below threshold.
% * *Parallel damping conductance* Gdamp on the DC bus for additional
%   resistive stabilization.
%
% The block can be parameterized to represent a single PFC unit or a lumped
% equivalent of N parallel units by scaling Cdc, Kp, Ki, Pmax, Lac, and
% Rac accordingly. The critical stability gain scales as
% Kpcrit = Pload / Vdc.

%% Ports
% *Electrical (Simscape physical signals):*
%
% * *AC+ (p)* and *AC- (n)* --- Single-phase AC input (left side).
% * *DC+ (dcp)* and *DC- (dcn)* --- Regulated DC output (right side).
%   Connect to IT Tray, DC-DC converter, or other DC loads.

%% Parameters
% *PFC Parameters:*
%
% * *DC bus capacitance*, |Cdc|, specified in F. Default: |2e-3|.
% * *DC bus voltage setpoint*, |VdcRef|, specified in V. Default: |400|.
% * *Voltage loop proportional gain*, |KpPfc|, specified in W/V.
%   Default: |1.0|.
% * *Voltage loop integral gain*, |KiPfc|, specified in W/(V*s).
%   Default: |60|.
% * *PFC efficiency*, |etaPfc|, dimensionless. Default: |0.97|.
% * *Maximum PFC power rating*, |Pmax|, specified in W. The PI power
%   reference is clamped to [0, 1.2 * Pmax]. Default: |130000|.
% * *Parallel damping conductance*, |Gdamp|, specified in S (1/Ohm).
%   Adds a resistive current Gdamp * vac to the AC reference.
%   Default: |0.02|.
% * *RMS voltage filter time constant*, |tauRms|, specified in s. First-order
%   filter on vac^2 for the RMS calculation. Default: |0.040|.
% * *Nominal AC RMS voltage*, |Vnom|, specified in V. Used for AC enable
%   logic and RMS normalization. Default: |277|.
%
% *AC Inductor:*
%
% * *AC boost inductor inductance*, |Lac|, specified in H. Default: |0.5e-3|.
% * *AC inductor series resistance*, |Rac|, specified in Ohm. Default: |0.01|.

%% See Also
% * |datacenter.computeProfileSource| --- Workload generator that drives IT
%   load connected to the PFC DC bus.
% * |DocumentationUtilizationConverter| --- Utility for converting rack
%   utilization matrices.
