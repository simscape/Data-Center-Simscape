% Function to estimate external wall fraction exposed to ambient.

% Copyright 2024 - 2025 The MathWorks, Inc.

function updatedBuilding = estimateExtWallSurfAreaFracToAmbient(bldgName,building,tolr)
    updatedBuilding = building;
    numApartments = numel(fieldnames(building));
    % listExternalWallData = zeros(:,9); 
    % Column 1:3 for i,j,k; Column 4,5 for WIN/VENT fraction and Column 6-9 for (x1,y1) & (x2,y2)
    listExternalWallData = [];

    for i = 1:numApartments
        numRooms = numel(fieldnames(building.("apartment"+num2str(i))));
        for j = 1:numRooms
            updatedBuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.partOfBuilding = bldgName;
            roomVerticesMat = building.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan.Vertices;
            numSidesRoom = size(roomVerticesMat,1);
            %
            for k = 1:numSidesRoom
                extVer2D = building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVertices;
                lenData = size(extVer2D,1);
                
                wallCoord = building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices(1:2,1:2)';
                [m1,c1] = slopeOfLineThroughTwoPoint(wallCoord,tolr);

                wallLength = sqrt(sum(wallCoord(:,1).^2) + sum(wallCoord(:,2).^2));
                wallSurfFrac = 0;
                ventSurfFracVal = 0;
                windowSurfFracVal = 0;

                %% listExternalWallDataItr = zeros(1,9);
                % A wall can be connected to 2 external walls too - in case
                % of a T shaped wall (edge case) and hence there may be
                % more than one vertices to be recorded.
                
                for itr = 1:lenData
                    listExternalWallDataItr = zeros(1,9);
                    % A wall can be connected to 2 external walls too - in case
                    % of a T shaped wall (edge case) and hence there may be
                    % more than one vertices to be recorded.
                    if itr < lenData
                        testCoord = extVer2D(itr:itr+1,:);
                    else
                        testCoord = extVer2D([itr,1],:);
                    end
                    [m2,c2] = slopeOfLineThroughTwoPoint(testCoord,tolr);
                    
                    if ismembertol(m1,m2,tolr) && ismembertol(c1,c2,tolr)
                        [wallFracVal,overlapVertices] = testParallelLineOverlapLength(testCoord,wallCoord,tolr);
                        % disp(strcat("*** For Apt/Room",num2str(i),"/",num2str(j),": wallfrac = ",num2str(wallFracVal)));
                        % disp("Ext Wall Vertices:");
                        % disp(testCoord);
                        % disp(" ");
                        % disp("Room Vertices");
                        % disp(wallCoord);
                        % disp(" ");
                        % disp("Overlap Vertices");
                        % disp(overlapVertices);
                        % disp(" ");
                        % disp("----------------------------------------------");
                        if wallFracVal > 0
                            listExternalWallDataItr(1,1:3) = [i,j,k];
                            listExternalWallDataItr(1,6:7) = overlapVertices(1,:);
                            listExternalWallDataItr(1,8:9) = overlapVertices(2,:);
                            % listExternalWallDataItr = [i,j,k,0,0,overlapVertices(1,1),overlapVertices(1,2),overlapVertices(2,1),overlapVertices(2,1)];
                            wallSurfFrac = wallSurfFrac + wallFracVal;% /wallLength;
                            if isfield(building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim,'allExtWallWindowFrac')
                                dataVec = building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallWindowFrac;
                                dataMat = reshape(dataVec,4,length(dataVec)/4)';
                                % only match Room & Wall number as its same
                                % for ground and other elevated floors. Apt
                                % number should not be matched as it might
                                % change with level and the dataMat() was
                                % created during floorplan (no levels).
                                idx = find(and(dataMat(:,2)==j,dataMat(:,3)==k));
                                if ~isempty(idx)
                                    for itrId = 1:size(idx,1)
                                        windowSurfFracVal = windowSurfFracVal + dataMat(idx(itrId,1),4);
                                        listExternalWallDataItr(1,4) = listExternalWallDataItr(1,4) + dataMat(idx(itrId,1),4);
                                    end
                                end
                            end
                            if isfield(building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim,'allExtWallVentFrac')
                                dataVec = building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.allExtWallVentFrac;
                                dataMat = reshape(dataVec,4,length(dataVec)/4)';
                                % only match Room & Wall number as its same
                                % for ground and other elevated floors. Apt
                                % number should not be matched as it might
                                % change with level and the dataMat() was
                                % created during floorplan (no levels).
                                idx = find(and(dataMat(:,2)==j,dataMat(:,3)==k));
                                if ~isempty(idx)
                                    for itrId = 1:size(idx,1)
                                        ventSurfFracVal = ventSurfFracVal + dataMat(idx(itrId,1),4);
                                        listExternalWallDataItr(1,5) = listExternalWallDataItr(1,5) + dataMat(idx(itrId,1),4);
                                    end
                                end
                            end
                        end
                    end
                    if ~sum(listExternalWallDataItr) == 0
                        listExternalWallData = [listExternalWallData;listExternalWallDataItr];
                    end
                end
                % wallSurfFrac reresents total fraction of entire wall
                % expose to ambient. It has to be multiplied with
                % window and vent fractions to estimate solid wall,
                % vent, and window area-fraction.
                windowSurfFracVal = min(1,max(0,windowSurfFracVal));
                ventSurfFracVal = min(1,max(0,ventSurfFracVal));
                wallSurfFrac = wallSurfFrac*min(1,max(0,1-windowSurfFracVal-ventSurfFracVal));
                
                % if ~sum(listExternalWallDataItr) == 0
                %     listExternalWallData = [listExternalWallData;listExternalWallDataItr];
                % end
                updatedBuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWallSurfFrac = max(0,min(1,wallSurfFrac));
                updatedBuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWindowSurfFrac = max(0,min(1,windowSurfFracVal));
                updatedBuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientVentSurfFrac = max(0,min(1,ventSurfFracVal));
                wallCoord3D = building.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices;
                wallAreaVal = sqrt(sum((wallCoord3D(:,1)-wallCoord3D(:,2)).^2)) * ...
                              sqrt(sum((wallCoord3D(:,2)-wallCoord3D(:,3)).^2));
                updatedBuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).WallAreaTotal = wallAreaVal;
            end
        end
    end
    updatedBuilding.apartment1.room1.geometry.dim.plotWallVert2D = listExternalWallData;
end