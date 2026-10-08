% Copyright 2026 The MathWorks, Inc.

function simResTblWeek = getWeeklyAvgData(logsoutFile,modelData)
    simResTbl = logsoutFile.extractTimetable;
    simResTbl = simResTbl(timerange(hours(24),hours(length(modelData.DateTimeVec))),:);
    simResTblWeek = retime(simResTbl, "regular", "mean", "TimeStep", days(7));
end