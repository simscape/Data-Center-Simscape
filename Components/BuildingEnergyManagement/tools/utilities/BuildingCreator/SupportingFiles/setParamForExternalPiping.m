function msgDisplayCount = setParamForExternalPiping(NameValueArgs)
% Set parameters for external piping.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingBlockPathData struct {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.DiagnosticMsgStart (1,1) {mustBeNonnegative} = 0
        NameValueArgs.PipingDataTable table {mustBeNonempty}
        NameValueArgs.IniTemperature (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.IniTemperature, "K")}
    end

    setLibraryPathReferences;

    fieldsToExpect = {'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding', 'blkNameRoofsAndGround', 'namePipeInletBldg', 'namePipeOutletBldg'};
    fieldsUserData = fieldnames(NameValueArgs.BuildingBlockPathData);
    
    if all(ismember(fieldsToExpect, fieldsUserData)) && bdIsLoaded(NameValueArgs.BuildingLibraryName)
        floorHeight = NameValueArgs.BuildingBlockPathData.partFileBuilding.apartment1.room1.geometry.dim.height;
        for IO = 1:2
            if IO == 1
                blkName = NameValueArgs.BuildingBlockPathData.namePipeInletBldg; % Inlet
                msgDisplayCount = NameValueArgs.DiagnosticMsgStart+1;
                msgDisplayCount = displayDiagnostics(ErrorMsg="Setting building inlet piping details.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
            else
                blkName = NameValueArgs.BuildingBlockPathData.namePipeOutletBldg; % Outlet
                msgDisplayCount = NameValueArgs.DiagnosticMsgStart+1;
                msgDisplayCount = displayDiagnostics(ErrorMsg="Setting building outlet piping details.",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
            end
            nPipe = size(blkName,1);
            for i = 1:nPipe
                [~, pipeName, ~] = fileparts(blkName(i,1));
                lvl = str2double(erase(pipeName,"VertPipe"));
                % Pipe length
                val = getParamStr(num2str(floorHeight*(lvl+1)));
                set_param(blkName(i,1),"length",val);
                set_param(blkName(i,1),"length_unit","m");
                % Pipe length additional
                val = getParamStr(num2str(0));
                set_param(blkName(i,1),"length_add",val);
                set_param(blkName(i,1),"length_add_unit","m");
                % Hydraulic diameter
                val = getParamStr(num2str(NameValueArgs.PipingDataTable.DistributorPipe("Hydraulic Diameter (m)")));
                set_param(blkName(i,1),"Dh",val);
                set_param(blkName(i,1),"Dh_unit","m");
                % Pipe cross-sectional area
                val = getParamStr(num2str(NameValueArgs.PipingDataTable.DistributorPipe("Crossectional area (m^2)")));
                set_param(blkName(i,1),"area",val);
                set_param(blkName(i,1),"area_unit","m^2");
                % Initial temperature
                val = getParamStr(num2str(value(NameValueArgs.IniTemperature,"K")));
                set_param(blkName(i,1),"T0",val);
                set_param(blkName(i,1),"T0_unit","K");
            end
        end
    end

end
