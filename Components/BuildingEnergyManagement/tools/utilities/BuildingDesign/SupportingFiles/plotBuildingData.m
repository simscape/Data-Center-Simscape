% Function to create building plots.

% Copyright 2024 The MathWorks, Inc.

function plotBuildingData(model3Dbuilding,viewingAngle,colorScheme,alphaData,ts,plotIntWalls,plotWallText)
    plotColorLowVal = 0.85;
    plotColorHighVal = 1;
    uppTs = ceil(ts);
    lowTs = floor(ts);
    if uppTs == lowTs
        interplData = false;
        interplDataScaleLow = 0;
    else
        interplData = true;
        interplDataScaleLow = min(1,max(0,(uppTs-ts)/(uppTs-lowTs)));
    end
    
    if plotIntWalls
        intWallDataMat = model3Dbuilding.apartment1.room1.geometry.dim.plotInternalWallVert2D;
        nIntWall = size(intWallDataMat,1);
    else
        nIntWall = 0;
    end
    % aptRoomWallNumMat = model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wall;
    aptRoomWallNumMat = model3Dbuilding.apartment1.room1.geometry.dim.plotWallVert2D;
    % plotWallVert2D: Column 1:3 for i,j,k; Column 4,5 for WIN/VENT fraction and Column 6-9 for (x1,y1) & (x2,y2)
    aptRoomRoofNumMat = model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roof;
    
    nWall = size(aptRoomWallNumMat,1);
    nRoof = size(aptRoomRoofNumMat,1);

    if strcmp(colorScheme,"walls")
        nRoof = 0;
    end

    if strcmp(colorScheme,"roof")
        nWall = 0;
    end

    if isfield(model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData,"wallTemp")
        plotTroom = model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.wallTemp;
    end
    
    if isfield(model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData,"roofTemp")
        plotTroof = model3Dbuilding.apartment1.room1.geometry.dim.buildingExtBoundaryWallData.roofTemp;
    end

    if strcmp(colorScheme,"temperature")
        maxT = max(max(max(plotTroof)),max(max(plotTroom)));
        minT = min(min(min(plotTroof)),min(min(plotTroom)));
    end
    
    % With the assumption of all walls having 4 vertices
    listOfFaces_X = zeros(nWall+nRoof+nIntWall,4); % 4 vertices
    listOfFaces_Y = zeros(nWall+nRoof+nIntWall,4); % 4 vertices
    listOfFaces_Z = zeros(nWall+nRoof+nIntWall,4); % 4 vertices
    colorForFaces = zeros(nWall+nRoof+nIntWall,1); % RGB values

    listOfWindows_X = zeros(nWall+nIntWall,4); % 4 vertices
    listOfWindows_Y = zeros(nWall+nIntWall,4); % 4 vertices
    listOfWindows_Z = zeros(nWall+nIntWall,4); % 4 vertices
    if strcmp(colorScheme,"simple")
        colorForWindows = 0.8*ones(nWall+nIntWall,1); % RGB values
    else
        colorForWindows = 0.5*ones(nWall+nIntWall,1); % RGB values
    end

    windowTextData = strings(nWall+nIntWall,1);
    windowTextLoc = zeros(nWall+nIntWall,3); % XYZ location

    if ~strcmp(colorScheme,"roof")
        for wall = 1:nWall
            i = aptRoomWallNumMat(wall,1);
            j = aptRoomWallNumMat(wall,2);
            k = aptRoomWallNumMat(wall,3);
            if strcmp(colorScheme,"random") 
                colorForFaces(wall,1) = rand(1,1);
            elseif strcmp(colorScheme,"simple")
                colorForFaces(wall,1) = 0.98;
            elseif strcmp(colorScheme,"radiation")
                radiation = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).sunlightWattPerMeterSq;
                if interplData
                    radiationVal = min(1,max(0,(radiation(1,uppTs)*(1-interplDataScaleLow)+radiation(1,lowTs)*interplDataScaleLow)/max(radiation)));
                else
                    radiationVal = min(1,max(0,radiation(1,uppTs)/max(radiation)));
                end
                if radiationVal > 0
                    radiationValCol = plotColorLowVal + (plotColorHighVal-plotColorLowVal)*radiationVal;
                else
                    radiationValCol = radiationVal;
                end
                colorForFaces(wall,1) = radiationValCol;
            elseif strcmp(colorScheme,"temperature")
                if interplData
                    colorForFaces(wall,1) = (plotTroom(wall,uppTs)*(1-interplDataScaleLow)+plotTroom(nWall,lowTs)*interplDataScaleLow);
                else
                    colorForFaces(wall,1) = plotTroom(wall,uppTs);
                end
            elseif strcmp(colorScheme,"wallsAndRoof")
                colorForFaces(wall,1) = 0;
            elseif strcmp(colorScheme,"walls")
                colorForFaces(wall,1) = 0;
            else
                colorForFaces(wall,1) = rand(1,1);
            end
            listOfFaces_X(wall,:) = [aptRoomWallNumMat(wall,[6,8]),aptRoomWallNumMat(wall,[8,6])];
            listOfFaces_Y(wall,:) = [aptRoomWallNumMat(wall,[7,9]),aptRoomWallNumMat(wall,[9,7])];
            listOfFaces_Z(wall,:) = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.("wall"+num2str(k)).vertices(3,:);
            windowAreaFrac = aptRoomWallNumMat(wall,4);
            ventAreaFrac = aptRoomWallNumMat(wall,5);

            [X,Y,Z] = getPatchCoordinatesForWallOpening(listOfFaces_X(wall,:),listOfFaces_Y(wall,:),listOfFaces_Z(wall,:),windowAreaFrac+ventAreaFrac);

            listOfWindows_X(wall,:) = X;
            listOfWindows_Y(wall,:) = Y;
            listOfWindows_Z(wall,:) = Z;

            windowTextData(wall,1) = strcat(num2str(round(windowAreaFrac+ventAreaFrac,2)*100),"%");
            windowTextLoc(wall,1) = mean(X);
            windowTextLoc(wall,2) = mean(Y);
            windowTextLoc(wall,3) = mean(Z);
        end

        if plotIntWalls
            for wall = 1:nIntWall
                i1 = intWallDataMat(wall,1);
                j1 = intWallDataMat(wall,2);

                solidWallFracVal = intWallDataMat(wall,5);
                listOfFaces_X(nWall+wall,:) = [intWallDataMat(wall,[6,8]),intWallDataMat(wall,[8,6])];
                listOfFaces_Y(nWall+wall,:) = [intWallDataMat(wall,[7,9]),intWallDataMat(wall,[9,7])];
                % All walls of a room would have similar wall.vertices(3,:)
                % and hence, value for 1st wall is used below, as the data
                % for wall number if not present.
                listOfFaces_Z(nWall+wall,:) = model3Dbuilding.("apartment"+num2str(i1)).("room"+num2str(j1)).geometry.("wall"+num2str(1)).vertices(3,:);

                [X,Y,Z] = getPatchCoordinatesForWallOpening(listOfFaces_X(nWall+wall,:),listOfFaces_Y(nWall+wall,:),listOfFaces_Z(nWall+wall,:),1-solidWallFracVal);
                listOfWindows_X(nWall+wall,:) = X;
                listOfWindows_Y(nWall+wall,:) = Y;
                listOfWindows_Z(nWall+wall,:) = Z;

                windowTextData(nWall+wall,1) = strcat(num2str(round(1-solidWallFracVal,2)*100),"%");
                windowTextLoc(nWall+wall,1) = mean(X);
                windowTextLoc(nWall+wall,2) = mean(Y);
                windowTextLoc(nWall+wall,3) = mean(Z);
            end
        end
    end

    if ~strcmp(colorScheme,"walls")
        for roof = 1:nRoof
            i = aptRoomRoofNumMat(roof,1);
            j = aptRoomRoofNumMat(roof,2);
            if strcmp(colorScheme,"random") 
                colorForFaces(nWall+nIntWall+roof,1) = rand(1,1);
            elseif strcmp(colorScheme,"simple")
                colorForFaces(nWall+nIntWall+roof,1) = 0.01;
            elseif strcmp(colorScheme,"radiation")
                radiation = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.sunlightWattPerMeterSq;
                if interplData
                    radiationVal = min(1,max(0,(radiation(1,uppTs)*(1-interplDataScaleLow)+radiation(1,lowTs)*interplDataScaleLow)/max(radiation)));
                else 
                    radiationVal = min(1,max(0,radiation(1,uppTs)/max(radiation)));
                end
                if radiationVal > 0
                    radiationValCol = plotColorLowVal + (plotColorHighVal-plotColorLowVal)*radiationVal;
                else
                    radiationValCol = radiationVal;
                end
                colorForFaces(nWall+nIntWall+roof,1) = radiationValCol;
            elseif strcmp(colorScheme,"temperature")
                if interplData
                    colorForFaces(nWall+nIntWall+roof,1) = (plotTroof(roof,uppTs)*(1-interplDataScaleLow)+plotTroof(roof,lowTs)*interplDataScaleLow);
                else
                    colorForFaces(nWall+nIntWall+roof,1) = plotTroof(roof,uppTs);
                end
            elseif strcmp(colorScheme,"wallsAndRoof")
                colorForFaces(nWall+nIntWall+roof,1) = 1;
            elseif strcmp(colorScheme,"roof")
                colorForFaces(nWall+nIntWall+roof,1) = 1;
            else
                colorForFaces(nWall+nIntWall+roof,1) = rand(1,1);
            end
            listOfFaces_X(roof+nWall,:) = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.vertices(1,:);
            listOfFaces_Y(roof+nWall,:) = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.vertices(2,:);
            listOfFaces_Z(roof+nWall,:) = model3Dbuilding.("apartment"+num2str(i)).("room"+num2str(j)).geometry.roof.vertices(3,:);
        end
    end

    if isfield(model3Dbuilding.apartment1.room1.geometry.dim,"inclinedRoof")
        inclX = model3Dbuilding.apartment1.room1.geometry.dim.inclinedRoof.inclX;
        inclY = model3Dbuilding.apartment1.room1.geometry.dim.inclinedRoof.inclY;
        inclZ = model3Dbuilding.apartment1.room1.geometry.dim.inclinedRoof.inclZ;
        if isfield(model3Dbuilding.apartment1.room1.geometry.dim.inclinedRoof,"solarRadWattPerSqMeter")
            if strcmp(colorScheme,"radiation")
                radiationMat = model3Dbuilding.apartment1.room1.geometry.dim.inclinedRoof.solarRadWattPerSqMeter;
                for i = 1:size(radiationMat,1)
                    radiation = radiationMat(i,:);
                    if interplData
                        radiationVal = min(1,max(0,(radiation(1,uppTs)*(1-interplDataScaleLow)+radiation(1,lowTs)*interplDataScaleLow)/max(radiation)));
                    else 
                        radiationVal = min(1,max(0,radiation(1,uppTs)/max(radiation)));
                    end
                    if radiationVal > 0
                        radiationValCol = plotColorLowVal + (plotColorHighVal-plotColorLowVal)*radiationVal;
                    else
                        radiationValCol = radiationVal;
                    end
                    inclC(i,1) = radiationValCol;
                end
            else
                inclC = 0.5*ones(size(inclZ,1),1);
            end
        else
            inclC = 0.5*ones(size(inclZ,1),1);
        end
        p = patch([listOfFaces_X;listOfWindows_X;inclX]',...
                  [listOfFaces_Y;listOfWindows_Y;inclY]',...
                  [listOfFaces_Z;listOfWindows_Z;inclZ]',...
                  [colorForFaces;colorForWindows;inclC]');
    else
        p = patch([listOfFaces_X;listOfWindows_X]',...
                  [listOfFaces_Y;listOfWindows_Y]',...
                  [listOfFaces_Z;listOfWindows_Z]',...
                  [colorForFaces;colorForWindows]');
    end

    if plotWallText
        text(windowTextLoc(:,1),windowTextLoc(:,2),windowTextLoc(:,3),windowTextData(:,1));
    end

    p.FaceVertexAlphaData = alphaData;
    if alphaData < 1
        p.FaceAlpha = 'flat' ; 
    end
    
    if ~strcmp(colorScheme,"temperature")
        if strcmp(colorScheme,"simple")
            % Do nothing
        else
            cparula = parula;
            colormap(cparula);
            c = colorbar;
            if strcmp(colorScheme,"wallsAndRoof")
                c.Ticks = [0 1]; c.TickLabels = {'walls','roof'};
            elseif strcmp(colorScheme,"walls")
                c.Ticks = [0 1];
            elseif strcmp(colorScheme,"roof")
                c.Ticks = [0 1];
            else
                c.Ticks = 0:0.25:1;
                c.Limits = [0 1];
            end
            clim([0 1]);
            c.Location = "eastoutside";
        end
    else
        cparula = parula;
        colormap(cparula);
        nGrid = 8;
        delT = (maxT - minT)/(nGrid+1);
        tickValues = round(minT+(0:nGrid)*delT,1);
        c = colorbar('Ticks',tickValues);
        c.Limits = [minT maxT];
        clim([minT maxT]);
        c.Location = "eastoutside";
    end
    xlabel('East');
    ylabel('North');
    zlabel('Height');
    view(viewingAngle);
end