% Copyright 2026 The MathWorks, Inc.

% N+1 redundancy
model = "UPSControl";
blockPath = strcat(model,'/','Server Load','/','UPS Units');
set_param(blockPath,'upsConfiguration','Three UPS Parallel');
loadPower = 10e6;
lvrtProfileName = 'None';

% Size the rack fleet to loadPower and leave utilization at its design value.
% Raising utilizationFactor is not a way to reach loadPower: the Server Chip
% power curves saturate (GPU compute goes as 2*U - U^gpuExponent, HBM as
% min(gpuHBMutil*U + 0.1, 1)), so the 5 racks that ServerRackParam sizes for a
% 5 MW peak top out near 8.4 MW even at U = 1. PDU Racks multiplies one
% representative tray by nTrays*nRacks, so power is exactly linear in nRacks
% and the trim in rack.efficiencyGain stays valid because the utilization
% range it was fitted over does not move. One 144-tray rack per MW of load.
rack.nRacks = loadPower/1e6;
utilizationFactor = 0.45;

% Reading the per-UPS power plot: the N+1 result is the steady-state sharing,
% where UPS1 and UPS2 settle at 0.92 pu each and UPS3 sits at 0 once its
% breaker opens. The 1.09 pu peak is a transient, not an oversize: breaker.UPS
% opens a module at t = 5 s, which is exactly where tokenRateWaypoints puts its
% maximum rate (0.90), so the trip lands on the compute peak by construction.
% It stays clear of the ups.iLimit.value = 1.2 limiter, and the single-UPS
% default case peaks at 1.06 pu for the same reason, so it is not specific to
% this configuration. Exactly 1.00 pu would need a 9.75 MW load peak, i.e.
% 9.4 racks, so it is not reachable with an integer count of 144-tray racks.
% Do not chase it by setting rack.efficiencyGain to 1: that gain is shared with
% the default case, which would then deliver 4.72 MW against a 5 MW design
% point, and it discards the calibration against the Server Unit load.

parasiticConductance = 0;
breaker.grid = 40;
breaker.generator = 45;
breaker.UPS = 5;
lvrtProfile = lvrtTest.buildLvrtProfile(lvrtTest.getLVRTProfile('None'), Ts, 10, lvrt.startTime);