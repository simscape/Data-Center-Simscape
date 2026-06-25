% Function to plot solar angle data at noon time.

% Copyright 2024 The MathWorks, Inc.

function plotSolarAngleDataAtNoon(solarData,place,days,labels)
    plotTitle = strcat("At 12:00 hrs, ",place);
    figure('Name',plotTitle);
    azimuthAngle_12hrs = solarData.("12:00 hrs").('surfaceAzimuthAngle');
    declinationAngle_12hrs = solarData.("12:00 hrs").('declinationAngleOnThatDay');
    plot(days,azimuthAngle_12hrs,'ro-'); hold on;
    plot(days,declinationAngle_12hrs,'b*-'); hold off;
    title(plotTitle);
    legend('Azimuth Angle','Declination Angle'); ylabel('Angle (deg)');
    xticks(days);xticklabels(labels);
end