function createDataCenterWithEnclosure(NameValueArgs)
% Build datacenter of desired fidelity and rating in a rectangular room.
% 
% For more details, see <a href="matlab:web('DocumentationDataCenterUtilities.html')">Data Center Utilities</a>
% 
% Copyright 2025 - 2026 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.NumPDUunitsX (1,1) {mustBeGreaterThan(NameValueArgs.NumPDUunitsX,1)}
        NameValueArgs.NumPDUunitsY (1,1) {mustBeGreaterThan(NameValueArgs.NumPDUunitsY,1)}
        NameValueArgs.ModelName string {mustBeText}
        NameValueArgs.ModelOption string {mustBeMember(NameValueArgs.ModelOption,["Thermal","Electrothermal","Electrical"])}
        NameValueArgs.RatingDatacenter (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RatingDatacenter, "kW")}
        NameValueArgs.ThermalRes (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.ThermalRes, "K/W")} = simscape.Value(1, "K/W")
        NameValueArgs.ServerNamePlateRating (6,2) table {mustBeNonempty} = array2table(zeros(6,2))
        NameValueArgs.ServerPowerSystemSpec (5,1) table {mustBeNonempty} = array2table(zeros(5,1))
        NameValueArgs.ModelEnclosure logical {mustBeNumericOrLogical} = true
        NameValueArgs.EnclosureName string {mustBeText} = "Room"
        NameValueArgs.RoomLength (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomLength, "m")} = simscape.Value(1, "m")
        NameValueArgs.RoomWidth (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomWidth, "m")} = simscape.Value(1, "m")
        NameValueArgs.RoomHeight (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomHeight, "m")} = simscape.Value(1, "m")
        NameValueArgs.WallThickness (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.WallThickness, "m")} = simscape.Value(1, "m")
        NameValueArgs.RoomRotate (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RoomRotate, "deg")} = simscape.Value(0, "deg")
        NameValueArgs.PercentAirVolInRoom (1,1) {mustBeBetween(NameValueArgs.PercentAirVolInRoom,0,100)} = 10
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.SaveAtFullPath string {mustBeNonempty} = "NotDefined"
        NameValueArgs.SaveModelAs string {mustBeMember(NameValueArgs.SaveModelAs,["Model","Library","Subsystem"])} = "Library"
    end
    
    % Check if server optional data is specified
    data = getDataCenterNamePlateRatingTable;
    if sum(sum(table2array(NameValueArgs.ServerNamePlateRating))) == 0
        serverNamePlateRating = data.nameplateRating;
    else
        serverNamePlateRating = NameValueArgs.ServerNamePlateRating;
    end
    if NameValueArgs.Diagnostics
        disp("*** Server rating for Data Center ***");
        disp(" ");
        disp(serverNamePlateRating);
        disp(" ");
    end
    if sum(sum(table2array(NameValueArgs.ServerPowerSystemSpec))) == 0
        serverPowerSystemSpec = data.powerSystemSpecs;
    else
        serverPowerSystemSpec = NameValueArgs.ServerPowerSystemSpec;
    end
    if NameValueArgs.Diagnostics
        disp("*** Power system specification for Data Center ***");
        disp(" ");
        disp(serverPowerSystemSpec);
        disp(" ");
    end

    if exist(NameValueArgs.ModelName,"file") > 0
        modelFileName = strcat(NameValueArgs.ModelName,"_1");
    else
        modelFileName = NameValueArgs.ModelName;
    end

    % Open Model.
    open_system(new_system(modelFileName,NameValueArgs.SaveModelAs));
    
    % Add datacenter of Thermal option to the model.
    datacenter = buildDataCenter(NumPDUunitsX=NameValueArgs.NumPDUunitsX,...
                                 NumPDUunitsY=NameValueArgs.NumPDUunitsY,...
                                 ModelName=modelFileName,...
                                 ModelOption=NameValueArgs.ModelOption,...
                                 RatingDatacenter=NameValueArgs.RatingDatacenter,...
                                 ServerNamePlateRating=serverNamePlateRating,...
                                 ServerPowerSystemSpec=serverPowerSystemSpec,...
                                 ThermalRes=NameValueArgs.ThermalRes,...
                                 Diagnostics=NameValueArgs.Diagnostics);
    if and(NameValueArgs.ModelEnclosure,NameValueArgs.ModelOption~="Electrical")
        % Add room to around the datacenter unit.
        roomModel = buildEnclosureForDataCenter(ModelName=modelFileName,...
                                                DatacenterModel=datacenter,...
                                                EnclosureName=NameValueArgs.EnclosureName,...
                                                PercentAirVolInRoom=NameValueArgs.PercentAirVolInRoom,...
                                                RoomLength=NameValueArgs.RoomLength,...
                                                RoomWidth=NameValueArgs.RoomWidth,...
                                                RoomHeight=NameValueArgs.RoomHeight,...
                                                WallThickness=NameValueArgs.WallThickness,...
                                                RoomRotate=NameValueArgs.RoomRotate,...
                                                Diagnostics=NameValueArgs.Diagnostics);
    else
        roomModel = "Not Specified";
    end
    % Save and close datacenter custom library
    if NameValueArgs.SaveAtFullPath ~= "NotDefined"
        saveFileLoc = fullfile(NameValueArgs.SaveAtFullPath,modelFileName);
        save_system(modelFileName,saveFileLoc);
        close_system(modelFileName);
        save(saveFileLoc,'datacenter','roomModel');
        if NameValueArgs.Diagnostics, disp(strcat("Build completed. To get started, open the model file '",...
                saveFileLoc,"' and copy the subsystem 'Datacenter' and '",NameValueArgs.EnclosureName,...
                "' on to your model canvas.")); 
        end
    else
        if NameValueArgs.Diagnostics, disp("Build completed. Save the file at your desired location."); end
    end

end