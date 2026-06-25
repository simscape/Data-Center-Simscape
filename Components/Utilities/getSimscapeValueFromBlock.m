% Copyright 2025 - 2026 The MathWorks, Inc.

function simVal = getSimscapeValueFromBlock(NameValueArgs)
    arguments (Input)
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.Parameter string {mustBeNonempty}
    end

    arguments (Output)
        simVal simscape.Value
    end

    paramValStr = get_param(NameValueArgs.BlockPath,NameValueArgs.Parameter);
    paramUnit = get_param(NameValueArgs.BlockPath,strcat(NameValueArgs.Parameter,"_unit"));
    paramVal = str2num(paramValStr);
    simVal = simscape.Value(paramVal,paramUnit);
end