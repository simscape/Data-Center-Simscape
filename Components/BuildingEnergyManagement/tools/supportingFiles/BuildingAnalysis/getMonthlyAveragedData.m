function monthlyAvg = getMonthlyAveragedData(NameValueArgs)
% Function to plot monthly averaged results.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DateTimeVec datetime {mustBeNonempty}
        NameValueArgs.Data (1,:) {mustBeNonempty}
        NameValueArgs.Plot {mustBeNonempty} = false
        NameValueArgs.DisplayData {mustBeNonempty} = false
        NameValueArgs.PlotName string {mustBeNonempty} = "data"
        NameValueArgs.PlotOption string {mustBeMember(NameValueArgs.PlotOption,["","Watt","BTU per Hr"])} = ""
    end

    if length(NameValueArgs.Data) == length(NameValueArgs.DateTimeVec)
        data = NameValueArgs.Data(2:end)';
        OneWattToBtuPerHr = 3.412141633;
        if NameValueArgs.PlotOption == "BTU per Hr", data = OneWattToBtuPerHr.*data; end
        time = NameValueArgs.DateTimeVec(2:end)';
        tbl = timetable(data,RowTimes=time);
        monthlyAvg = retime(tbl,'monthly','mean');
        if NameValueArgs.Plot
            plotName = strcat("Monthly Average Results (",NameValueArgs.PlotName,")");
            figure("Name",plotName);
            plot(monthlyAvg.Time,monthlyAvg.data);
            title(plotName);
            xlabel("Time");ylabel(strcat(NameValueArgs.PlotName," [",NameValueArgs.PlotOption,"]"));
        end
        if NameValueArgs.DisplayData
            disp(monthlyAvg);
        end
    else
        monthlyAvg = [];
        error("DateTimeVec and Data must be of same length");
    end
end