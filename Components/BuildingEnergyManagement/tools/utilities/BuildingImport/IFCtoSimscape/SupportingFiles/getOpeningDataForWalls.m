function bldgWindows = getOpeningDataForWalls(NameValueArgs)
% Function to get opening data for the specified wall name.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.WallList (1,1) string {mustBeNonempty}
        NameValueArgs.ModelData struct {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.PhysUnitLen string {mustBeNonempty}
    end
    
    winCount = 1;
    bldgWindows = [];
    for i = 1:size(NameValueArgs.ModelData.Campus.Surface,2)
        if NameValueArgs.ModelData.Campus.Surface(1,i).surfaceTypeAttribute == NameValueArgs.WallList
            numWindows = size(NameValueArgs.ModelData.Campus.Surface(1,i).Opening,2);
            wallH = NameValueArgs.ModelData.Campus.Surface(1,i).RectangularGeometry.Height;
            wallW = NameValueArgs.ModelData.Campus.Surface(1,i).RectangularGeometry.Width;
            wallCoord = NameValueArgs.ModelData.Campus.Surface(1,i).PlanarGeometry.PolyLoop.CartesianPoint;
            wallCoordVal = zeros(4,3);
            for j = 1:4
                wallCoordVal(j,:) = wallCoord(1,j).Coordinate;
            end
            winWallPts = wallCoordVal(wallCoordVal(:,3)==min(unique(wallCoordVal(:,3))),:);
            winFrac = 0;
            for j = 1:numWindows
                if isfield(NameValueArgs.ModelData.Campus.Surface(1,i).Opening(1,j),"PlanarGeometry")
                    if NameValueArgs.Debug, disp(strcat("*** Wall#",num2str(i),"-Window#",num2str(j))); end
                    opening.("geometry"+j) = NameValueArgs.ModelData.Campus.Surface(1,i).Opening(1,j).PlanarGeometry.PolyLoop.CartesianPoint;
                    winW = NameValueArgs.ModelData.Campus.Surface(1,i).Opening(1,j).RectangularGeometry.Width;
                    winH = NameValueArgs.ModelData.Campus.Surface(1,i).Opening(1,j).RectangularGeometry.Height;
                    winFrac = winFrac + winW*winH/(wallW*wallH);
                end
            end
            if winFrac>0
                bldgWindows.("window"+winCount).wallOrientation = simscape.Value(winWallPts,NameValueArgs.PhysUnitLen);
                bldgWindows.("window"+winCount).openingFrac = winFrac;
                bldgWindows.("window"+winCount).derivedFrom.wall = wallCoord;
                bldgWindows.("window"+winCount).derivedFrom.wallType = NameValueArgs.ModelData.Campus.Surface(1,i).surfaceTypeAttribute;
                bldgWindows.("window"+winCount).derivedFrom.wallOpening = opening;
                winCount = winCount+1;
            end
            if NameValueArgs.Debug, disp(strcat("Found wall :",NameValueArgs.WallList,", window fraction value = ",num2str(winFrac))); end
        end
    end

    if NameValueArgs.Debug, disp(strcat("Number of windows found = ",num2str(winCount))); end

end