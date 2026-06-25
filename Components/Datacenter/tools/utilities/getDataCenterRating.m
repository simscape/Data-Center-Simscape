function kW = getDataCenterRating(NameValueArgs)
    arguments (Input)
        NameValueArgs.BlockPath string {mustBeNonempty}
    end

    arguments (Output)
        kW (1,1) simscape.Value
    end
    
    n = str2double(get_param(NameValueArgs.BlockPath,"numCPUperServer"));
    idlePower = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="idlePower");
    peakPower = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowCPU")*str2double(get_param(NameValueArgs.BlockPath,"numOfCPU"));
    memPower  = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowMemory")*str2double(get_param(NameValueArgs.BlockPath,"numOfMemory"));
    diskPower = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowDisk")*str2double(get_param(NameValueArgs.BlockPath,"numOfDisk"));
    pciPower  = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowPCIslot")*str2double(get_param(NameValueArgs.BlockPath,"numOfPCIslot"));
    fanPower  = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowFan")*str2double(get_param(NameValueArgs.BlockPath,"numOfFan"));
    mbPower   = getSimscapeValueFromBlock(BlockPath=NameValueArgs.BlockPath,Parameter="peakPowMotherboard")*str2double(get_param(NameValueArgs.BlockPath,"numOfMotherboard"));
    
    eff = str2double(get_param(NameValueArgs.BlockPath,"ratioActualToNameplate"))/(str2double(get_param(NameValueArgs.BlockPath,"powerSupplyEff"))/100);
    kW = eff*n*(idlePower+peakPower+memPower+diskPower+pciPower+fanPower+mbPower);
end