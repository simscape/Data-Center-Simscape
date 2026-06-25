function [buildingBlockPathData,success] = createBuildingLibrary(NameValueArgs)
% Create building library
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingPartFile string {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.ModelType string {mustBeMember(NameValueArgs.ModelType,["Heat Load Analysis","Building Energy System (TL)"])} = "Heat Load Analysis"
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end
    
    try
        readBuildingDataXML(FileName=NameValueArgs.BuildingPartFile);
        success = true;
    catch exception
        success = false;
        disp(strcat("*** FATAL ERROR *** Unable to read the file ",NameValueArgs.BuildingPartFile,". It must be a valid filename, the valid extension (must be .xml), and must be added to the project path."));
    end

    if success
        % Create building model on Simulink Canvas.
        [buildingBlockPathData.bldgBlockPath,buildingBlockPathData.msg] = ...
            createBuildingComponentFromPartFile(BuildingPartFile=NameValueArgs.BuildingPartFile,...
            BuildingLibraryName=NameValueArgs.BuildingLibraryName,Diagnostics=NameValueArgs.Diagnostics,...
            ModelType=NameValueArgs.ModelType,DiagnosticMsgStart=1);
        
        buildingBlockPathData.ModelType = NameValueArgs.ModelType;
        
        buildingBlockPathData.BuildingLibraryName = NameValueArgs.BuildingLibraryName;
    end
end