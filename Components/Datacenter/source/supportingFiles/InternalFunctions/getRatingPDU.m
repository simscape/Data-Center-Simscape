function rating = getRatingPDU(NameValueArgs)
    arguments (Input)
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.BlockType string {mustBeMember(NameValueArgs.BlockType,["Single Rack","PDU","PDU Assembly"])}
    end

    arguments (Output)
        rating simscape.Value {simscape.mustBeCommensurateUnit(rating, "kW")}
    end
    
    val = str2double(get_param(NameValueArgs.BlockPath,"nGPU"));
    valUnit = "1"; % Simulink mask has no units; Add units as per mask.
    nGPU = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"gpuExponent"));
    valUnit = "1"; % Simulink mask has no units; Add units as per mask.
    gpuExponent = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"gpuIdlePower"));
    valUnit = "W"; % Simulink mask has no units; Add units as per mask.
    gpuIdlePower = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"gpuTDPperDie"));
    valUnit = "W"; % Simulink mask has no units; Add units as per mask.
    gpuTDPperDie = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"gpuHBMpower"));
    valUnit = "W"; % Simulink mask has no units; Add units as per mask.
    gpuHBMpower = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"gpuHBMutil"));
    valUnit = "1"; % Simulink mask has no units; Add units as per mask.
    gpuHBMutil = simscape.Value(val,valUnit);

    % CPU values
    val = str2double(get_param(NameValueArgs.BlockPath,"nCPU"));
    valUnit = "1"; % Simulink mask has no units; Add units as per mask.
    nCPU = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"cpuExponent"));
    valUnit = "1"; % Simulink mask has no units; Add units as per mask.
    cpuExponent = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"cpuIdlePower"));
    valUnit = "W"; % Simulink mask has no units; Add units as per mask.
    cpuIdlePower = simscape.Value(val,valUnit);

    val = str2double(get_param(NameValueArgs.BlockPath,"cpuTDPperSocket"));
    valUnit = "W"; % Simulink mask has no units; Add units as per mask.
    cpuTDPperSocket = simscape.Value(val,valUnit);

    if NameValueArgs.BlockType == "Single Rack"
        val = str2double(get_param(NameValueArgs.BlockPath,"nTrays"));
        valUnit = "1"; % Simulink mask has no units; Add units as per mask.
        scalingFactor = simscape.Value(val,valUnit);
    elseif NameValueArgs.BlockType == "PDU"
        val1 = str2double(get_param(NameValueArgs.BlockPath,"nTrays"));
        valUnit1 = "1"; % Simulink mask has no units; Add units as per mask.
        val2 = str2double(get_param(NameValueArgs.BlockPath,"nRacks"));
        valUnit2 = "1"; % Simulink mask has no units; Add units as per mask.
        scalingFactor = simscape.Value(val1,valUnit1)*simscape.Value(val2,valUnit2);
    elseif NameValueArgs.BlockType == "PDU Assembly"
        val1 = str2double(get_param(NameValueArgs.BlockPath,"nTrays"));
        valUnit1 = "1"; % Simulink mask has no units; Add units as per mask.
        val2 = str2double(get_param(NameValueArgs.BlockPath,"nRacks"));
        valUnit2 = "1"; % Simulink mask has no units; Add units as per mask.
        val3 = str2double(get_param(NameValueArgs.BlockPath,"nAssembly"));
        valUnit3 = "1"; % Simulink mask has no units; Add units as per mask.
        scalingFactor = simscape.Value(val1,valUnit1)*simscape.Value(val2,valUnit2)*simscape.Value(val3,valUnit3);
    else
        error(strcat("Incorrect BlockType parameter set (",NameValueArgs.BlockType,")"));
    end

    [powGPUperTray,powCPUperTray] = ...
        getPowerConsumption(NumOfCPUperTray=nCPU, ...
                            CPUexponent=cpuExponent, ...
                            CPUidlePower=cpuIdlePower, ...
                            CPUtdp=cpuTDPperSocket, ...
                            NumOfGPUperTray=nGPU, ...
                            GPUexponent=gpuExponent, ...
                            GPUhbmPower=gpuHBMpower, ...
                            GPUhbmUtilFrac=gpuHBMutil, ...
                            GPUidlePower=gpuIdlePower, ...
                            GPUtdp=gpuTDPperDie, ...
                            UtilizationCPU=simscape.Value(1,"1"), ...
                            UtilizationGPU=simscape.Value(1,"1"));

    rating = (powGPUperTray+powCPUperTray)*scalingFactor;

    ratingVal = value(rating,"W");
    findOutputUnit = log10(abs(ratingVal));
    if findOutputUnit >= 9 % Giga
        divBy = 10^9;
        ratingUnit = "GW";
    elseif and(findOutputUnit<9,findOutputUnit>=6) % Mega
        divBy = 10^6;
        ratingUnit = "MW";
    elseif and(findOutputUnit<6,findOutputUnit>=3) % Kilo
        divBy = 10^3;
        ratingUnit = "kW";
    else
        divBy = 1;
        ratingUnit = "W";
    end
    rating = simscape.Value(round(ratingVal/divBy,2),ratingUnit);
end