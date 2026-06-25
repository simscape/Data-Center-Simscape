% Function to find unit vector for sides of a building.

% Copyright 2024 The MathWorks, Inc.

function unitDirVec = getUnitDirectionVecForAllSides(vert)
    cntP = mean(vert);
    unitDirVec = zeros(size(vert,1),2);
    for i = 1:size(vert,1)
        if i < size(vert,1) 
            ptXY = vert(i:i+1,:);
        else
            ptXY = vert([i,1],:);
        end
        ptOnLine = mean(ptXY);
        [posX, posY] = getUnitVectorFromPointToLine(cntP,ptOnLine);
        unitDirVec(i,1) = posX;
        unitDirVec(i,2) = posY;
    end
end