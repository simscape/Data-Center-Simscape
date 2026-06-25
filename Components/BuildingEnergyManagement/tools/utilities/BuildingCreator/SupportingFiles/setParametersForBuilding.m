function setParametersForBuilding(NameValueArgs)
% Set building parameters.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockType string {mustBeMember(NameValueArgs.BlockType,["Room","Room with Radiator","Room with UFP","Room with UFP & Radiator","External Wall","Internal Wall"])}
        NameValueArgs.BuildingData struct {mustBeNonempty}
        NameValueArgs.BuildingAptNum (1,1) {mustBeNonnegative}
        NameValueArgs.BuildingRoomNum (1,1) {mustBeNonnegative} = 0
        NameValueArgs.MinOpeningFraction (1,1) {mustBeNonnegative} = 0.01
        NameValueArgs.InternalWallThickness simscape.Value {mustBeNonempty} = simscape.Value(0,"m")
        NameValueArgs.ExternalWallThickness simscape.Value {mustBeNonempty} = simscape.Value(0,"m")
    end
    % NameValueArgs.BuildingRoomNum is kept optional as when walls are
    % specified, the Apt. Num. is used to index into wall matrix data.
    if NameValueArgs.BlockType == "Room" || ...
       NameValueArgs.BlockType == "Room with Radiator" || ...
       NameValueArgs.BlockType == "Room with UFP" || ...
       NameValueArgs.BlockType == "Room with UFP & Radiator"
        % Set room dimensions
        roomData = NameValueArgs.BuildingData.("apartment"+NameValueArgs.BuildingAptNum).("room"+NameValueArgs.BuildingRoomNum);
        len = getParamStr(num2str(roomData.geometry.dim.length));
        set_param(NameValueArgs.BlockPath,"roomLen",len);
        wid = getParamStr(num2str(roomData.geometry.dim.width));
        set_param(NameValueArgs.BlockPath,"roomWid",wid);
        hgt = getParamStr(num2str(roomData.geometry.dim.height));
        set_param(NameValueArgs.BlockPath,"roomHgt",hgt);
    elseif NameValueArgs.BlockType == "External Wall"
        extWallData = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotWallVert2D;
        i = extWallData(NameValueArgs.BuildingAptNum,1); 
        j = extWallData(NameValueArgs.BuildingAptNum,2); 
        k = extWallData(NameValueArgs.BuildingAptNum,3);
        fracWin = extWallData(NameValueArgs.BuildingAptNum,4);
        fracVen = extWallData(NameValueArgs.BuildingAptNum,5);
        room = NameValueArgs.BuildingData.("apartment"+i).("room"+j);
        wall = room.geometry.("wall"+k);
        wallVert = wall.vertices;
        wallZvec = unique(wallVert(3,:));
        if length(wallZvec) == 2
            dataWallLen = wallVert(1:2,wallVert(3,:)==min(wallZvec));
            wallLen = sqrt((dataWallLen(1,1)-dataWallLen(1,2))^2+(dataWallLen(2,1)-dataWallLen(2,2))^2);
            wallHgt = room.geometry.dim.height;
            wallThk = value(NameValueArgs.ExternalWallThickness,"m");
            ratioWallLenToHgt = wallLen/wallHgt;
            % Set wall parameters
            val = getParamStr(num2str(wallLen));
            set_param(NameValueArgs.BlockPath,"wallLength",val);
            val = getParamStr(num2str(wallHgt));
            set_param(NameValueArgs.BlockPath,"wallHeight",val);
            val = getParamStr(num2str(wallThk));
            set_param(NameValueArgs.BlockPath,"wallThickness",val);
            % Set wall direction
            val = getParamStr(strcat("[",num2str(wall.unitvecDir),"]"));
            set_param(NameValueArgs.BlockPath,"surfUnitV",val);
            val = getParamStr(num2str(90));
            set_param(NameValueArgs.BlockPath,"surfAngle",val);
            if fracWin > NameValueArgs.MinOpeningFraction && fracVen > NameValueArgs.MinOpeningFraction
                % Wall with Window and Vent
                winHgt = sqrt(fracWin*wallLen*wallHgt/ratioWallLenToHgt);
                winLen = ratioWallLenToHgt*winHgt;
                venHgt = sqrt(fracVen*wallLen*wallHgt/ratioWallLenToHgt);
                venLen = ratioWallLenToHgt*venHgt;
                % Set window parameters
                val = getParamStr(num2str(winHgt));
                set_param(NameValueArgs.BlockPath,"winHeight",val);
                val = getParamStr(num2str(winLen));
                set_param(NameValueArgs.BlockPath,"winLength",val);
                % Set vent parameters
                val = getParamStr(num2str(venHgt));
                set_param(NameValueArgs.BlockPath,"ventHeight",val);
                val = getParamStr(num2str(venLen));
                set_param(NameValueArgs.BlockPath,"ventLength",val);
            elseif fracWin <= NameValueArgs.MinOpeningFraction && fracVen > NameValueArgs.MinOpeningFraction
                % Wall with Vent
                venHgt = sqrt(fracVen*wallLen*wallHgt/ratioWallLenToHgt);
                venLen = ratioWallLenToHgt*venHgt;
                % Set vent parameters
                val = getParamStr(num2str(venHgt));
                set_param(NameValueArgs.BlockPath,"ventHeight",val);
                val = getParamStr(num2str(venLen));
                set_param(NameValueArgs.BlockPath,"ventLength",val);
            elseif fracWin > NameValueArgs.MinOpeningFraction && fracVen <= NameValueArgs.MinOpeningFraction
                % Wall with Window
                winHgt = sqrt(fracWin*wallLen*wallHgt/ratioWallLenToHgt);
                winLen = ratioWallLenToHgt*winHgt;
                % Set window parameters
                val = getParamStr(num2str(winHgt));
                set_param(NameValueArgs.BlockPath,"winHeight",val);
                val = getParamStr(num2str(winLen));
                set_param(NameValueArgs.BlockPath,"winLength",val);
            else
                % Solid wall, do nothing
            end
        else
            disp(strcat("*** Warning: could not parameterize wall ",num2str(k),"for Apartment/Room #",num2str(i),"/",num2str(j)));
        end
    elseif NameValueArgs.BlockType == "Internal Wall"
        intWallData = NameValueArgs.BuildingData.apartment1.room1.geometry.dim.plotInternalWallVert2D;
        i1 = intWallData(NameValueArgs.BuildingAptNum,1);
        j1 = intWallData(NameValueArgs.BuildingAptNum,2);
        openFrac = 1-intWallData(NameValueArgs.BuildingAptNum,5);
        wallHgt = NameValueArgs.BuildingData.("apartment"+i1).("room"+j1).geometry.dim.height;
        wallLen = sqrt((intWallData(NameValueArgs.BuildingAptNum,6)-intWallData(NameValueArgs.BuildingAptNum,8))^2+...
                       (intWallData(NameValueArgs.BuildingAptNum,7)-intWallData(NameValueArgs.BuildingAptNum,9))^2);
        wallThk = value(NameValueArgs.InternalWallThickness,"m");
        % Set wall parameters
        val = getParamStr(num2str(wallHgt));
        set_param(NameValueArgs.BlockPath,"wallHeight",val);
        val = getParamStr(num2str(wallLen));
        set_param(NameValueArgs.BlockPath,"wallLength",val);
        val = getParamStr(num2str(wallThk));
        set_param(NameValueArgs.BlockPath,"wallThickness",val);
        if openFrac > NameValueArgs.MinOpeningFraction
            % Internal wall with opening
            ratioWallLenToHgt = wallLen/wallHgt;
            openingHgt = sqrt(openFrac*wallLen*wallHgt/ratioWallLenToHgt);
            openingLen = ratioWallLenToHgt*openingHgt;
            val = getParamStr(num2str(openingLen));
            set_param(NameValueArgs.BlockPath,"ventLength",val);
            val = getParamStr(num2str(openingHgt));
            set_param(NameValueArgs.BlockPath,"ventHeight",val);
        end
    else
        disp(strcat("*** Warning : Skipping parameterization for ",NameValueArgs.BlockType," at :",NameValueArgs.BlockPath));
    end
end