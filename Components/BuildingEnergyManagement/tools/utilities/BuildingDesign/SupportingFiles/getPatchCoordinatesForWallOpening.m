% Function to find window or vent patch size for wall plot

% Copyright 2024 - 2025 The MathWorks, Inc.

function [X,Y,Z] = getPatchCoordinatesForWallOpening(wallVert_X,wallVert_Y,wallVert_Z,openingAreaFrac)
    midVal_X = mean(wallVert_X);
    midVal_Y = mean(wallVert_Y);
    midVal_Z = mean(wallVert_Z);
    X = wallVert_X;
    Y = wallVert_Y;
    % Z = wallVert_Z;
    if max(X) == min(X)
        % No change in X, calculating deltaX would give NaN
        delta_x = 0;
    else
        delta_x = max(wallVert_X) - min(wallVert_X);%mean(wallVert_X(wallVert_X>midVal_X)) - mean(wallVert_X(wallVert_X<midVal_X));
    end
    if max(Y) == min(Y)
        % No change in Y, calculating deltaY would give NaN
        delta_y = 0;
    else
        delta_y = max(wallVert_Y) - min(wallVert_Y);%mean(wallVert_Y(wallVert_Y>midVal_Y)) - mean(wallVert_Y(wallVert_Y<midVal_Y));
    end

    wall = [wallVert_X;wallVert_Y;wallVert_Z];
    wallLen1 = sqrt(sum((wall(:,1)-wall(:,2)).^2));
    wallLen2 = sqrt(sum((wall(:,2)-wall(:,3)).^2));
    openingLen1 = sqrt(openingAreaFrac)*wallLen1;
    openingLen2 = sqrt(openingAreaFrac)*wallLen2;

    diffZ = diff(wallVert_Z);
    % This assumed Z direction is along vertical and along the building
    % vertical direction.
    if diffZ(1,1) == 0
        refZchange = [1 1 -1 -1]*openingLen2/2;
        refXYchange = openingLen1;
    else
        refZchange = [1 1 -1 -1]*openingLen1/2;
        refXYchange = openingLen2;
    end
    Z = midVal_Z+refZchange;

    fx = delta_x/sqrt(delta_x^2+delta_y^2);
    fy = delta_y/sqrt(delta_x^2+delta_y^2);

    for i = 1:4
        if wallVert_X(1,i) < midVal_X
            X(1,i) = midVal_X - fx*refXYchange/2;
        else
            X(1,i) = midVal_X + fx*refXYchange/2;
        end
    end
    for i = 1:4
        if wallVert_Y(1,i) < midVal_Y
            Y(1,i) = midVal_Y - fy*refXYchange/2;
        else
            Y(1,i) = midVal_Y + fy*refXYchange/2;
        end
    end
end