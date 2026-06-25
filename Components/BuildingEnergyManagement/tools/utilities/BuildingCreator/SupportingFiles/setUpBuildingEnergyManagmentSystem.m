function result = setUpBuildingEnergyManagmentSystem(NameValueArgs)
% Set up building thermal management system model.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.NewModelName string {mustBeNonempty} = "BuildingModel"
        NameValueArgs.BuildingLibName string {mustBeNonempty}
        NameValueArgs.LibDisplaySize (1,1) {mustBeNonnegative} = 100
        NameValueArgs.LibStartPositionOnCanvas (1,2) {mustBeNonempty} = [400 100]
        NameValueArgs.AddEnvironmentBlocks logical {mustBeNumericOrLogical} = true
        NameValueArgs.EnvLibDisplaySize (1,1) {mustBeNonnegative} = 50
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.EndTime datetime {mustBeNonempty}
        NameValueArgs.SingleTemperatureModel logical {mustBeNumericOrLogical}
        NameValueArgs.SingleTemperatureInit (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.SingleTemperatureInit, "K")} = simscape.Value(300,"K")
    end
    
    setLibraryPathReferences;
    prjRoot = currentProject().RootFolder;
    dirFullPath = fullfile(prjRoot, "ScriptsData","BuildingLib",NameValueArgs.BuildingLibName);
    libExists = isfolder(dirFullPath);
    nDays = days(NameValueArgs.EndTime-NameValueArgs.StartTime);
    result = false;
    if libExists
        libModelData = load(strcat(dirFullPath,filesep,"lib_",NameValueArgs.BuildingLibName,".mat"));
        libModelType = libModelData.buildingBlockLayoutData.ModelType;
        %% Open Model
        sscnew(NameValueArgs.NewModelName);
        %% Set solver
        if libModelType == "Heat Load Analysis"
            set_param(NameValueArgs.NewModelName,"Solver","ode1be");
            set_param(NameValueArgs.NewModelName,"FixedStep",num2str(3600));
        elseif libModelType == "Building Energy System (TL)"
            set_param(NameValueArgs.NewModelName,"Solver","daessc");
            set_param(NameValueArgs.NewModelName,"MaxStep",num2str(1));
        else
            error("Unable to set Solver for model. ModelType not found.");
        end
        %% Add building library
        blkNameBuilding = strcat(NameValueArgs.NewModelName,"/",NameValueArgs.BuildingLibName);
        libPath = fullfile(strcat("lib_",NameValueArgs.BuildingLibName),strcat(NameValueArgs.BuildingLibName,"Lib"));
        libBlkLoc = [NameValueArgs.LibStartPositionOnCanvas,NameValueArgs.LibStartPositionOnCanvas+NameValueArgs.LibDisplaySize];
        add_block(libPath,blkNameBuilding,"Position",libBlkLoc);
        set_param(blkNameBuilding,"LinkStatus","inactive");
        %% Add and connect the environment blocks
        if NameValueArgs.AddEnvironmentBlocks
            %% Solar Radiation (LUT)
            blkNameSolar = strcat(NameValueArgs.NewModelName,"/","Solar Radiation");
            libBlkSolar = [NameValueArgs.LibStartPositionOnCanvas-[3*NameValueArgs.EnvLibDisplaySize,0],...
                           NameValueArgs.LibStartPositionOnCanvas-[3*NameValueArgs.EnvLibDisplaySize,0]+NameValueArgs.EnvLibDisplaySize];
            add_block(customBlkPath.solar,blkNameSolar,"Position",libBlkSolar);
            % set_param(blkNameSolar,"LinkStatus","inactive");
            simscape.addConnection(blkNameSolar,"S",blkNameBuilding,"Solar");
            %% Temperature source selection
            if or(nDays<3,NameValueArgs.SingleTemperatureModel)
                % Add library block
                blkNameThermal = strcat(NameValueArgs.NewModelName,"/","Ambient");
                libBlkThermal = libBlkSolar - 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(libBlkPath.temperature,blkNameThermal,"Position",libBlkThermal);
                set_param(blkNameThermal,"Orientation","left");
                val = getParamStr(num2str(value(NameValueArgs.SingleTemperatureInit,"K")));
                set_param(blkNameThermal,"temperature",val);
                simscape.addConnection(blkNameThermal,"A",blkNameBuilding,"Amb");
            else
                % Add custom library block
                blkNameThermal = strcat(NameValueArgs.NewModelName,"/","Ambient");
                libBlkThermal = libBlkSolar - 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(customBlkPath.thermal,blkNameThermal,"Position",libBlkThermal);
                % set_param(blkNameThermal,"LinkStatus","inactive");
                simscape.addConnection(blkNameThermal,"H",blkNameBuilding,"Amb");
            end
            %% Add heat pump, controls, daily scheduler - based on ModelType selected.
            if libModelType == "Heat Load Analysis"
                blkNameAdd = strcat(NameValueArgs.NewModelName,"/","Add");
                blkLocAdd = [NameValueArgs.LibStartPositionOnCanvas-[NameValueArgs.EnvLibDisplaySize,-2*NameValueArgs.EnvLibDisplaySize],...
                           NameValueArgs.LibStartPositionOnCanvas-[NameValueArgs.EnvLibDisplaySize,-2*NameValueArgs.EnvLibDisplaySize]+0.25*NameValueArgs.EnvLibDisplaySize];
                add_block(libBlkPath.addition,blkNameAdd,"Position",blkLocAdd);
                simscape.addConnection(blkNameAdd,"O",blkNameBuilding,"S");
                
                blkNameDaySchdule = strcat(NameValueArgs.NewModelName,"/","DayScheduler");
                blkLocDaySchdule = libBlkSolar + 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(customBlkPath.dailyScheduler,blkNameDaySchdule,"Position",blkLocDaySchdule);
                simscape.addConnection(blkNameDaySchdule,"S",blkNameAdd,"I1");

                blkNameQControl = strcat(NameValueArgs.NewModelName,"/","HeatControl");
                blkLocQControl = blkLocDaySchdule + 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(customBlkPath.heatSourceControl,blkNameQControl,"Position",blkLocQControl);
                simscape.addConnection(blkNameQControl,"S",blkNameAdd,"I2");
                set_param(blkNameQControl,"LinkStatus","inactive");
                
                bldgRoomData = initialize24HrRoomData(BuildingLibName=NameValueArgs.BuildingLibName);
                set24HrRoomDataSystemModel(BuildingModel=NameValueArgs.NewModelName,DayScheduleHeatSrc=bldgRoomData);
            elseif libModelType == "Building Energy System (TL)"
                blkNameDaySchdule = strcat(NameValueArgs.NewModelName,"/","DayScheduler");
                blkLocDaySchdule = libBlkSolar + 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(customBlkPath.dailyScheduler,blkNameDaySchdule,"Position",blkLocDaySchdule);
                simscape.addConnection(blkNameDaySchdule,"S",blkNameBuilding,"S");

                blkNameHP = strcat(NameValueArgs.NewModelName,"/","HeatPump");
                blkLocHP = blkLocDaySchdule + 1.5*NameValueArgs.EnvLibDisplaySize*[0,1,0,1];
                add_block(customBlkPath.heatPumpTL,blkNameHP,"Position",blkLocHP);
                simscape.addConnection(blkNameHP,"B",blkNameBuilding,"TL_A");
                simscape.addConnection(blkNameHP,"A",blkNameBuilding,"TL_B");
                set_param(blkNameHP,"LinkStatus","inactive");

                bldgRoomData = initialize24HrRoomData(BuildingLibName=NameValueArgs.BuildingLibName);
                set24HrRoomDataSystemModel(BuildingModel=NameValueArgs.NewModelName,DayScheduleHeatSrc=bldgRoomData)
            else
                %
            end
        end
        result = true;
    else
        disp(strcat("*** Error *** The Library ",NameValueArgs.BuildingLibName," cannot be found. Check if the library exists and is added to the project path."));
    end
end