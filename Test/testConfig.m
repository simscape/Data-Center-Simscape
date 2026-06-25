function config = testConfig()
% testConfig - Test configuration for the Data Center project

% Copyright 2026 The MathWorks, Inc.

%% Get project Root
try
    projectRoot = string(currentProject().RootFolder);
catch
    try
        prj = matlab.project.loadProject(pwd);
        projectRoot = string(prj.RootFolder);
    catch
        error("testConfig:NoProject", ...
            "Could not resolve ProjectRoot. Open the MATLAB project or run from the project root.");
    end
end

%% Project Root
config.ProjectRoot = projectRoot;

%% Model Discovery
config.Models.IncludeDirectories = [fullfile("Components","BuildingEnergyManagement","test");...
                                    fullfile("Components","Datacenter","test");...
                                    fullfile("Components","EnergyStorageAndGeneration","test");...
                                    fullfile("Components","MicrogridAndRenewables","test")];




config.Models.IncludeFiles = string.empty;
config.Models.FileTypes = ["SLX-file"; "MDL-file"];
config.Models.ExcludeDirectories = string.empty;
config.Models.ExcludeFiles = string.empty;

%% Workflow Discovery
config.Workflows.IncludeDirectories = string.empty;
config.Workflows.IncludeFiles = [fullfile("Workflow","HVAC","DatacenterLiquidCooling.m"),...
                                 fullfile("Workflow","HVAC","CreateDatacenterForUtilizationAnalysis.m"),...
                                 fullfile("Workflow","CreatePlantModels","CreateDataCenterModel.m"),...
                                 fullfile("Workflow","Electrical","UPSControlDesign.m"),...
                                 fullfile("Workflow","Electrical","UPSControlDesign","UPSLVRTSupport.m")];

config.Workflows.FileTypes = ["MLX-file"; "M-file"];
config.Workflows.ExcludeDirectories = string.empty;
config.Workflows.ExcludeFiles = string.empty;

%% Custom Tests
config.CustomTests.Files = string.empty;
config.CustomTests.Directories = string.empty;

%% Code Coverage
config.CodeCoverage.IncludeDirectories = ["Components"; "Workflow"];
config.CodeCoverage.IncludeFiles = string.empty;
config.CodeCoverage.FileTypes = ["M-file"];
config.CodeCoverage.ExcludeDirectories = "Test";
config.CodeCoverage.ExcludeFiles = string.empty;

%% Reporting
config.Reports.FolderName = "DataCenter";
config.Reports.GenerateJUnitXML = true;
config.Reports.GenerateHTMLReport = true;
config.Reports.GenerateCodeCoverage = true;
config.Reports.OpenInBrowser = false;

%% Warning Suppression
config.SuppressedWarnings = [   "MATLAB:hg:AutoSoftwareOpenGL";...
                                "MATLAB:graphics:SceneNode";...
                                "MATLAB:graphics:HardwareUnavailable"];

end