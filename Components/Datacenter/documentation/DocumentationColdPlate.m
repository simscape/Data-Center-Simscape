%% Cold Plate

% Copyright 2026 The MathWorks, Inc.

%% Cold Plate
% This block models a cold plate in a liquid cooled data center. The cold
% plate is modeled as pipes and channels taking the heat away from the
% *Server Tray* blocks.
%
% * *Cold plate pipe length (m)*, |pipeLen|, specified as a scalar value.
% * *Pipe cross-section area (m^2)*, |pipeArea|, specified as a scalar value.
% * *Pipe hydraulic diameter (m)*, |pipeDia|, specified as a scalar value.
% * *Aggregate equivalent length of local resistances (m)*, |pipeLenXtra|, specified as a scalar value.
% * *IT tray to cold plate thermal resistance (K/W)*, |thermalR|, specified as a scalar value.

%% Initial Conditions
% * *Initial temperature (K)*, |initialT|, specified as a scalar value.
% * *Initial pressure (MPa)*, |initialP|, specified as a scalar value.

