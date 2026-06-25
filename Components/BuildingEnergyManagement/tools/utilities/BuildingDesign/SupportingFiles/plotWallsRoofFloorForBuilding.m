% Plot building roof, walls, and floor.

% Copyright 2024 The MathWorks, Inc.

function plotWallsRoofFloorForBuilding(model3Dbuilding,viewingAngle,colorScheme,ts)
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(model3Dbuilding);
    maxCoordXY = [0 0];
    minCoordXY = [0 0];
    topFloorNumber = model3Dbuilding.("apartment"+num2str(nApt)).("room"+num2str(nRooms(nApt,1))).geometry.dim.floorLevel;
    grdFloorNumber = model3Dbuilding.("apartment"+num2str(1)).("room"+num2str(nRooms(1,1))).geometry.dim.floorLevel;
    for i = 1:nApt
        hold on;
        for j = 1:nRooms(i,1)
            roomVerticesMat = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).floorPlan.Vertices;
            maxCoordXY(1,1) = max(maxCoordXY(1,1),max(roomVerticesMat(:,1)));
            maxCoordXY(1,2) = max(maxCoordXY(1,2),max(roomVerticesMat(:,2)));
            minCoordXY(1,1) = min(minCoordXY(1,1),min(roomVerticesMat(:,1)));
            minCoordXY(1,2) = min(minCoordXY(1,2),min(roomVerticesMat(:,2)));
            nWalls = size(roomVerticesMat,1);
            for k = 1:nWalls
                isThisOuterWall = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWallSurfFrac + ...
                                   model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientWindowSurfFrac + ...
                                   model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).AmbientVentSurfFrac ...
                                   > 0);
                if isThisOuterWall
                    if strcmp(colorScheme,"random") 
                        colorSchemeVector = rand(1,3);
                    % elseif strcmp(colorScheme,"sunlight")
                    %     sunlightFraction = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).sunlightFrac(1,ts);
                    %     if sunlightFraction > 0
                    %         colorSchemeVector = [sunlightFraction sunlightFraction 0];
                    %     else
                    %         colorSchemeVector = [0 0 0.3];
                    %     end
                    elseif strcmp(colorScheme,"radiation")
                        radiation = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).sunlightWattPerMeterSq;
                        radiationVal = min(1,max(0,radiation(1,ts)/max(radiation)));
                        colorSchemeVector = [radiationVal 0 0];
                    else
                        colorSchemeVector = rand(1,3);
                    end
                    plotApartmentRoomWall(model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices,...
                        colorSchemeVector); 
                end
            end

            topFloor = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.floorLevel==topFloorNumber);
            grdFloor = (model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.dim.floorLevel==grdFloorNumber);
            
            if topFloor
                if strcmp(colorScheme,"random") 
                    colorSchemeVector = rand(1,3); 
                % elseif strcmp(colorScheme,"sunlight")
                %     sunlightFraction = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("roof").sunlightFrac(1,ts);
                %     colorSchemeVector = [sunlightFraction sunlightFraction 0];
                elseif strcmp(colorScheme,"radiation")
                    radiation = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.sunlightWattPerMeterSq;
                    radiationVal = min(1,max(0,radiation(1,ts)/max(radiation)));
                    colorSchemeVector = [radiationVal 0 0];
                else
                    colorSchemeVector = [1 0 0];
                end
                plotApartmentRoomWall(model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("roof").vertices,...
                    colorSchemeVector);
            end
            
            if grdFloor
                plotApartmentRoomWall(model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("floor").vertices,...
                    [0 0 0.3]);
            end
        end
    end
    axis([minCoordXY(1,1) maxCoordXY(1,1) minCoordXY(1,2) maxCoordXY(1,2)]);
    hold off
    xlabel('East');
    ylabel('North');
    zlabel('Height');
    title(strcat('Building with ~',num2str(nApt),' Apartments'))
    view(viewingAngle);
end