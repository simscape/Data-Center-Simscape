% Copyright 2026 The MathWorks, Inc.

function modelData = setSimulationDateTime(NameValueArgs)
    arguments (Input)
        NameValueArgs.ModelInfo struct
        NameValueArgs.StartTime datetime {mustBeNonempty}
        NameValueArgs.NumOfWeeks (1,1) {mustBeGreaterThanOrEqual(NameValueArgs.NumOfWeeks,1)}
    end
    modelData = NameValueArgs.ModelInfo;
    modelData.StartDate = NameValueArgs.StartTime;
    modelData.EndDate = modelData.StartDate + days(NameValueArgs.NumOfWeeks*7+1);
    modelData.DateTimeVec  = modelData.StartDate:hours(1):modelData.EndDate;
    disp(strcat("Start Date ",string(modelData.StartDate)," till End Date ",string(modelData.EndDate)));
end