% Function to find doors for internal wall plot

% Copyright 2024-2025 The MathWorks, Inc.

function [X,Y,Z] = getPatchCoordinatesForIntWallDoors(wallVert_X,wallVert_Y,wallVert_Z,solidWallAreaFrac)
    midVal_X = mean(wallVert_X);
    midVal_Y = mean(wallVert_Y);
    midVal_Z = mean(wallVert_Z);
    X = wallVert_X;
    Y = wallVert_Y;
    Z = wallVert_Z;

    delta_x = mean(wallVert_X(wallVert_X>midVal_X)) - mean(wallVert_X(wallVert_X<midVal_X));
    delta_y = mean(wallVert_Y(wallVert_Y>midVal_Y)) - mean(wallVert_Y(wallVert_Y<midVal_Y));
    delta_z = mean(wallVert_Z(wallVert_Z>midVal_Z)) - mean(wallVert_Z(wallVert_Z<midVal_Z));

    for i = 1:4
        if wallVert_X(1,i) < midVal_X
            X(1,i) = X(1,i) + delta_x*(solidWallAreaFrac)/2;
        else
            X(1,i) = X(1,i) - delta_x*(solidWallAreaFrac)/2;
        end
        if wallVert_Y(1,i) < midVal_Y
            Y(1,i) = Y(1,i) + delta_y*(solidWallAreaFrac)/2;
        else
            Y(1,i) = Y(1,i) - delta_y*(solidWallAreaFrac)/2;
        end
        if wallVert_Z(1,i) < midVal_Z
            Z(1,i) = Z(1,i) ;
        else
            Z(1,i) = Z(1,i) - 2*delta_z*(solidWallAreaFrac)/2;
        end
    end
end