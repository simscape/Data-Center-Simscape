% Function to plot daylight duration.

% Copyright 2024 The MathWorks, Inc.

function plotDaylightDurationForLocation(solarData,location,dayNumVec,equinoxSolstice)
    plotTitle = strcat("Daylight Hours at : ",location);
    figure('Name',plotTitle);
    dayLight = solarData.("12:00 hrs").("sunset") - solarData.("12:00 hrs").("sunrise");
    plot(dayNumVec,dayLight','-b'); hold on
    plot([equinoxSolstice(1,1),equinoxSolstice(1,1)],[min(dayLight),max(dayLight)],'m--'); hold on
    plot([equinoxSolstice(1,2),equinoxSolstice(1,2)],[min(dayLight),max(dayLight)],'r--'); hold on
    plot([equinoxSolstice(1,3),equinoxSolstice(1,3)],[min(dayLight),max(dayLight)],'c--'); hold on
    plot([equinoxSolstice(1,4),equinoxSolstice(1,4)],[min(dayLight),max(dayLight)],'b--'); hold off
    ylabel('Day Light Hours');
    monthForPlotting = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
    xticks(15:30:365);xticklabels(monthForPlotting);
    legend('Day Light Time','Vernal Equinox','Summer Solstice','Autumnal Equinox','Winter Solstice');
    title(plotTitle); grid('on');
end