function msgDisplayCount = setParamForWallThermal(NameValueArgs)
% Set wall thermal parameters.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingBlockPathData struct {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.DiagnosticMsgStart (1,1) {mustBeNonnegative} = 0
        NameValueArgs.HeatTransferCoeffInt (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.HeatTransferCoeffInt, "W/(K*m^2)")} = simscape.Value(20,"W/(K*m^2)")
        NameValueArgs.HeatTransferCoeffExt (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.HeatTransferCoeffExt, "W/(K*m^2)")} = simscape.Value(10,"W/(K*m^2)")
        NameValueArgs.MaterialPropTable (6,5) table {mustBeNonempty}
        NameValueArgs.MinOpeningFraction (1,1) {mustBeNonnegative} = 0.01
        NameValueArgs.IniBuildingTemperature (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.IniBuildingTemperature, "K")}
        NameValueArgs.WallName string {mustBeMember(NameValueArgs.WallName,["Roof","Floor","Internal","External","All"])} = "All"
    end

    setLibraryPathReferences;

    fieldsToExpect = {'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding', 'blkNameRoofsAndGround', 'namePipeInletBldg', 'namePipeOutletBldg'};
    fieldsUserData = fieldnames(NameValueArgs.BuildingBlockPathData);
    
    if all(ismember(fieldsToExpect, fieldsUserData)) && bdIsLoaded(NameValueArgs.BuildingLibraryName)
        msgDisplayCount = NameValueArgs.DiagnosticMsgStart+1;
        msgDisplayCount = displayDiagnostics(ErrorMsg="Setting building thermal from the part-file.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        
        listIntWalls = NameValueArgs.BuildingBlockPathData.partFileBuilding.apartment1.room1.geometry.dim.plotInternalWallVert2D;
        listExtWalls = NameValueArgs.BuildingBlockPathData.partFileBuilding.apartment1.room1.geometry.dim.plotWallVert2D;
        
        if or(NameValueArgs.WallName=="External",NameValueArgs.WallName=="All")
            % Parameterize external walls
            for i = 1:size(listExtWalls,1)
                % Density
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.ExternalWall("Density [kg/m^3]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallMaterialDen",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallMaterialDen_unit","kg/m^3");
                % Heat Capacity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.ExternalWall("Heat Capacity [J/kg-K]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallMaterialCp",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallMaterialCp_unit","J/(K*kg)");
                % Thermal Conductivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.ExternalWall("Thermal Conductivity [W/K-m]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallThermalK",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallThermalK_unit","W/(K*m)");
                % Solar Radiation Absorptivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.ExternalWall("Absorptivity [-]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"wallAbsorptivity",val);
                % HTC - external
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffExt,"W/(K*m^2)")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"extToWallHTC",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"extToWallHTC_unit","W/(K*m^2)");
                % HTC - internal
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffInt,"W/(K*m^2)")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"intToRoomHTC",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"intToRoomHTC_unit","W/(K*m^2)");
                % Initial Temperature
                val = getParamStr(num2str(value(NameValueArgs.IniBuildingTemperature,"K")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"iniT",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"iniT_unit","K");
                % Check if Window exists, and parameterize it.
                if listExtWalls(i,4) > NameValueArgs.MinOpeningFraction
                    % Glass Thickness
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Thickness [m]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winThickness",val);
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winThickness_unit","m");
                    % Density
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Density [kg/m^3]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winMaterialDen",val);
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winMaterialDen_unit","kg/m^3");
                    % Heat Capacity
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Heat Capacity [J/kg-K]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winMaterialCp",val);
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winMaterialCp_unit","J/(K*kg)");
                    % Thermal Conductivity
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Thermal Conductivity [W/K-m]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winThermalK",val);
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winThermalK_unit","W/(K*m)");
                    % Solar Radiation Absorptivity, Transmissivity 
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Absorptivity [-]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winAbsorptivity",val);
                    val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Window("Transmissivity [-]")));
                    set_param(NameValueArgs.BuildingBlockPathData.blkNameWallExternal(i,1),"winTransmissivity",val);
                end
            end
            msgDisplayCount = displayDiagnostics(ErrorMsg="Completed external wall thermal parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        end

        if or(NameValueArgs.WallName=="Internal",NameValueArgs.WallName=="All")
            % Parameterize internal walls
            for i = 1:size(listIntWalls,1)
                % Density
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.InternalWall("Density [kg/m^3]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallMaterialDen",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallMaterialDen_unit","kg/m^3");
                % Heat Capacity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.InternalWall("Heat Capacity [J/kg-K]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallMaterialCp",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallMaterialCp_unit","J/(K*kg)");
                % Thermal Conductivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.InternalWall("Thermal Conductivity [W/K-m]")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallThermalK",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"wallThermalK_unit","W/(K*m)");
                % HTC - internal wall, so internal and external HTC are
                % same == internal HTC of two different rooms.
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffInt,"W/(K*m^2)")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"intToRoomHTC",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"intToRoomHTC_unit","W/(K*m^2)");
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"extToWallHTC",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"extToWallHTC_unit","W/(K*m^2)");
                % Initial Temperature
                val = getParamStr(num2str(value(NameValueArgs.IniBuildingTemperature,"K")));
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"iniT",val);
                set_param(NameValueArgs.BuildingBlockPathData.blkNameWallInternal(i,1),"iniT_unit","K");
            end
            msgDisplayCount = displayDiagnostics(ErrorMsg="Completed internal wall thermal parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        end

        if or(NameValueArgs.WallName=="Roof",NameValueArgs.WallName=="All")
            paramRoof = true;
        else
            paramRoof = false;
        end
        if or(NameValueArgs.WallName=="Floor",NameValueArgs.WallName=="All")
            paramFloor = true;
        else
            paramFloor = false;
        end
        % Parameterize roof of all levels.
        for i = 1:size(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround,1)
            blkName = NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,1);
            if and(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2)=="WallSolar",paramRoof)
                % Density
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Roof("Density [kg/m^3]")));
                set_param(blkName,"wallMaterialDen",val);
                set_param(blkName,"wallMaterialDen_unit","kg/m^3");
                % Heat Capacity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Roof("Heat Capacity [J/kg-K]")));
                set_param(blkName,"wallMaterialCp",val);
                set_param(blkName,"wallMaterialCp_unit","J/(K*kg)");
                % Thermal Conductivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Roof("Thermal Conductivity [W/K-m]")));
                set_param(blkName,"wallThermalK",val);
                set_param(blkName,"wallThermalK_unit","W/(K*m)");
                % Solar Radiation Absorptivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Roof("Absorptivity [-]")));
                set_param(blkName,"wallAbsorptivity",val);
                % HTC - external
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffExt,"W/(K*m^2)")));
                set_param(blkName,"extToWallHTC",val);
                set_param(blkName,"extToWallHTC_unit","W/(K*m^2)");
                % HTC - internal
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffInt,"W/(K*m^2)")));
                set_param(blkName,"intToRoomHTC",val);
                set_param(blkName,"intToRoomHTC_unit","W/(K*m^2)");
                % Initial Temperature
                val = getParamStr(num2str(value(NameValueArgs.IniBuildingTemperature,"K")));
                set_param(blkName,"iniT",val);
                set_param(blkName,"iniT_unit","K");
            end
            if or(and(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2)=="Wall",paramFloor),...
                  and(NameValueArgs.BuildingBlockPathData.blkNameRoofsAndGround(i,2)=="WallOpen",paramFloor))
                % Density
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Floor("Density [kg/m^3]")));
                set_param(blkName,"wallMaterialDen",val);
                set_param(blkName,"wallMaterialDen_unit","kg/m^3");
                % Heat Capacity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Floor("Heat Capacity [J/kg-K]")));
                set_param(blkName,"wallMaterialCp",val);
                set_param(blkName,"wallMaterialCp_unit","J/(K*kg)");
                % Thermal Conductivity
                val = getParamStr(num2str(NameValueArgs.MaterialPropTable.Floor("Thermal Conductivity [W/K-m]")));
                set_param(blkName,"wallThermalK",val);
                set_param(blkName,"wallThermalK_unit","W/(K*m)");
                % HTC - internal wall, so internal and external HTC are
                % same == internal HTC of two different rooms.
                val = getParamStr(num2str(value(NameValueArgs.HeatTransferCoeffInt,"W/(K*m^2)")));
                set_param(blkName,"intToRoomHTC",val);
                set_param(blkName,"intToRoomHTC_unit","W/(K*m^2)");
                set_param(blkName,"extToWallHTC",val);
                set_param(blkName,"extToWallHTC_unit","W/(K*m^2)");
                % Initial Temperature
                val = getParamStr(num2str(value(NameValueArgs.IniBuildingTemperature,"K")));
                set_param(blkName,"iniT",val);
                set_param(blkName,"iniT_unit","K");
            end
        end
        if paramFloor
            msgDisplayCount = displayDiagnostics(ErrorMsg="Completed all floor thermal parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        end
        if paramRoof
            msgDisplayCount = displayDiagnostics(ErrorMsg="Completed all roof thermal parameterization.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        end

    else
        disp(strcat("*** Error: exiting. Block (",BuildingBlockPathData,") struct must contain fields 'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding' and the model (",NameValueArgs.BuildingLibraryName,") must be loaded."));
    end
end