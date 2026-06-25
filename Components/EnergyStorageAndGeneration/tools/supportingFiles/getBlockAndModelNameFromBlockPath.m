function [ModelName,ModelBlockName] = getBlockAndModelNameFromBlockPath(NameValueArgs)
% Get model and block name from the block path

% Copyright 2026 The MathWorks, Inc.

    arguments
        NameValueArgs.BlockPath string {mustBeNonempty}
    end
    
    [filepath,ModelBlockName,~] = fileparts(NameValueArgs.BlockPath);
    if contains(filepath,"/")
        locFileSep = strfind(filepath,"/");
        ModelName = filepath(1:(locFileSep(1,1)-1));
    else
        % filepath is the model name
        ModelName = filepath;
    end
end