% SSTRideThrough - Configure model for ERCOT LVRT scenario
% Applies the ERCOT ascending staircase voltage profile to test SST
% ride-through capability at each LVRT range threshold.
% Uses same mixed workload profile as Case 2 (NLR training + roofline inference).

% Copyright 2026 The MathWorks, Inc.

if ~exist('modelName', 'var'), modelName = 'HyperscaleDataCenter'; end

% Apply realistic mixed GPU utilization (same as MixedWorkload.m)
MixedWorkload;

% Apply ERCOT ascending staircase LVRT profile
lvrtGridCode = sstLvrt.getProfile('ERCOT_Ascending');
lvrt.startTime = 3.0;
lvrtProfile = sstLvrt.buildProfile(lvrtGridCode, Ts, 10, lvrt.startTime);
