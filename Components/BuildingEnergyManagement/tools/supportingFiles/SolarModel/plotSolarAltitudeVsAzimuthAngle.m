% Function to plot solar altitude with azimuthal angle.

% Copyright 2024 The MathWorks, Inc.

function plotSolarAltitudeVsAzimuthAngle(solarData,location,hours,days,dayLabels)
    plotTitle = strcat("Location : ",location);
    figure('Name',plotTitle);
    for i = 1:length(days)
        angle1 = zeros(1,length(hours));
        angle2 = zeros(1,length(hours));
        for j = 1:length(hours)
            atTime = strcat(num2str(hours(1,j)),':00 hrs');
            angle1(1,j) = solarData(i,:).(atTime).('solarAltitudeDeg');
            angle2(1,j) = solarData(i,:).(atTime).('surfaceAzimuthAngle');
        end
        plot(angle2,angle1); hold on;
    end
    hold off
    xlabel('Azimuth Angle (deg)');
    ylabel('Solar Altitude (deg)');
    title(plotTitle);legend(dayLabels);
end