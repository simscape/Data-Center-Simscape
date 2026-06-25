function result = readBuildingGeometryData(NameValueArgs)
% Read building data from struct, created from XML file obtained from tools 
% like Revit.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.PhysUnitMapping (:,2) {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.RoundOff (1,1) {mustBeNonnegative} = 1
    end
    
    % Find length units for BIM model
    result.UnitLength = NameValueArgs.PhysUnitMapping.Simscape(find(NameValueArgs.PhysUnitMapping.Revit==NameValueArgs.BuildingData.lengthUnitAttribute),1);
    result.UnitLength = convertCharsToStrings(result.UnitLength{1,1});
    result.PhysUnitMap = NameValueArgs.PhysUnitMapping;
    
    % Extract room information
    X = []; Y = []; Z = []; sz = [];
    numSpaces = size(NameValueArgs.BuildingData.Campus.Building.Space,2);
    roomCount = 1;
    bldgHt = 0;
    result.Height = 0;
    countH = 0;
    for j = 1:numSpaces
        Xr = []; Yr = []; Zr = [];
        spaceModel = NameValueArgs.BuildingData.Campus.Building.Space(1,j);
        numPolyLoop = numel(spaceModel.ShellGeometry.ClosedShell.PolyLoop);
        for i = 1:numPolyLoop
            pointData = spaceModel.ShellGeometry.ClosedShell.PolyLoop(i).CartesianPoint;
            numPts = numel(pointData);
            val = zeros(numPts,3);
            for k = 1:numPts
                val(k,:) = round(pointData(1,k).Coordinate,NameValueArgs.RoundOff);
            end
            sz = [sz;numPts];
            Xr = [Xr;val(:,1)];
            Yr = [Yr;val(:,2)];
            Zr = [Zr;val(:,3)];
        end
        X = [X;Xr]; Y = [Y;Yr]; Z = [Z;Zr];
    
        % Extract Room Floor Plan Data
        plotName = strcat("Room #",num2str(j));
        
        [~,rectPatchX,rectPatchY,roomHeight,maxZ] = getPatchForRoom(X=Xr,Y=Yr,Z=Zr,...
                                                                    Debug=NameValueArgs.Debug,...
                                                                    RoomPlotName=plotName);
        bldgHt = max(bldgHt,maxZ);
        result.Height = result.Height + roomHeight;
        countH = countH + 1;

        for i = 1:size(rectPatchX,1)
            if size(rectPatchX,1) > 1
                roomName = [i,j];
            else
                roomName = [0,j];
            end
            result.Room{roomCount,1} = getBuildingRoomCreationParams(...
                X=rectPatchX(i,:),Y=rectPatchY(i,:),RoomNum=roomName,...
                Debug=NameValueArgs.Debug,PhysUnitLen=result.UnitLength);
            roomCount = roomCount+1;
        end
    end
    result.Height = result.Height/countH;
    result.NumLevels = max(1,floor(bldgHt/result.Height));

    result.Height = simscape.Value(result.Height,result.UnitLength);
    
    if NameValueArgs.Debug
        figure("Name","All Vertices")
        for i = 1:size(sz,1)
            if i>1
                startIndx = sum(sz(1:i-1,1))+1;
                endIndx = sum(sz(1:i,1));
            else
                startIndx = 1;
                endIndx = sz(i,1);
            end
            plot3(X(startIndx:endIndx,1),...
                  Y(startIndx:endIndx,1),...
                  Z(startIndx:endIndx,1));hold on;
        end
        hold off;
        axis off;
    end

end