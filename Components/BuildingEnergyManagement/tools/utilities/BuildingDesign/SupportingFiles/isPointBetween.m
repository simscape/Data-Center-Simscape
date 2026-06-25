% To check if a point lies between two other points, within a certain
% tolerance value.

% Copyright 2024 The MathWorks, Inc.

function res = isPointBetween(chkPt,pt1,pt2,tolr)
    if abs(sqrt(sum((chkPt-pt1).^2)) + sqrt(sum((chkPt-pt2).^2)) - sqrt(sum((pt1-pt2).^2))) < tolr*sqrt(sum((pt1-pt2).^2))
        res = 1;
    else
        res = 0;
    end
end