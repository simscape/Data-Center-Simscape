function opening = getOpeningForMultipleBuildingWalls(NameValueArgs)
% Function to get opening data for the specified wall names or wall list.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.WallList (:,1) string {mustBeNonempty}
        NameValueArgs.ModelData struct {mustBeNonempty}
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.PhysUnitLen string {mustBeNonempty}
    end

    if NameValueArgs.Debug
        disp("*** Wall Names:");
        disp(NameValueArgs.WallList);
    end
    
    for i = 1:size(NameValueArgs.WallList,1)
        opening.(NameValueArgs.WallList(i,1)) = getOpeningDataForWalls(WallList=NameValueArgs.WallList(i,1),...
            ModelData=NameValueArgs.ModelData,Debug=NameValueArgs.Debug,PhysUnitLen=NameValueArgs.PhysUnitLen);
    end
end