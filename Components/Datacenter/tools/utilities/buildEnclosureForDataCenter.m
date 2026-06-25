function roomModel = buildEnclosureForDataCenter(NameValueArgs)
% Build rectangular room around the data center.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.ModelName string {mustBeText}
        NameValueArgs.EnclosureName string {mustBeText} = "Enclosure"
        NameValueArgs.DatacenterModel struct {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.RoomLength (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomLength, "m")}
        NameValueArgs.RoomWidth (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomWidth, "m")}
        NameValueArgs.RoomHeight (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomHeight, "m")}
        NameValueArgs.WallThickness (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.WallThickness, "m")}
        NameValueArgs.RoomRotate (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomRotate, "deg")}
        NameValueArgs.PercentAirVolInRoom (1,1) {mustBeBetween(NameValueArgs.PercentAirVolInRoom,0,100)} = 10
    end

    if bdIsLoaded(NameValueArgs.ModelName)
        if ~isempty(NameValueArgs.DatacenterModel)
            roomModel = createEnclosure(ModelName=NameValueArgs.ModelName,...
                                        DatacenterModel=NameValueArgs.DatacenterModel,...
                                        EnclosureName=NameValueArgs.EnclosureName,...
                                        Diagnostics=NameValueArgs.Diagnostics);
    
            if ~isempty(roomModel)
                specifyEnclosureSizeAndOrientation(DatacenterMatrixSize=size(NameValueArgs.DatacenterModel.Servers.Name),...
                                                   PercentAirVolInRoom=NameValueArgs.PercentAirVolInRoom,...
                                                   RoomModel=roomModel,...
                                                   RoomHeight=NameValueArgs.RoomHeight,...
                                                   RoomLength=NameValueArgs.RoomLength,...
                                                   RoomWidth=NameValueArgs.RoomWidth,...
                                                   RoomRotate=NameValueArgs.RoomRotate,...
                                                   WallThickness=NameValueArgs.WallThickness,...
                                                   Diagnostics=NameValueArgs.Diagnostics);
            else
                disp(strcat("WARNING: Skipping '",NameValueArgs.EnclosureName,"' parameterization."));
            end
        else
            disp(strcat("ERROR: Datacenter model '",NameValueArgs.DatacenterModel,"' not found."));
        end
    else
        disp(strcat("ERROR: Model '",NameValueArgs.ModelName,"' is not loaded or open."));
    end
end