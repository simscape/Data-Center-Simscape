function info = getBlockInfo(blockPath)
    [filePath,blkName,~] = fileparts(blockPath);
    hadToLoadFile = false;
    if ~bdIsLoaded(filePath)
        try
            load_system(filePath);
            hadToLoadFile = true;
        catch ME
            fprintf(2, 'Could not find "%s": %s\n', filePath, ME.message);
            info = [];
            return;
        end
    end
    if getSimulinkBlockHandle(blockPath) ~= -1
        info.isSubsystem = strcmp(get_param(blockPath, "BlockType"), "SubSystem");
        info.parentIsLibrary = strcmp(get_param(bdroot(blockPath), "BlockDiagramType"), "library");
        info.linkStatus = get_param(blockPath, "LinkStatus");
        info.referenceBlock = get_param(blockPath, "ReferenceBlock");
        info.isLibraryLink = ~isempty(info.referenceBlock);
    else
        if hadToLoadFile
            close_system(filePath,0);
        end
        info = [];
        error(strcat("Could not find block ",blkName));
    end
    if hadToLoadFile
        close_system(filePath,0);
    end
end