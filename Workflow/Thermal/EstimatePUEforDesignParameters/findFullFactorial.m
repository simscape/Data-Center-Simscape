% Copyright 2026 The MathWorks, Inc.

function combos = findFullFactorial(paramValues)
    nParams = numel(paramValues);
    sizes   = cellfun(@numel, paramValues);
    nRows   = prod(sizes);
    combos  = zeros(nRows, nParams);

    repInner = 1;
    for k = 1:nParams
        v = paramValues{k}(:).';
        repOuter = nRows / (repInner * numel(v));
        col = repmat(v, repInner, repOuter);
        combos(:, k) = col(:);
        repInner = repInner * numel(v);
    end
end
