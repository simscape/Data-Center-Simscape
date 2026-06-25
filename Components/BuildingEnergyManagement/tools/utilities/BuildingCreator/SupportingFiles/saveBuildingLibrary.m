function saveBuildingLibrary(NameValueArgs)
% Save building library
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.ModelName string {mustBeNonempty}
        NameValueArgs.ModelData struct {mustBeNonempty}
        NameValueArgs.AddToProjectPath logical {mustBeNumericOrLogical} = false
        NameValueArgs.AddIcon logical {mustBeNumericOrLogical} = true
    end

    libLocation = fullfile(matlab.project.rootProject().RootFolder,"ScriptsData","BuildingLib",NameValueArgs.ModelName);
    % Create a directory for the building library if it doesn't exist
    if exist(libLocation, 'dir')
        disp(strcat("*** ERROR *** The directory ",libLocation," exists; specify a new name for the model."));
    else
        if bdIsLoaded(NameValueArgs.ModelName)
            mkdir(libLocation);
            fileName = strcat("lib_",NameValueArgs.ModelName);
            % Model File
            filePath_slx = fullfile(libLocation,strcat(fileName,".slx"));
            save_system(NameValueArgs.ModelName,filePath_slx);
            filePath_mat = fullfile(libLocation,strcat(fileName,".mat"));
            buildingBlockLayoutData = NameValueArgs.ModelData;
            save(filePath_mat,'buildingBlockLayoutData');
            if NameValueArgs.AddToProjectPath
                pathToAdd = genpath(libLocation);
                addpath(pathToAdd);
            end
            if NameValueArgs.AddIcon
            % Icon
                figure("Name","Create Building Icon");
                plot3DlayoutBuilding(Building=NameValueArgs.ModelData.bldgBlockPath.partFileBuilding,...
                    PlotViewDirection=[-1 -1 1],ColorScheme="simple"); 
                axis("on"); colorbar("off"); 
                xlabel("East/West","Visible","off"); 
                ylabel("North/South","Visible","off");
                imgFileName = strcat(fileName,".png");
                exportgraphics(gcf,imgFileName);%saveas(gcf,imgFileName);
                movefile(imgFileName,libLocation);
                % Apply icon as mask
                blockPath = strcat(fileName,filesep,strcat(NameValueArgs.ModelData.BuildingLibraryName,"Lib"));
                Simulink.Mask.create(blockPath);
                maskObj = Simulink.Mask.get(blockPath);
                maskObj.Display = strcat("image('",imgFileName,"')");%sprintf('image(''%s'')', fullfile(libLocation,imgFileName));
                maskObj.IconOpaque = "opaque-with-ports";
                % Save SLX file
                save_system(fileName);
            end
            disp(strcat("*** SUCCESS *** Library data saved in folder :",libLocation));
        else
            disp(strcat("*** ERROR *** The model file ",NameValueArgs.ModelName,".slx is not loaded."));
        end
    end
end