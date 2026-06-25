function [avgDayT,avgDayTvar,avgNightT,avgNightTvar] = getTemperatureFromYearlyData(NameValueArgs)
% Function to create yearly temperature variation model.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.DateTimeVec datetime {mustBeNonempty}
        NameValueArgs.Tavg12MonthData (12,2) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.Tavg12MonthData, "K")}
        NameValueArgs.DeltaDegreesNightT (1,1) simscape.Value  {simscape.mustBeCommensurateUnit(NameValueArgs.DeltaDegreesNightT, "K")} = simscape.Value(5,"K")
        NameValueArgs.Plot {mustBeNonempty} = false
        NameValueArgs.PercentDayTimeTvar (1,1) {mustBeNonempty} = 1
        NameValueArgs.PercentNightTimeTvar (1,1) {mustBeNonempty} = 1
        NameValueArgs.Location table {mustBeNonempty}
        NameValueArgs.PlotName string = ""
    end

    nDays = days(NameValueArgs.DateTimeVec(1,end)-NameValueArgs.DateTimeVec(1,1));
    vecDays = ones(nDays,1);
    vecDays(1,1) = day(NameValueArgs.DateTimeVec(1,1),"dayofyear");
    for i = 2:nDays
        valDayNum = mod(vecDays(i-1,1)+1,366);
        if valDayNum == 0, valDayNum = 366; end
        vecDays(i,1) = valDayNum;
    end
    
    vecYrs = unique(year(NameValueArgs.DateTimeVec));
    nYrs = length(vecYrs);
    avgDayT = zeros(1,nDays);

    if length(unique(month(NameValueArgs.DateTimeVec,"monthofyear"))) < 3
        disp("*** Use this function for dateTime values of a quarter (of year) or more.");
        avgDayT = simscape.Value(0,"K");
        avgNightT = simscape.Value(0,"K");
        avgDayTvar = simscape.Value(0,"1");
        avgNightTvar = simscape.Value(0,"1");
    else
        if strcmp("N",NameValueArgs.Location.Latitude{1,1}(end)) || strcmp("n",NameValueArgs.Location.Latitude{1,1}(end))
            northernHemis = true;
        else
            northernHemis = false;
        end
        data = value(NameValueArgs.Tavg12MonthData,"K");
        monthlyData = repmat(data,[nYrs,1]);
        minT = smoothdata(monthlyData(:,1));
        maxT = smoothdata(monthlyData(:,2));
        dt = NameValueArgs.DateTimeVec(1:24:end);
        mt = month(dt);
        dy = day(dt,"dayofyear");
        yr = year(dt) - year(dt(1,1)) + 1;
        for i = 1:length(dy)
            % Each full day is covered and hence each 
            idx = (yr(1,i)-1)*12 + mt(1,i);
            if day(dt(1,i),"dayofmonth") > 15
                x = min(1,max(0,30-day(dt(1,i),"dayofmonth"))/30);
                if and(northernHemis,mt(1,i)<=6)
                    avgDayT(1,i) = maxT(idx,1)*x + minT(idx+1,1)*(1-x);
                elseif and(northernHemis,mt(1,i)>6)
                    avgDayT(1,i) = minT(idx,1)*x + maxT(min(nYrs*12,idx+1),1)*(1-x);
                elseif and(~northernHemis,mt(1,i)<=6)
                    avgDayT(1,i) = maxT(idx,1)*x + minT(idx+1,1)*(1-x);
                elseif and(~northernHemis,mt(1,i)>6)
                    avgDayT(1,i) = minT(idx,1)*x + maxT(min(nYrs*12,idx+1),1)*(1-x);
                else
                    avgDayT(1,i) = (maxT(idx,1)+minT(idx,1))/2;
                end
            else
                x = min(1,max(0,15-day(dt(1,i),"dayofmonth"))/30);
                if and(northernHemis,mt(1,i)<=6)
                    avgDayT(1,i) = minT(idx,1)*x + maxT(max(1,idx-1),1)*(1-x);
                elseif and(northernHemis,mt(1,i)>6)
                    avgDayT(1,i) = maxT(idx,1)*x + minT(idx-1,1)*(1-x);
                elseif and(~northernHemis,mt(1,i)<=6)
                    avgDayT(1,i) = minT(idx,1)*x + maxT(max(1,idx-1),1)*(1-x);
                elseif and(~northernHemis,mt(1,i)>6)
                    avgDayT(1,i) = maxT(idx,1)*x + minT(idx-1,1)*(1-x);
                else
                    avgDayT(1,i) = (maxT(idx,1)+minT(idx,1))/2;
                end
            end
                
        end
        avgDayT = smoothdata(avgDayT);
        avgDayT = avgDayT(1:nDays);
        avgNightT = avgDayT-value(NameValueArgs.DeltaDegreesNightT,"K");
        avgDayTvar = NameValueArgs.PercentDayTimeTvar;
        avgNightTvar = NameValueArgs.PercentNightTimeTvar;
        if NameValueArgs.Plot
            [~,~,sunriseTvec,sunsetTvec] = getSunriseSunsetData(DateTimeVector=NameValueArgs.DateTimeVec,...
                                                                Location=NameValueArgs.Location);
            dispStr = strcat("Day Light Time & Temperature :",NameValueArgs.PlotName);
            figure("Name",dispStr);
            yyaxis left; 
            plot(NameValueArgs.DateTimeVec(1:24:nDays*24),round((sunsetTvec-sunriseTvec)/3600,1),LineWidth=1.5);
            ylim([0,24]); ylabel("Day Length (Hours)");
            yyaxis right; 
            plot(NameValueArgs.DateTimeVec(1:24:nDays*24),avgDayT); hold on; 
            plot(NameValueArgs.DateTimeVec(1:24:nDays*24),avgNightT); hold off; 
            legend("Day Length","Avg. Temperature (Day)", " Avg. Temperature (Night)",Location="southwest");
            title(dispStr);
            xlabel("Day");ylabel("Temperature [K]");
        end
    end

    avgDayT = simscape.Value(avgDayT,"K");
    avgNightT = simscape.Value(avgNightT,"K");
end