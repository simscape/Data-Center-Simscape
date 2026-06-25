function [modelData,dataBIM] = getBuildingDataFromBIM(NameValueArgs)
% Import BIM data stored in XML file
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.FileName string {mustBeNonempty}
        NameValueArgs.PhysUnitMappingFile string {mustBeNonempty} = "PhysicalUnitMapping.xlsx"
        NameValueArgs.PhysUnitMappingRowSize (1,1) {mustBeGreaterThan(NameValueArgs.PhysUnitMappingRowSize,0)} = 99
        NameValueArgs.Debug {mustBeNumericOrLogical} = false
        NameValueArgs.RoundOff (1,1) {mustBeNonnegative} = 1
    end

    warning off;
    if NameValueArgs.FileName == "importBuildingFiveRectRoom.xml"
        modelDataImage = "imgBuildingFiveRectRoom.png";
    elseif NameValueArgs.FileName == "importBuildingRectRoom.xml"
        modelDataImage = "imgBuildingRectRoom.jpg";
    elseif NameValueArgs.FileName == "importBuildingTshapedAndRectRoom.xml"
        modelDataImage = "imgBuildingTshapedAndRectRoom.jpg";
    elseif NameValueArgs.FileName == "importBuildingTshapedRoom.xml"
        modelDataImage = "imgBuildingTshapedRoom.jpg";
    else
        modelDataImage = "";
    end
    displayBuildingPicture(modelDataImage);

    dataBIM = readstruct(NameValueArgs.FileName);
    
    rangeFileData = strcat("A2:B",num2str(NameValueArgs.PhysUnitMappingRowSize));
    unitDat = readtable(NameValueArgs.PhysUnitMappingFile,Range=rangeFileData);
    
    modelData = readBuildingGeometryData(BuildingData=dataBIM,...
                                         PhysUnitMapping=unitDat,...
                                         Debug=NameValueArgs.Debug,...
                                         RoundOff=NameValueArgs.RoundOff);
    
    modelData.Room = checkRoomRotationConsistency(Room=modelData.Room);
    
    modelData = getWallMaterialDataFromBIM(DataBIM=dataBIM,DataModel=modelData);

    modelData.WindowProperty.Transmittance = dataBIM.WindowType.Transmittance.Text;

    modelData.BuildingImage = modelDataImage;
end