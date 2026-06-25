function [finalRectangles,rectPatchX,rectPatchY,roomHeight,maxZ] = getPatchForRoom(NameValueArgs)
% Function to get patch for a room.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.X (:,1) {mustBeNonempty}
        NameValueArgs.Y (:,1) {mustBeNonempty}
        NameValueArgs.Z (:,1) {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.RoomPlotName string {mustBeNonempty} = "Plot Name"
    end

    plotNameDisp = strcat(NameValueArgs.RoomPlotName," (floorplan)");
    listOfLevelZ = unique(NameValueArgs.Z);
    minZ = listOfLevelZ(1,1);
    maxZ = listOfLevelZ(end,1);
    roomHeight = mean(abs(diff(listOfLevelZ)));
    findAllMinZVal = NameValueArgs.Z==minZ;
    floorPlanPoints = [NameValueArgs.X(findAllMinZVal,1),NameValueArgs.Y(findAllMinZVal,1)];
    
    distFloorPlanPtsOrigin = sum(floorPlanPoints.^2,2);
    findUniquePts = unique(distFloorPlanPtsOrigin);
    totalNumPts = length(findUniquePts);
    finalPointList = zeros(totalNumPts,2);
    for i = 1:totalNumPts
        listOfPtIndx = find(distFloorPlanPtsOrigin==findUniquePts(i,1));
        finalPointList(i,:) = floorPlanPoints(listOfPtIndx(1,1),:);
    end

    figure("Name",strcat("Marker Points for ",plotNameDisp));
    plot(finalPointList(:,1),finalPointList(:,2),"o");hold on;
    for i = 1:size(finalPointList,1)
        text(finalPointList(i,1),finalPointList(i,2),strcat("p#",num2str(i)));
    end
    minX = min(finalPointList(:,1));
    maxX = max(finalPointList(:,1));
    minY = min(finalPointList(:,2));
    maxY = max(finalPointList(:,2));
    boundingBox = polyshape([minX,minX,maxX,maxX],[minY,maxY,maxY,minY]);
    boundingBox.plot;
    title(strcat("Marker Points for ",plotNameDisp));
    hold off 

    boundingBox_m = zeros(1,4); boundingBox_c = zeros(1,4); boundingBox_l = zeros(1,4);

    for j = 1:4
        if j == 4
            i1 = j; i2 = 1;
        else
            i1 = j; i2 = j+1;
        end
        [boundingBox_m(1,j),boundingBox_c(1,j)] = ...
            slopeOfLineThroughTwoPoint(boundingBox.Vertices([i1,i2],:),0.01);
        boundingBox_l(1,j) = ...
            round(sqrt(sum((boundingBox.Vertices(i1,:)-boundingBox.Vertices(i2,:)).^2)),2);
    end
    
    shortList = [];
    for i = 1:totalNumPts
        for j = 1:totalNumPts
            if j ~= i
                [m,~] = slopeOfLineThroughTwoPoint([finalPointList(i,:);finalPointList(j,:)],0.01);
                if ismembertol(m,boundingBox_m(1,1),0.01) || ismembertol(m,boundingBox_m(1,2),0.01)
                    shortList = [shortList;[i,j,m]];
                end
            end
        end
        dispShortList = shortList(shortList(:,1)==i,:);
        if NameValueArgs.Debug, disp(strcat("*** For pt#",num2str(i),", possible point are #",mat2str(dispShortList))); end
    end
    
    
    slopeOptions = [boundingBox_m(1,1),boundingBox_m(1,2)];
    rectangleList = [];
    for i = 1:totalNumPts
        % Start march towards finding a rectangle.
        % disp(i)
        possiblePt2 = shortList(shortList(:,1)==i,:);
        if size(possiblePt2,1) > 0
            for pt2 = 1:size(possiblePt2,1)
                m2 = possiblePt2(pt2,3); % 3rd column stores the slope value
                j2 = possiblePt2(pt2,2); % 2nd column stores next point data
                if j2 ~= i
                    % Next point must be at 90deg turn and hence slope must be
                    % different
                    if ismembertol(m2,slopeOptions(1,1),0.01)
                        find_m2 = slopeOptions(1,2);
                    else
                        find_m2 = slopeOptions(1,1);
                    end
                    possiblePt3 = shortList(and(shortList(:,1)==j2,shortList(:,3)==find_m2),:);
                    if size(possiblePt3,1) > 0
                        for pt3 = 1:size(possiblePt3,1)
                            m3 = possiblePt3(pt3,3);
                            j3 = possiblePt3(pt3,2);
                            if j3 ~=j2
                                if ismembertol(m3,slopeOptions(1,1),0.01)
                                    find_m3 = slopeOptions(1,2);
                                else
                                    find_m3 = slopeOptions(1,1);
                                end
                                possiblePt4 = shortList(and(shortList(:,1)==j3,shortList(:,3)==find_m3),:);
                                if size(possiblePt4,1) > 0
                                    for pt4 = 1:size(possiblePt4,1)
                                        m4 = possiblePt4(pt4,3);
                                        j4 = possiblePt4(pt4,2);
                                        if j4 ~= j3
                                            if ismembertol(m4,slopeOptions(1,1),0.01)
                                                find_m4 = slopeOptions(1,2);
                                            else
                                                find_m4 = slopeOptions(1,1);
                                            end
                                            chkReturnToStartPt = shortList(and(shortList(:,1)==j4,shortList(:,3)==find_m4),:);
                                            if size(chkReturnToStartPt,1) > 0
                                                for chk = 1:size(chkReturnToStartPt,1)
                                                    if chkReturnToStartPt(chk,2) == i
                                                        checkDataSet = [i,j2,j3,j4];
                                                        rectangleList = [rectangleList;checkDataSet];
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    [~,idx] = unique(sort(rectangleList,2),"rows");
    finalRectangles = rectangleList(idx,:);
    rectPatchX = zeros(length(idx),4);
    rectPatchY = zeros(length(idx),4);
    rectColor = rand(length(idx),1);
    
    for i = 1:length(idx)
        rectPatchX(i,:) = finalPointList(finalRectangles(i,:)',1);
        rectPatchY(i,:) = finalPointList(finalRectangles(i,:)',2);
    end
    
    figure("Name",plotNameDisp);
    patch(rectPatchX',rectPatchY',rectColor');
    title(plotNameDisp);
end