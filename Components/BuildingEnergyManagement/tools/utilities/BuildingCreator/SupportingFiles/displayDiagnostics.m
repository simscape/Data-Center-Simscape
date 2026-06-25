function count = displayDiagnostics(NameValueArgs)
% Display diagnostics message template
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.ErrorMsgNum (1,1) {mustBeNonnegative}
        NameValueArgs.ErrorMsg string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end

    if NameValueArgs.Diagnostics
        disp(strcat("(",num2str(NameValueArgs.ErrorMsgNum),") ",NameValueArgs.ErrorMsg));
        count = NameValueArgs.ErrorMsgNum+1;
    else
        count = NameValueArgs.ErrorMsgNum+1;
    end
end