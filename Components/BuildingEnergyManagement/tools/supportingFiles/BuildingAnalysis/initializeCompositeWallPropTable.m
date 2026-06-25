function tbl = initializeCompositeWallPropTable(NameValueArgs)
% Function to initialize data for a composite wall definition.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.NumLayer (1,1) {mustBeNonnegative,mustBeNonNan}
        NameValueArgs.LayerName (1,:) string {mustBeNonempty} = ""
    end

    Property = ["Absorptivity [-]", "Thickness [m]", "Density [kg/m^3]", "Heat Capacity [J/kg-K]", "Thermal Conductivity [W/K-m]"]';
    nProp = length(Property);
    tblColumn = strings(1,NameValueArgs.NumLayer);
    if or(strcmp(NameValueArgs.LayerName,""),length(NameValueArgs.LayerName)~=NameValueArgs.NumLayer)
        for i = 1:NameValueArgs.NumLayer
            tblColumn(1,i) = strcat("Layer"+num2str(i));
        end
    else
        for i = 1:NameValueArgs.NumLayer
            tblColumn(1,i) = NameValueArgs.LayerName(1,i);
        end
    end
    varType = strings(1,NameValueArgs.NumLayer);
    varType(1:end) = "double";
    tbl = table(Size=[nProp,NameValueArgs.NumLayer],VariableTypes=varType,RowNames=Property,VariableNames=tblColumn);
end