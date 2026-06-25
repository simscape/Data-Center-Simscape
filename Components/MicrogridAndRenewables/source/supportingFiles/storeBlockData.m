% === User Configuration ===
%blockPath = 'BESS_Harness/Wind Farm Detailed'; % Full path to the block instance in the harness model
%matFile   = 'WindBlockData.mat';     % File to save/load everything
function data = storeBlockData(blockPath)
% === Save Mask Parameter Expressions and Workspace Variables ===
    maskObj = Simulink.Mask.get(blockPath);
    if isempty(maskObj)
        error('No mask found on block: %s', blockPath);
    end
    params = maskObj.Parameters;
    flag = any(contains({maskObj.Description},'physmod'));
    if ~flag
        data.maskNames = {params.Name};
        data.maskExprs = {params.Value};
    else
        data.maskNames = fieldnames(get_param(blockPath, 'DialogParameters'));
        data.maskExprs = cellfun(@(p) get_param(blockPath, p), data.maskNames, 'UniformOutput', false);
    end
    varNames = {};
    varValues = {};
    for k = 1:numel(data.maskExprs)
        expr = data.maskExprs{k};
        % Try to get variable name using a regexp (simple variable names only)
        tokens = regexp(expr, '^\s*([a-zA-Z]\w*)\s*$', 'tokens');
        if ~isempty(tokens)
            varName = tokens{1}{1};
            try
                varValue = evalin('base', varName);
                if ~ismember(varName, varNames)
                    varNames{end+1} = varName; %#ok<AGROW>
                    varValues{end+1} = varValue; %#ok<AGROW>
                end
            catch
                warning('Variable "%s" not found in base workspace.', varName);
            end
        end
    end
    data.varNames = varNames;
    data.varValues = varValues;