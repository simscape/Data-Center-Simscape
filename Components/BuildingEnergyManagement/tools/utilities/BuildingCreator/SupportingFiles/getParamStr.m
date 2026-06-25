function strParam = getParamStr(str)
% Template for parameterizing the numeric data on model libraries
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        str string {mustBeNonempty}
    end
    strParam = strcat(str," % Parameterized on : ",string(datetime("now")));
end