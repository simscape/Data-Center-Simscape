function models = getFileListAtPath(NameValueArgs)
    arguments
        NameValueArgs.Path string {mustBeNonempty}
        NameValueArgs.Type string {mustBeMember(NameValueArgs.Type,["M-file","SLX-file","MDL-file","MLX-file"])}
        NameValueArgs.DisplayList logical {mustBeNumericOrLogical} = false
    end
    
    testDirs = dir(NameValueArgs.Path);
    if NameValueArgs.Type == "M-file"
        fileType = "*.m";
    elseif NameValueArgs.Type == "SLX-file"
        fileType = "*.slx";
    elseif NameValueArgs.Type == "MDL-file"
        fileType = "*.mdl";
    elseif NameValueArgs.Type == "MLX-file"
        fileType = "*.mlx";
    else
        error("Cannot identify the name-value-pair Type.");
    end
    
    testDirs = testDirs([testDirs.isdir]);

    models = strings(0,1);
    for d = testDirs(:)'
        L = dir(fullfile(d.folder, d.name, fileType));
        if ~isempty(L)
            models = [models; string(fullfile({L.folder}, {L.name}))']; %#ok<AGROW>
        end
    end
    models = unique(models);
    
    if isempty(models), warning(strcat("No file type ",fileType," found.")); end

    if NameValueArgs.DisplayList
        fprintf("[INFO] List of "+fileType+" files found: %d file(s):\n", numel(models));
        fprintf("       %s\n", strjoin(models, newline+"       "));
    end
end