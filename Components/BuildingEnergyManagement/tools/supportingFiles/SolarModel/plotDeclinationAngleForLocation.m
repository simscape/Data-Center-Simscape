% Function to plot declination angle.

% Copyright 2024 The MathWorks, Inc.

function plotDeclinationAngleForLocation(solarData,location,dayNumVec,equinoxSolstice)
    plotTitle = strcat("Declination Angle at : ",location);
    figure('Name',plotTitle);
    declinationAngleVec = solarData.("12:00 hrs").("declinationAngleOnThatDay");
    plot(dayNumVec,declinationAngleVec','-b'); hold on
    plot([equinoxSolstice(1,1),equinoxSolstice(1,1)],[min(declinationAngleVec),max(declinationAngleVec)],'m--'); hold on;
    plot([equinoxSolstice(1,2),equinoxSolstice(1,2)],[min(declinationAngleVec),max(declinationAngleVec)],'r--'); hold on;
    plot([equinoxSolstice(1,3),equinoxSolstice(1,3)],[min(declinationAngleVec),max(declinationAngleVec)],'c--'); hold on;
    plot([equinoxSolstice(1,4),equinoxSolstice(1,4)],[min(declinationAngleVec),max(declinationAngleVec)],'g--'); hold on;
    plot(dayNumVec,zeros(1,length(dayNumVec))','--k'); hold on
    plot(dayNumVec,max(declinationAngleVec)*ones(1,length(dayNumVec))','--k'); hold on
    plot(dayNumVec,min(declinationAngleVec)*ones(1,length(dayNumVec))','--k'); hold off
    ylabel('Declination Angle (deg)');
    monthForPlotting = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
    xticks(15:30:365);xticklabels(monthForPlotting);
    legend('Day Light Time','Vernal Equinox','Summer Solstice','Autumnal Equinox','Winter Solstice');
    title(plotTitle); grid('on');
end