function shuntR = vanadiumRedoxFlowShuntRes(Ns,Nc,Rp,Rc)
% Calculates the approximate shunt resistance value assuming an electrical 
% ladder network like structure for manifolds to the individual stacks.

% Copyright 2023 The MathWorks, Inc.

    Rc0   = Rc*Nc;
    Reff  = Rc0;
    if Ns > 1
        for sNum = Ns:-1:2
            Rseries = 2*Rp+Reff;
            Reff    = 1/(1/Rseries+1/Rc0);
        end
    end
    shuntR = 2*Rp+Reff;
end