function tbl = initializeBuildingThermalParam(NameValueArgs)
% Initialize building thermal parameters.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DiameterDistributor (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.DiameterDistributor, "m")} = simscape.Value(0.005, "m")
        NameValueArgs.DiameterRadiator (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.DiameterRadiator, "m")} = simscape.Value(0.005, "m")
        NameValueArgs.DiameterUnderFloor (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.DiameterUnderFloor, "m")} = simscape.Value(0.005, "m")
        NameValueArgs.GapRadiatorPipe (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.GapRadiatorPipe, "m")} = simscape.Value(0.006, "m")
        NameValueArgs.GapUnderFloorPipe (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.GapUnderFloorPipe, "m")} = simscape.Value(0.006, "m")
        NameValueArgs.DisplayData {mustBeNonempty} = true
    end

    Property = ["Hydraulic Diameter (m)", "Inter-pipe gap (m)", "Crossectional area (m^2)"];
    DistributorPipe = zeros(size(Property,2),1);
    RadiatorPipe = zeros(size(Property,2),1);
    UnderFloorPipe = zeros(size(Property,2),1);

    if and(value(NameValueArgs.GapRadiatorPipe,"m")>value(NameValueArgs.DiameterRadiator,"m"), value(NameValueArgs.GapUnderFloorPipe,"m")>value(NameValueArgs.DiameterUnderFloor,"m"))
        tbl = table(DistributorPipe,RadiatorPipe,UnderFloorPipe,RowNames=Property);
        tbl{"Hydraulic Diameter (m)","DistributorPipe"} = value(NameValueArgs.DiameterDistributor,"m");
        tbl{"Hydraulic Diameter (m)","RadiatorPipe"} = value(NameValueArgs.DiameterRadiator,"m");
        tbl{"Hydraulic Diameter (m)","UnderFloorPipe"} = value(NameValueArgs.DiameterUnderFloor,"m");
        tbl{"Inter-pipe gap (m)","DistributorPipe"} = NaN;
        tbl{"Inter-pipe gap (m)","RadiatorPipe"} = value(NameValueArgs.GapRadiatorPipe,"m");
        tbl{"Inter-pipe gap (m)","UnderFloorPipe"} = value(NameValueArgs.GapUnderFloorPipe,"m");
        tbl{"Crossectional area (m^2)","DistributorPipe"} = (value(NameValueArgs.DiameterDistributor,"m"))^2;
        tbl{"Crossectional area (m^2)","RadiatorPipe"} = (value(NameValueArgs.DiameterRadiator,"m"))^2;
        tbl{"Crossectional area (m^2)","UnderFloorPipe"} = (value(NameValueArgs.DiameterUnderFloor,"m"))^2;
        if NameValueArgs.DisplayData
            disp("*** You must not specify values marked as NaN in the table.");
            disp("*** Block default values are provided where name-value-pair are not defined.");
            disp(tbl); 
        end
    else
        tbl = [];
        disp("*** ERROR: Pipe to pipe centerline gap must be greater than the pipe diameter.")
    end
end