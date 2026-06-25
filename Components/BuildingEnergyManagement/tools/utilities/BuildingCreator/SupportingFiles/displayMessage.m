function displayMessage(NameValueArgs)
% Display message template
% 
% Copyright 2025 The MathWorks, Inc.

    arguments (Input)
        NameValueArgs.ErrorMessage string {mustBeText}
        NameValueArgs.WarningMessage string {mustBeText}
        NameValueArgs.Display string {mustBeMember(NameValueArgs.Display,["Error","Warning","Error and Warning"])}
    end

    disp("**********");
    disp(" ");
    if or(NameValueArgs.Display=="Error",NameValueArgs.Display=="Error and Warning"), disp(NameValueArgs.ErrorMessage); end
    if or(NameValueArgs.Display=="Warning",NameValueArgs.Display=="Error and Warning"), disp(NameValueArgs.WarningMessage); end
    disp(" ");
    disp("**********");
end