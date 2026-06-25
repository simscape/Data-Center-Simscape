% Function to calculate unit vector on building walls, roofs, and floors.

% Copyright 2024 The MathWorks, Inc.

function [posX,posY] = getUnitVectorFromPointToLine(ptCoord,ptOnTheLine)
    % Assumption:
    %     East == positive X axis
    %     West == negative X axis
    %    North == positive Y axis
    %    South == negative Y axis
    oneUnitStep = 1;
    posX = 0;
    posY = 0;
    xPoint = ptCoord(1,1);
    yPoint = ptCoord(1,2);
    xLinePt = ptOnTheLine(1,1);
    yLinePt = ptOnTheLine(1,2);

    if xPoint == xLinePt && yPoint == yLinePt
         disp('Error in room definition. Centroid ')
    elseif yPoint == yLinePt
        if xPoint > xLinePt
            % Facing West
            posX = -oneUnitStep;
        else
            % Facing East
            posX = oneUnitStep;
        end
    elseif xPoint == xLinePt
        if yPoint > yLinePt
            % Facing South
            posY = -oneUnitStep;
        else
            % Facing North
            posY = oneUnitStep;
        end
    else
        % Could be NE, NW, SE, or SW. Check in which quadrant the direction
        % points to (0,0 - global center)
        posX = (xLinePt-xPoint)/sqrt((yLinePt-yPoint)^2+(xLinePt-xPoint)^2);
        posY = (yLinePt-yPoint)/sqrt((yLinePt-yPoint)^2+(xLinePt-xPoint)^2);
    end
end
