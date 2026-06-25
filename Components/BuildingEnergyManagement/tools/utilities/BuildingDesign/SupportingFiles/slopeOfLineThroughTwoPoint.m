% Function to find slope of line through two points.

% Copyright 2024 The MathWorks, Inc.

function [m, c] = slopeOfLineThroughTwoPoint(twoPoints,tolr)
    x1 = twoPoints(1,1);
    y1 = twoPoints(1,2);
    x2 = twoPoints(2,1);
    y2 = twoPoints(2,2);

    if abs(x1-x2)<tolr*abs(x1) || x1 == x2
        m = 90;
        c = x1;
    elseif abs(y1-y2)<tolr*abs(y1) || y1 == y2
        m = 0;
        c = y1;
    else
        if (y2-y1)/(x2-x1) < 0
            m = round(180+rad2deg(atan((y2-y1)/(x2-x1))), 1);
        else
            m = round(rad2deg(atan((y2-y1)/(x2-x1))), 1);
        end
        c = round(y2 - ((y2-y1)/(x2-x1)) *x2, 2);
    end
end