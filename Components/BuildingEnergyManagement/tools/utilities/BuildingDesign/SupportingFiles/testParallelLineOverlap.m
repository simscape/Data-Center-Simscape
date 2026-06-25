% Function to test if two parallel lines of finite length overlap or are
% separated by some distance in the plane. This is used while finding room
% overlap data from floorplans.

% Copyright 2024 The MathWorks, Inc.

function overlapValue = testParallelLineOverlap(wallCoord,testCoord,tolr)
    overlapSuccess = 0;
    % Check x and y axis projections for overlap: wall segment larger than
    % check points

    baselineX1 = wallCoord(1,1);
    baselineY1 = wallCoord(1,2);
    baselineX2 = wallCoord(2,1);
    baselineY2 = wallCoord(2,2);
    if any(testCoord(:,2)>=min(baselineY1,baselineY2)) && any(testCoord(:,2)<=max(baselineY1,baselineY2)) && ...
       any(testCoord(:,1)>=min(baselineX1,baselineX2)) && any(testCoord(:,1)<=max(baselineX1,baselineX2))
        overlapSuccess = 1;
    end
    % Check x and y axis projections for overlap: test segment larger than
    % the wall check points
    baselineX1 = testCoord(1,1);
    baselineY1 = testCoord(1,2);
    baselineX2 = testCoord(2,1);
    baselineY2 = testCoord(2,2);
    if any(wallCoord(:,2)>=min(baselineY1,baselineY2)) && any(wallCoord(:,2)<=max(baselineY1,baselineY2)) && ...
       any(wallCoord(:,1)>=min(baselineX1,baselineX2)) && any(wallCoord(:,1)<=max(baselineX1,baselineX2))
        overlapSuccess = 1;
    end

    if overlapSuccess == 1
        xw1 = wallCoord(1,1);
        yw1 = wallCoord(1,2);
        xw2 = wallCoord(2,1);
        yw2 = wallCoord(2,2);

        xe1 = testCoord(1,1);
        ye1 = testCoord(1,2);
        xe2 = testCoord(2,1);
        ye2 = testCoord(2,2);

        lenWall = sqrt((xw1-xw2)^2+(yw1-yw2)^2);
        distPts = sqrt((xe1-xe2)^2+(ye1-ye2)^2);
        lenE1 = sqrt((xw1-xe1)^2+(yw1-ye1)^2) + sqrt((xw2-xe1)^2+(yw2-ye1)^2) - lenWall;
        lenE2 = sqrt((xw1-xe2)^2+(yw1-ye2)^2) + sqrt((xw2-xe2)^2+(yw2-ye2)^2) - lenWall;

        if lenE1 > tolr*lenWall
            % Point e1 outside the line joining both wall vertices
            optionE1 = 0;
        else
            optionE1 = 1;
        end
        if lenE2 > tolr*lenWall
            % Point e2 outside the line joining both wall vertices
            optionE2 = 0;
        else
            optionE2 = 1;
        end

        if optionE1 == 0 && optionE2 == 0
            overlapValue = overlapSuccess*1;
        elseif optionE1 == 1 && optionE2 == 1
            overlapValue = overlapSuccess*min(1,max(0,distPts/lenWall));
        elseif optionE1 == 0 && optionE2 == 1
            overlapValue = overlapSuccess*min(1,max(0,max(sqrt((xw1-xe2)^2+(yw1-ye2)^2),sqrt((xw2-xe2)^2+(yw2-ye2)^2))/lenWall));
        else
            % optionE1 == 1 && optionE2 == 0
            overlapValue = overlapSuccess*min(1,max(0,max(sqrt((xw1-xe1)^2+(yw1-ye1)^2),sqrt((xw2-xe1)^2+(yw2-ye1)^2))/lenWall));
        end
    else
        overlapValue = 0;
    end
end