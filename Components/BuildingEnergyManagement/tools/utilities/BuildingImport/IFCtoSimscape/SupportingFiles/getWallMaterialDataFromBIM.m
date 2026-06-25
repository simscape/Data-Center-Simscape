function modelDataUpdated = getWallMaterialDataFromBIM(NameValueArgs)
% Function to collate wall material properties.

% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DataBIM struct {mustBeNonempty}
        NameValueArgs.DataModel struct {mustBeNonempty}
    end

    wallName = [NameValueArgs.DataBIM.Campus.Surface.surfaceTypeAttribute];
    wallMaterial = [NameValueArgs.DataBIM.Campus.Surface.constructionIdRefAttribute];
    wallList = unique(wallName);
    wallPropertyDefinition = strings(1,length(wallList));
    for i = 1:length(wallList)
        id1 = find(wallName==wallList(1,i),1);
        wallPropertyDefinition(1,i) = wallMaterial(1,id1);
        constructLayer = [NameValueArgs.DataBIM.Construction.idAttribute];
        id2 = find(constructLayer==wallPropertyDefinition(1,i),1);
        layerName = NameValueArgs.DataBIM.Construction(1,id2).LayerId.layerIdRefAttribute;
        absorptance = NameValueArgs.DataBIM.Construction(1,id2).Absorptance;
        layerDefinition = [NameValueArgs.DataBIM.Layer.idAttribute];
        id3 = find(layerDefinition==layerName,1);
        listOfLayers = NameValueArgs.DataBIM.Layer(1,id3).MaterialId;
        numLayers = length(listOfLayers);
        nameLayers = strings(1,numLayers);
        for j = 1:numLayers
            nameLayers(1,j) = strcat("L",num2str(j)," (",listOfLayers(1,j).materialIdRefAttribute,")");
        end
        % Initialize table
        NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i)) = initializeCompositeWallPropTable(NumLayer=numLayers,LayerName=nameLayers);
        
        if isfield(absorptance,"Text")
            NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Absorptivity [-]",:) = array2table(absorptance.Text);
        end
        
        for j = 1:length(nameLayers)
            listOfMaterials = [NameValueArgs.DataBIM.Material.idAttribute];
            checkMaterial = listOfLayers(1,j).materialIdRefAttribute;
            idj = find(listOfMaterials==checkMaterial,1);
            thickness = NameValueArgs.DataBIM.Material(1,idj).Thickness;
            if and(isfield(thickness,"Text"),isfield(thickness,"unitAttribute"))
                units = NameValueArgs.DataModel.PhysUnitMap.Simscape(find(NameValueArgs.DataModel.PhysUnitMap.Revit==thickness.unitAttribute),1);
                units = convertCharsToStrings(units{1,1});
                thicknessVal = simscape.Value(thickness.Text,units);
                thicknessVal = value(thicknessVal,"m");
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Thickness [m]",j) = array2table(thicknessVal);
            else
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Thickness [m]",j) = array2table(NaN);
            end
            conductivity = NameValueArgs.DataBIM.Material(1,idj).Conductivity;
            if and(isfield(conductivity,"Text"),isfield(conductivity,"unitAttribute"))
                units = NameValueArgs.DataModel.PhysUnitMap.Simscape(find(NameValueArgs.DataModel.PhysUnitMap.Revit==conductivity.unitAttribute),1);
                units = convertCharsToStrings(units{1,1});
                conductivityVal = simscape.Value(conductivity.Text,units);
                conductivityVal = value(conductivityVal,"W/(K*m)");
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Thermal Conductivity [W/K-m]",j) = array2table(conductivityVal);
            else
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Thermal Conductivity [W/K-m]",j) = array2table(NaN);
            end
            specificHeat = NameValueArgs.DataBIM.Material(1,idj).SpecificHeat;
            if and(isfield(specificHeat,"Text"),isfield(specificHeat,"unitAttribute"))
                units = NameValueArgs.DataModel.PhysUnitMap.Simscape(find(NameValueArgs.DataModel.PhysUnitMap.Revit==specificHeat.unitAttribute),1);
                units = convertCharsToStrings(units{1,1});
                specificHeatVal = simscape.Value(specificHeat.Text,units);
                specificHeatVal = value(specificHeatVal,"J/(K*kg)");
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Heat Capacity [J/kg-K]",j) = array2table(specificHeatVal);
            else
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Heat Capacity [J/kg-K]",j) = array2table(NaN);
            end
            density = NameValueArgs.DataBIM.Material(1,idj).Density;
            if and(isfield(density,"Text"),isfield(density,"unitAttribute"))
                units = NameValueArgs.DataModel.PhysUnitMap.Simscape(find(NameValueArgs.DataModel.PhysUnitMap.Revit==density.unitAttribute),1);
                units = convertCharsToStrings(units{1,1});
                DensityVal = simscape.Value(density.Text,units);
                DensityVal = value(DensityVal,"kg/m^3");
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Density [kg/m^3]",j) = array2table(DensityVal);
            else
                NameValueArgs.DataModel.WallMaterial.Data.(wallList(1,i))("Density [kg/m^3]",j) = array2table(NaN);
            end
        end
    end
    NameValueArgs.DataModel.WallMaterial.Listing = table(wallList',wallPropertyDefinition','VariableNames',["Wall", "Wall Material"]);
    modelDataUpdated = NameValueArgs.DataModel;
end