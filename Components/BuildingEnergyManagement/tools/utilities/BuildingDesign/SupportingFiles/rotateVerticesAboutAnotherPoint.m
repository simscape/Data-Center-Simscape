% Internal function to rotate a point about another one.

% Copyright 2024 The MathWorks, Inc.

function [delX,delY] = rotateVerticesAboutAnotherPoint(vertex,rotateAboutVertex,degVal)
    relVec = vertex - rotateAboutVertex;
    if relVec(1,1) < 0
        signX = -1;
    else
        signX = 1;
    end
    if relVec(1,2) < 0
        signY = -1;
    else
        signY = 1;
    end
    l = sqrt(sum(relVec.^2));
    degValRel = rad2deg(atan(relVec(1,2)/relVec(1,1)));
    if (signX < 0 && signY > 0) || (signX < 0 && signY < 0)
        % Q2 or Q3
        degValRel = 180+degValRel;
    end
    if signX > 0 && signY < 0
        % Q4
        degValRel = 360+degValRel;
    end
    delX = l*cos(deg2rad(degValRel)) - l*cos(deg2rad(degValRel+degVal));
    delY = l*sin(deg2rad(degValRel)) - l*sin(deg2rad(degValRel+degVal));
end