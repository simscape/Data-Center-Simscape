%% CHB Module (Average Model)
% Average model of a single H-bridge cell of a Cascaded H-Bridge (CHB)
% converter. The four switches are not modelled individually. Instead the
% cell is described by the average relationships
%
%  v_ac = m * v_dc
%  i_dc = m * i_ac
%
% where _m_ is the modulation index input. Because no switching events are
% generated, the component runs with a large solver step and is intended for
% system-level studies rather than for switching-ripple or EMI analysis.
%
% The component has an input port _m_, two AC electrical ports *AC+* and
% *AC-*, and two DC electrical ports *DC+* and *DC-*. Connect several
% modules in series on the AC side to build a phase leg. Each module needs
% its own DC source or capacitor on the DC side.

% Copyright 2026 The MathWorks, Inc.

%% Parameters
% * *On-state resistance (total per leg) (Ohm)*, |OnResistance|, specified as a scalar value. Default is |1e-3|.
% * *Nominal grid voltage (L-L RMS) (V)*, |GridVoltage|, specified as a scalar value. Default is |13800|.
% * *Total DC voltage per phase (N * initial DC voltage) (V)*, |TotalDCVoltage|, specified as a scalar value. Default is |13200|.

%% Modulation Scaling
% The input _m_ is not applied directly. It is first scaled by an internal
% gain derived from the two voltage parameters, then clamped to the range
% -1 to 1:
%
%  ModulationGain = GridVoltage / (sqrt(3/2) * TotalDCVoltage)
%  ref            = min(max(m * ModulationGain, -1), 1)
%
% With the default values the gain is approximately |0.854|. This means the
% controller upstream of the block can work in per-unit terms without an
% additional external scaling gain. If you add your own scaling gain outside
% the block, the modulation index is scaled twice and the control loop gains
% must be retuned.

%% Equations
% The average H-bridge relationships implemented by the component are
%
%  v_ac == ref * v_dc + OnResistance * i_ac
%  i_dc == -ref * i_ac
%
% where |v_ac| is the voltage across *AC+* and *AC-* and |v_dc| is the
% voltage across *DC+* and *DC-*. The conduction drop
% |OnResistance * i_ac| accounts for the combined switch and wiring loss of
% the cell.

%% Internal Reference Connection
% The *DC-* node of the module is connected internally to the electrical
% domain reference. The DC bus of each module is therefore *not floating*.
% Take this into account when connecting module DC buses to downstream
% converters, and do not add a second reference to the same DC node.

%% Variables
% The following variables are exposed for logging and for setting initial
% targets: |iAC|, |vAC|, |iDC|, |vDC|, and |vOn|. The variable |vDC| is
% declared with priority *None*, so it does not act as an initial-condition
% target by default. Set the DC bus initial voltage on the capacitor or
% source connected to the DC ports instead.

%% References
% Modulation and average-value modelling of cascaded H-bridge converters is
% covered in standard multilevel-converter references. The component
% implements the classical fundamental-frequency average model, in which the
% switching function is replaced by its local average value _m_.
