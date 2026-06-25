function htc = vanadiumRedoxFlowHTC(v)
% Calculates the approximate heat transfer coefficient value inside the 
% VRFB container. This HTC value influences the heat transfer from stacks
% to the container wall and to the ambient. The fluid velocity 'v' must be
% in units of m/s.

% Copyright 2025 The MathWorks, Inc.

    htc = max(5,1.163*(10.45-v+10*sqrt(v)));
end