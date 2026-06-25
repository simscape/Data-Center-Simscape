function monthlyAveragedHVACRequirement(NameValueArgs)
% Function to plot monthly averaged results.
%
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DateTime (1,:) datetime {mustBeNonempty}
        NameValueArgs.HeatSource (1,:) {mustBeNonempty}
        NameValueArgs.PlotTitle string {mustBeNonempty}
        NameValueArgs.PlotOption string {mustBeMember(NameValueArgs.PlotOption,["Watt","BTU per Hr"])} = "Watt"
    end
    
    OneWattToBtuPerHr = 3.412141633;

    Q = NameValueArgs.HeatSource(2:end)';
    if NameValueArgs.PlotOption == "BTU per Hr", Q = OneWattToBtuPerHr.*Q; end
    szQvec = size(Q,2);
    szTime = size(NameValueArgs.DateTime,2);
    startTime = 1;
    if szTime ~= szQvec
        startTime = max(1,szTime-szQvec)+1;
    end

    t = NameValueArgs.DateTime(startTime:end);
    
    figure("Name",strcat("Plot: ",NameValueArgs.PlotTitle));
    plot(t,Q);
    ylabel(strcat("Heat Source (",NameValueArgs.PlotOption,")"));
    title(NameValueArgs.PlotTitle);
end