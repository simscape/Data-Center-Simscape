function loadBlockData(blockPath, data)
   % data = load(matFile, 'maskNames', 'maskExprs', 'varNames', 'varValues');

    % Restore mask parameter expressions
    for k = 1:numel(data.maskNames)
        set_param(blockPath, data.maskNames{k}, data.maskExprs{k});
    end
   % fprintf('Mask parameter expressions and workspace variables loaded from base workspace');
end