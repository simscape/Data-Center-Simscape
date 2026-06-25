function tbl = initializeBuildingMaterialProperties(NameValueArgs)
% Function to initialize building material properties.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.RoofAbsorptivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.RoofAbsorptivity, "1")} = simscape.Value(0.6, "1")
        NameValueArgs.ExternalWallAbsorptivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.ExternalWallAbsorptivity, "1")} = simscape.Value(0.6, "1")
        NameValueArgs.WindowAbsorptivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowAbsorptivity, "1")} = simscape.Value(0.4, "1")
        NameValueArgs.WindowTransmissivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowTransmissivity, "1")} = simscape.Value(0.2, "1")
        NameValueArgs.RoofThickness (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.RoofThickness, "m")} = simscape.Value(0.3, "m")
        NameValueArgs.FloorThickness (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.FloorThickness, "m")} = simscape.Value(0.3, "m")
        NameValueArgs.ExternalWallThickness (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.ExternalWallThickness, "m")} = simscape.Value(0.3, "m")
        NameValueArgs.InternalWallThickness (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.InternalWallThickness, "m")} = simscape.Value(0.3, "m")
        NameValueArgs.WindowThickness (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowThickness, "m")} = simscape.Value(0.01, "m")
        NameValueArgs.RoofDensity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.RoofDensity, "kg/m^3")} = simscape.Value(2400, "kg/m^3")
        NameValueArgs.FloorDensity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.FloorDensity, "kg/m^3")} = simscape.Value(2400, "kg/m^3")        
        NameValueArgs.ExternalWallDensity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.ExternalWallDensity, "kg/m^3")} = simscape.Value(2400, "kg/m^3")
        NameValueArgs.InternalWallDensity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.InternalWallDensity, "kg/m^3")} = simscape.Value(2400, "kg/m^3")
        NameValueArgs.WindowDensity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowDensity, "kg/m^3")} = simscape.Value(4000, "kg/m^3")
        NameValueArgs.RoofHeatCapacity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.RoofHeatCapacity, "J/(K*kg)")} = simscape.Value(750, "J/(K*kg)")
        NameValueArgs.FloorHeatCapacity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.FloorHeatCapacity, "J/(K*kg)")} = simscape.Value(750, "J/(K*kg)")
        NameValueArgs.ExternalWallHeatCapacity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.ExternalWallHeatCapacity, "J/(K*kg)")} = simscape.Value(750, "J/(K*kg)")
        NameValueArgs.InternalWallHeatCapacity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.InternalWallHeatCapacity, "J/(K*kg)")} = simscape.Value(750, "J/(K*kg)")
        NameValueArgs.WindowHeatCapacity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowHeatCapacity, "J/(K*kg)")} = simscape.Value(840, "J/(K*kg)")
        NameValueArgs.RoofThermalConductivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.RoofThermalConductivity, "W/(K*m)")} = simscape.Value(2, "W/(K*m)")
        NameValueArgs.FloorThermalConductivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.FloorThermalConductivity, "W/(K*m)")} = simscape.Value(2, "W/(K*m)")
        NameValueArgs.ExternalWallThermalConductivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.ExternalWallThermalConductivity, "W/(K*m)")} = simscape.Value(2, "W/(K*m)")
        NameValueArgs.InternalWallThermalConductivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.InternalWallThermalConductivity, "W/(K*m)")} = simscape.Value(2, "W/(K*m)")
        NameValueArgs.WindowThermalConductivity (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.WindowThermalConductivity, "W/(K*m)")} = simscape.Value(1, "W/(K*m)")
        NameValueArgs.DisplayData {mustBeNonempty} = true
    end

    Property = ["Absorptivity [-]", "Transmissivity [-]", "Thickness [m]", "Density [kg/m^3]", "Heat Capacity [J/kg-K]", "Thermal Conductivity [W/K-m]"]';
    
    Roof = zeros(size(Property,1),1); Roof(2,1) = NaN;
    Floor = zeros(size(Property,1),1); Floor(1:2,1) = NaN;
    ExternalWall = zeros(size(Property,1),1); ExternalWall(2,1) = NaN;
    InternalWall = zeros(size(Property,1),1); InternalWall(1:2,1) = NaN;
    Window = zeros(size(Property,1),1);
    
    tbl = table(Roof,Floor,ExternalWall,InternalWall,Window,RowNames=Property);
    
    %% Set default values
    % Absorptivity
    tbl{"Absorptivity [-]","Roof"} = value(NameValueArgs.RoofAbsorptivity,"1");
    tbl{"Absorptivity [-]","ExternalWall"} = value(NameValueArgs.ExternalWallAbsorptivity,"1");
    tbl{"Absorptivity [-]","Window"} = value(NameValueArgs.WindowAbsorptivity,"1");
    % Transmissivity
    tbl{"Transmissivity [-]","Window"} = value(NameValueArgs.WindowTransmissivity,"1");
    % Thickness
    tbl{"Thickness [m]","Roof"} = value(NameValueArgs.RoofThickness,"m");
    tbl{"Thickness [m]","Floor"} = value(NameValueArgs.FloorThickness,"m");
    tbl{"Thickness [m]","ExternalWall"} = value(NameValueArgs.ExternalWallThickness,"m");
    tbl{"Thickness [m]","InternalWall"} = value(NameValueArgs.InternalWallThickness,"m");
    tbl{"Thickness [m]","Window"} = value(NameValueArgs.WindowThickness,"m");
    % Density
    tbl{"Density [kg/m^3]","Roof"} = value(NameValueArgs.RoofDensity,"kg/m^3");
    tbl{"Density [kg/m^3]","Floor"} = value(NameValueArgs.FloorDensity,"kg/m^3");
    tbl{"Density [kg/m^3]","ExternalWall"} = value(NameValueArgs.ExternalWallDensity,"kg/m^3");
    tbl{"Density [kg/m^3]","InternalWall"} = value(NameValueArgs.InternalWallDensity,"kg/m^3");
    tbl{"Density [kg/m^3]","Window"} = value(NameValueArgs.WindowDensity,"kg/m^3");
    % Heat Capacity
    tbl{"Heat Capacity [J/kg-K]","Roof"} = value(NameValueArgs.RoofHeatCapacity,"J/(K*kg)");
    tbl{"Heat Capacity [J/kg-K]","Floor"} = value(NameValueArgs.FloorHeatCapacity,"J/(K*kg)");
    tbl{"Heat Capacity [J/kg-K]","ExternalWall"} = value(NameValueArgs.ExternalWallHeatCapacity,"J/(K*kg)");
    tbl{"Heat Capacity [J/kg-K]","InternalWall"} = value(NameValueArgs.InternalWallHeatCapacity,"J/(K*kg)");
    tbl{"Heat Capacity [J/kg-K]","Window"} = value(NameValueArgs.WindowHeatCapacity,"J/(K*kg)");
    % Thermal Conductivity
    tbl{"Thermal Conductivity [W/K-m]","Roof"} = value(NameValueArgs.RoofThermalConductivity,"W/(K*m)");
    tbl{"Thermal Conductivity [W/K-m]","Floor"} = value(NameValueArgs.FloorThermalConductivity,"W/(K*m)");
    tbl{"Thermal Conductivity [W/K-m]","ExternalWall"} = value(NameValueArgs.ExternalWallThermalConductivity,"W/(K*m)");
    tbl{"Thermal Conductivity [W/K-m]","InternalWall"} = value(NameValueArgs.InternalWallThermalConductivity,"W/(K*m)");
    tbl{"Thermal Conductivity [W/K-m]","Window"} = value(NameValueArgs.WindowThermalConductivity,"W/(K*m)");

    if NameValueArgs.DisplayData
        disp("*** You must not specify values marked as NaN in the table.");
        disp("*** Block default values are provided where name-value-pair are not defined.");
        disp(tbl); 
    end
end