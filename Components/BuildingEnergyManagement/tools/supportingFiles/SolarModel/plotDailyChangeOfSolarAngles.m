% Function to plot solar angle.

% Copyright 2024 The MathWorks, Inc.

function plotDailyChangeOfSolarAngles(solarData,location,fullDayHrs,daysOfTheYear,daysOfTheYearLbl)
    for i = 1:length(daysOfTheYear)
        angle1 = zeros(1,length(fullDayHrs));
        angle2 = zeros(1,length(fullDayHrs));
        for j = 1:length(fullDayHrs)
            atTime = strcat(num2str(fullDayHrs(1,j)),':00 hrs');
            angle1(1,j) = solarData(i,:).(atTime).('solarAltitudeDeg');
            angle2(1,j) = solarData(i,:).(atTime).('surfaceAzimuthAngle');
        end
        timeForPlotting = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'};
        plotTitle = strcat(daysOfTheYearLbl{1,i}," : ",location);
        figure('Name',plotTitle);
        plot(fullDayHrs,angle1,'-or'); hold on;
        plot(fullDayHrs,angle2,'-ob'); hold off; title(plotTitle);
        ylabel('Angles (deg)'); legend('Altitude Angle','Azimuth Angle');
        xticks(0:3:24); xticklabels(timeForPlotting);
        grid('on');
    end
end