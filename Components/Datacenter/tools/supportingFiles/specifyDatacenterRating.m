function specifyDatacenterRating(NameValueArgs)
% Specify datacenter rating.
% 
% Copyright 2025 - 2026 The MathWorks, Inc.

    arguments(Input)
        NameValueArgs.Datacenter struct
        NameValueArgs.RatingDatacenter (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RatingDatacenter, "kW")} = simscape.Value(50, "kW")
        NameValueArgs.ServerNamePlateRating (6,2) table {mustBeNonempty} = array2table(zeros(6,2))
        NameValueArgs.ServerPowerSystemSpec (5,1) table {mustBeNonempty} = array2table(zeros(5,1))
        NameValueArgs.ThermalRes (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.ThermalRes, "K/W")} = simscape.Value(1, "K/W")
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    desiredPower = value(NameValueArgs.RatingDatacenter,"W");
    thermalResVal_KperW = value(NameValueArgs.ThermalRes,"K/W");
    datacenter = NameValueArgs.Datacenter;

    X = size(datacenter.Servers.Name,1);
    Y = size(datacenter.Servers.Name,2);
    numPDUmatrix = X*Y;
    % Nameplate rating data
    percentPowerSupplyEff = table2array(NameValueArgs.ServerPowerSystemSpec("Power Supply Efficiency [%]","Value [unit]"));
    idlePower = table2array(NameValueArgs.ServerPowerSystemSpec("Idle Power [W]","Value [unit]"));
    ratioActualToNPV = table2array(NameValueArgs.ServerPowerSystemSpec("Ratio actual to nameplate [-]","Value [unit]"));
    massServer = table2array(NameValueArgs.ServerPowerSystemSpec("Mass [kg]","Value [unit]"));
    cpServer = table2array(NameValueArgs.ServerPowerSystemSpec("Specific heat [J/(kg*K)]","Value [unit]"));
    cpuData = table2array(NameValueArgs.ServerNamePlateRating("CPU",:));
    memData = table2array(NameValueArgs.ServerNamePlateRating("Memory",:));
    dskData = table2array(NameValueArgs.ServerNamePlateRating("Disk",:));
    pciData = table2array(NameValueArgs.ServerNamePlateRating("PCI Slot",:));
    mbdData = table2array(NameValueArgs.ServerNamePlateRating("Motherboard",:));
    fanData = table2array(NameValueArgs.ServerNamePlateRating("Fan",:));

    PDUrating = prod(cpuData)+prod(memData)+prod(dskData)+prod(pciData)+prod(mbdData)+prod(fanData);
    multFact = ratioActualToNPV/(percentPowerSupplyEff/100);
   
    n = round(desiredPower/(PDUrating*multFact*numPDUmatrix));
    if NameValueArgs.Diagnostics, disp(strcat("*** Number of servers per PDU = ",num2str(n))); end
    
    for i = 1:X
        for j = 1:Y
            % Power system specifications
            set_param(datacenter.Servers.Name(i,j),"idlePower",num2str(idlePower));
            set_param(datacenter.Servers.Name(i,j),"powerSupplyEff",num2str(percentPowerSupplyEff));
            set_param(datacenter.Servers.Name(i,j),"ratioActualToNameplate",num2str(ratioActualToNPV));
            set_param(datacenter.Servers.Name(i,j),"serverMass",num2str(massServer));
            set_param(datacenter.Servers.Name(i,j),"serverSpHeat",num2str(cpServer));
            set_param(datacenter.Servers.Name(i,j),"numCPUperServer",num2str(n));
            % Name plate rating
            set_param(datacenter.Servers.Name(i,j),"peakPowCPU",num2str(cpuData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfCPU",num2str(cpuData(1,2)));
            set_param(datacenter.Servers.Name(i,j),"peakPowMemory",num2str(memData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfMemory",num2str(memData(1,2)));
            set_param(datacenter.Servers.Name(i,j),"peakPowDisk",num2str(dskData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfDisk",num2str(dskData(1,2)));
            set_param(datacenter.Servers.Name(i,j),"peakPowPCIslot",num2str(pciData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfPCIslot",num2str(pciData(1,2)));
            set_param(datacenter.Servers.Name(i,j),"peakPowMotherboard",num2str(mbdData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfMotherboard",num2str(mbdData(1,2)));
            set_param(datacenter.Servers.Name(i,j),"peakPowFan",num2str(fanData(1,1)));
            set_param(datacenter.Servers.Name(i,j),"numOfFan",num2str(fanData(1,2)));
        end
    end
    
    if datacenter.Datacenter.Type == "Electrical"
        allThermalRes = datacenter.ThermalRes.Name;
    else
        allThermalRes = [datacenter.WallThermalRes.Name;datacenter.ThermalRes.Name];
    end

    for i = 1:size(allThermalRes,1)
        set_param(allThermalRes(i,1),"resistance",num2str(thermalResVal_KperW));
    end
end