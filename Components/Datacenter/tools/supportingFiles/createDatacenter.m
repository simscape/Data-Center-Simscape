function datacenter = createDatacenter(NameValueArgs)
% Create datacenter
% 
% Copyright 2025 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.NumPDUunitsX (1,1) {mustBeGreaterThan(NameValueArgs.NumPDUunitsX,1)}
        NameValueArgs.NumPDUunitsY (1,1) {mustBeGreaterThan(NameValueArgs.NumPDUunitsY,1)}
        NameValueArgs.ModelName string {mustBeText}
        NameValueArgs.ModelOption string {mustBeMember(NameValueArgs.ModelOption,["Electrical","Thermal","Electrothermal"])}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    % if NameValueArgs.Diagnostics, disp("Launching Simulink to create Datacenter model."); end
    % open_system(new_system(NameValueArgs.ModelName));
    baselineLocation = [400 0 450 50];

    customBlkPath.datacenter = 'datacenter_lib/Datacenter Server Unit';
    customBlkPath.load3ph = 'datacenter_lib/Custom Dynamic Load (3-phase) block';
    libBlkPath.thermalRes = 'fl_lib/Thermal/Thermal Elements/Thermal Resistance';
    libBlkPath.arrayConn = 'nesl_utility/Array Connection';
    libBlkPath.connPort = 'nesl_utility/Connection Port';
    libBlkPath.concatPS = 'fl_lib/Physical Signals/Functions/PS Concatenate';
    libBlkPath.selectorPS = 'fl_lib/Physical Signals/Nonlinear Operators/PS Selector';
    libBlkPath.dynLoad3ph = 'ee_lib/Passive/Dynamic Load (Three-Phase)';

    %% Common Features
    % Create Datacenter Subsystem
    datacenter.Datacenter.Type = NameValueArgs.ModelOption;
    datacenter.Datacenter.Name = strcat(NameValueArgs.ModelName,'/Datacenter');
    datacenterSubsystemLoc = [400 200 500 300];
    subSysLen1 = datacenterSubsystemLoc(1,3)-datacenterSubsystemLoc(1,1);
    subSysLen2 = datacenterSubsystemLoc(1,4)-datacenterSubsystemLoc(1,2);

    add_block("built-in/Subsystem",datacenter.Datacenter.Name,"Position",datacenterSubsystemLoc);

    if NameValueArgs.Diagnostics, disp("*** Created Datacenter Subsystem block."); end

    % Create ServerUnits subsystem
    datacenterServerUnits = strcat(datacenter.Datacenter.Name,'/ServerUnits');
    add_block("built-in/Subsystem",datacenterServerUnits,"Position",datacenterSubsystemLoc);
    datacenter.Servers.Location = datacenterSubsystemLoc;

    if NameValueArgs.Diagnostics, disp("*** Created Datacenter/ServerUnits Subsystem block."); end

    % Add datacenter servers to the ServerUnits subsystem
    [datacenter.Servers.Name,...
     datacenter.ThermalRes.Name] = addServerUnitsToDatacenter(X=NameValueArgs.NumPDUunitsX,...
                                                              Y=NameValueArgs.NumPDUunitsY,...
                                                              CustomBlkPath=customBlkPath,...
                                                              LibBlkPath=libBlkPath,...
                                                              ServerSubsystemName=datacenterServerUnits,...
                                                              ReferenceLocation=baselineLocation);

    if NameValueArgs.Diagnostics, disp("*** Added server units to Datacenter/ServerUnits Subsystem."); end

    % Add input Utilization port to the ServerUnits subsystem
    connectInputPortToServer(X=NameValueArgs.NumPDUunitsX,...
                             Y=NameValueArgs.NumPDUunitsY,...
                             LibBlkPath=libBlkPath,...
                             NameOfServerBlocks=datacenter.Servers.Name,...
                             ServerSubsystemName=datacenterServerUnits);
    
    % Add port for Utilization
    portUvec = strcat(datacenter.Datacenter.Name,'/Util');
    add_block(libBlkPath.connPort,portUvec,'Position',datacenterSubsystemLoc+...
        [-1.5*subSysLen1 0 -(1.5*subSysLen1+round(0.75*subSysLen1)) 0-round(0.75*subSysLen2)]);
    set_param(portUvec,'Orientation','right');
    set_param(portUvec,'Side','left');
    simscape.addConnection(datacenterServerUnits,"U",portUvec,"port");

    if NameValueArgs.Diagnostics, disp("*** Added input utilization vector port to Datacenter/ServerUnits Subsystem."); end

    %% Thermal and Electrothermal Variant
    if or(NameValueArgs.ModelOption == "Thermal", NameValueArgs.ModelOption == "Electrothermal")
        % Add array of thermal nodes to the model
        [~,datacenter.WallThermalRes.Name] = addArrayThermalNodesToServers(X=NameValueArgs.NumPDUunitsX,...
                                                                           Y=NameValueArgs.NumPDUunitsY,...
                                                                           LibBlkPath=libBlkPath,...
                                                                           NameOfServerBlocks=datacenter.Servers.Name,...
                                                                           ServerSubsystemName=datacenterServerUnits,...
                                                                           ReferenceLocation=baselineLocation);
        % Connect thermal output from servers to output node
        connectOutputPortFromServer(TypeOfPort="Thermal",...
                                    X=NameValueArgs.NumPDUunitsX,...
                                    Y=NameValueArgs.NumPDUunitsY,...
                                    LibBlkPath=libBlkPath,...
                                    NameOfServerBlocks=datacenter.Servers.Name,...
                                    ReferenceLocation=baselineLocation,...
                                    ServerSubsystemName=datacenterServerUnits);

        % Add ports
        portTvec = strcat(datacenter.Datacenter.Name,'/T');
        add_block(libBlkPath.connPort,portTvec,'Position',datacenterSubsystemLoc+...
            [1.5*subSysLen1 0 1.5*subSysLen1-round(0.75*subSysLen1) 0-round(0.75*subSysLen2)]);
        set_param(portTvec,'Orientation','left');
        set_param(portTvec,'Side','right');
        simscape.addConnection(datacenterServerUnits,"Tvec",portTvec,"port");

        if NameValueArgs.Diagnostics, disp("*** Added server temperature vector output port to Datacenter/ServerUnits Subsystem."); end

        portHnode = strcat(datacenter.Datacenter.Name,'/H');
        add_block(libBlkPath.connPort,portHnode,'Position',datacenterSubsystemLoc+...
            [1.5*subSysLen1 0-subSysLen2 1.5*subSysLen1-round(0.75*subSysLen1) 0-subSysLen2-round(0.75*subSysLen2)]);
        set_param(portHnode,'Orientation','left');
        set_param(portHnode,'Side','right');
        simscape.addConnection(datacenterServerUnits,"H",portHnode,"port");

        if NameValueArgs.Diagnostics, disp("*** Added array of thermal node to Datacenter/ServerUnits Subsystem."); end
    end
    %% Electrical and Electrothermal Variant
    if or(NameValueArgs.ModelOption == "Electrical", NameValueArgs.ModelOption == "Electrothermal")
        % Connect electrical output from servers to output node
        connectOutputPortFromServer(TypeOfPort="Electrical",...
                                    X=NameValueArgs.NumPDUunitsX,...
                                    Y=NameValueArgs.NumPDUunitsY,...
                                    LibBlkPath=libBlkPath,...
                                    NameOfServerBlocks=datacenter.Servers.Name,...
                                    ReferenceLocation=baselineLocation,...
                                    ServerSubsystemName=datacenterServerUnits);
        % Add electrical load blocks
        [datacenter.CustomLoad.Name,...
         datacenter.ThreePhaseLoad.Name] = addElectricalLoadBlocks(NumServer=NameValueArgs.NumPDUunitsX*NameValueArgs.NumPDUunitsY,...
                                                                   DatacenterSubsystemName=datacenter.Datacenter.Name,...
                                                                   LibBlkPath=libBlkPath,...
                                                                   CustomBlkPath=customBlkPath,...
                                                                   DatacenterSubsystemLoc=datacenterSubsystemLoc);
        simscape.addConnection(datacenter.CustomLoad.Name,"Pw",datacenterServerUnits,"Pvec");

        if NameValueArgs.Diagnostics, disp("*** Added server power vector output port to Datacenter/ServerUnits Subsystem."); end

        % Add node for 3-phase
        portEnode = strcat(datacenter.Datacenter.Name,'/~');
        add_block(libBlkPath.connPort,portEnode,'Position',datacenterSubsystemLoc+...
            [4*subSysLen1 0-subSysLen2 4*subSysLen1-round(0.75*subSysLen1) 0-(subSysLen2+round(0.75*subSysLen2))]);
        set_param(portEnode,'Orientation','down');
        set_param(portEnode,'Side','right');
        simscape.addConnection(datacenter.ThreePhaseLoad.Name,"N",portEnode,"port");

        if NameValueArgs.Diagnostics, disp("*** Added electrical 3-phase node to Datacenter."); end
    end

    if NameValueArgs.Diagnostics, disp("Success: Model created. Goto Simulink model and save it at your desired location."); end
end