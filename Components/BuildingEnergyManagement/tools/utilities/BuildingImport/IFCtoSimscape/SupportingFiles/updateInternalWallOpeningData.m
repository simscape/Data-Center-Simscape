function aptTbl = updateInternalWallOpeningData(NameValueArgs)
% Function to update internal walls opening data.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.TableData table {mustBeNonempty}
        NameValueArgs.WallData struct {mustBeNonempty}
        NameValueArgs.ModelDataUnit string {mustBeNonempty}
        NameValueArgs.Tol (1,1) {mustBeNonnegative} = 0.01
    end

    aptTbl = NameValueArgs.TableData;
    for i = 1:size(aptTbl,1)
        roomIntersectionPts = zeros(2,2);
        r1 = aptTbl.("#A")(i,1);
        r2 = aptTbl.("#B")(i,1);
        roomIntersectionPts(1,:) = NameValueArgs.Apartment.("room"+r1).geometry.connectivity.("room"+r2).commonWallPoint1;
        roomIntersectionPts(2,:) = NameValueArgs.Apartment.("room"+r1).geometry.connectivity.("room"+r2).commonWallPoint2;
        [mr,cr] = slopeOfLineThroughTwoPoint([roomIntersectionPts(1,:);roomIntersectionPts(2,:)],NameValueArgs.Tol);
    
        nInternalWindows = length(fieldnames(NameValueArgs.WallData));
        for j = 1:nInternalWindows
            intWallCADUnits = NameValueArgs.WallData.("window"+j).wallOrientation(1:2,1:2);
            intWallCAD = value(intWallCADUnits,"m");
            intWallCADfr = NameValueArgs.WallData.("window"+j).openingFrac;
            [mj,cj] = slopeOfLineThroughTwoPoint([intWallCAD(1,:);intWallCAD(2,:)],NameValueArgs.Tol);
            if ismembertol(mj,mr,NameValueArgs.Tol) && ismembertol(cj,cr,NameValueArgs.Tol)
                [wallFracVal,~] = testParallelLineOverlapLength(intWallCAD,roomIntersectionPts,NameValueArgs.Tol);
                if wallFracVal > 0
                    aptTbl.("Solid Wall Fraction")(i,1) = min(1,max(0.001,1-intWallCADfr));
                end
            end
        end
    end
    disp(aptTbl);
end