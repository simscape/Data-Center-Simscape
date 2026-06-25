function success = checkBuildingInputDataErrors(NameValueArgs)
% Check for errors
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.ModelType string {mustBeMember(NameValueArgs.ModelType,["Heat Load Analysis","Building Energy System (TL)"])}
        NameValueArgs.PipingDataTable table {mustBeNonempty}
        NameValueArgs.SaveModel string {mustBeMember(NameValueArgs.SaveModel,["Create Model","Create Model and Save","Create Model and Save With Icon","Create Model, Save With Icon, and Update Path"])}
    end
    
    [a,b] = size(NameValueArgs.PipingDataTable);
    if and(a==3,b==3)
        modelTL = true;
    else
        modelTL = false;
    end
    
    errMsg = string;
    warnMsg = string;

    errCount = 0;
    warnCount = 0;
    success = true;
    if and(NameValueArgs.ModelType=="Building Energy System (TL)",~modelTL)
        success = false;
        errCount = errCount+1;
        errMsgStr = "If the name-value-pair ModelType is selected as 'Building Energy System (TL)', then you must specify non-zero values for the following: DiameterDistributor, DiameterUnderFloor, GapRadiatorPipe, DiameterRadiator, and GapUnderFloorPipe. These parameters are specified in PipingDataTable.";
        if errCount > 1
            errMsg = strcat(errMsg," <Error#",num2str(errCount),"> ",errMsgStr);
        else
            errMsg = strcat("<Error#",num2str(errCount),"> ",errMsgStr);
        end
    end
    if and(NameValueArgs.ModelType=="Heat Load Analysis",modelTL)
        % No errCount required as it is just a warning.
        warnCount = warnCount+1;
        warnMsgStr = "If the name-value-pair ModelType is selected as 'Heat Load Analysis', then the following parameters are not required for the model creation:(1) DiameterDistributor, (2) DiameterUnderFloor, (3) GapRadiatorPipe, (4) DiameterRadiator, and (5) GapUnderFloorPipe. These parameters are specified in PipingDataTable.";
        if warnCount > 1
            warnMsg = strcat(warnMsg," <Warning> ",warnMsgStr);
        else
            warnMsg = strcat("<Warning#",num2str(warnCount),"> ",warnMsgStr);
        end
    end
    libLocation = fullfile(matlab.project.rootProject().RootFolder,"ScriptsData","BuildingLib",NameValueArgs.BuildingLibraryName);
    if and(exist(libLocation, 'dir'),NameValueArgs.SaveModel~="Create Model")
        success = false;
        errCount = errCount+1;
        errMsgStr = strcat("You have selected SaveModel as true. The building library with all its associated file is saved under the directory ScriptsData/BuildingLib. The directory ",libLocation," name exists; you must specify a new (unique) name for BuildingLibraryName.");
        if errCount > 1
            errMsg = strcat(errMsg," <Error#",num2str(errCount),"> ",errMsgStr);
        else
            errMsg = strcat("<Error#",num2str(errCount),"> ",errMsgStr);
        end
    end

    displayMessage(ErrorMessage=errMsg,WarningMessage=warnMsg,Display="Error and Warning");
end