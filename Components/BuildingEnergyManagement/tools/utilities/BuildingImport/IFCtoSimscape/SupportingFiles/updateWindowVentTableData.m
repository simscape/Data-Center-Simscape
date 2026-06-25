function tblDataWindowVent = updateWindowVentTableData(NameValueArgs)
% Function to update external wall opening data.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.FloorPlan struct {mustBeNonempty}
        NameValueArgs.TableData table {mustBeNonempty}
        NameValueArgs.WallData struct {mustBeNonempty}
        NameValueArgs.ModelDataUnit string {mustBeNonempty}
        NameValueArgs.Tol (1,1) {mustBeNonnegative} = 0.01
    end

    tblDataWindowVent = NameValueArgs.TableData;
    totPts = max(tblDataWindowVent.("From Point"));
    nWinCAD = length(fieldnames(NameValueArgs.WallData));
    for i = 1:totPts
        if i == totPts
            id1 = totPts;
            id2 = 1;
        else
            id1 = i;
            id2 = i+1;
        end
        idVec = find(and(tblDataWindowVent.("From Point")==id1,tblDataWindowVent.("To Point")==id2));
        for j = 1:size(idVec,1)
            roomVert = str2num(tblDataWindowVent.("Overlap Vertices")(idVec(j,1),1));
            roomVert = [roomVert(1,1:2);roomVert(1,3:4)];
            for k = 1:nWinCAD
                % Convert to SI units
                wallWithUnits = NameValueArgs.WallData.("window"+k).wallOrientation(1:2,1:2);
                wallVert = value(wallWithUnits,"m");
                %
                [mw,cw] = slopeOfLineThroughTwoPoint([wallVert(1,:);wallVert(2,:)],NameValueArgs.Tol);
                [mr,cr] = slopeOfLineThroughTwoPoint(roomVert,NameValueArgs.Tol);
                if ismembertol(mw,mr,NameValueArgs.Tol) && ismembertol(cr,cw,NameValueArgs.Tol)
                    [wallFracVal,~] = testParallelLineOverlapLength(wallVert,roomVert,NameValueArgs.Tol);
                    if wallFracVal > 0
                        numWinToCheck = length(fieldnames(NameValueArgs.WallData.("window"+k).derivedFrom.wallOpening));
                        for m = 1:numWinToCheck
                            wallName = NameValueArgs.WallData.("window"+k).derivedFrom.wallOpening.("geometry"+m);
                            unitBIMmodel = string(unit(wallWithUnits));
                            winCoordmeters = value(simscape.Value([wallName(1,1).Coordinate;wallName(1,2).Coordinate;wallName(1,3).Coordinate;wallName(1,4).Coordinate],unitBIMmodel),"m");
                            heightVec = unique(winCoordmeters(:,3));
                            if length(heightVec) > 1
                                wallH = abs(heightVec(1,1)-heightVec(2,1));
                                winPts12 = winCoordmeters(winCoordmeters(:,3)==heightVec(1,1),:);
                                winPts34 = winCoordmeters(winCoordmeters(:,3)==heightVec(2,1),:);
                                [winValidityChk1,~] = testParallelLineOverlapLength(winPts12,roomVert,NameValueArgs.Tol);
                                [winValidityChk2,~] = testParallelLineOverlapLength(winPts34,roomVert,NameValueArgs.Tol);
                                if winValidityChk1 > 0 || winValidityChk2 > 0
                                    winArea = sqrt((winPts12(1,1)-winPts12(2,1))^2+(winPts12(1,2)-winPts12(2,2))^2)*sqrt((winPts34(1,1)-winPts34(2,1))^2+(winPts34(1,2)-winPts34(2,2))^2);
                                    wallArea = sqrt((roomVert(1,1)-roomVert(2,1))^2+(roomVert(1,2)-roomVert(2,2))^2)*wallH;
                                    tblDataWindowVent.("Window (0-1)")(idVec(j,1),1) = min(1,tblDataWindowVent.("Window (0-1)")(idVec(j,1),1)+winArea/wallArea);
                                end
                            end
                        end
                        % tblDataWindowVent.("Window (0-1)")(idVec(j,1),1) = tblDataWindowVent.("Window (0-1)")(idVec(j,1),1) + NameValueArgs.WallData.("window"+k).openingFrac;
                    end
                end
            end
        end
    end
end