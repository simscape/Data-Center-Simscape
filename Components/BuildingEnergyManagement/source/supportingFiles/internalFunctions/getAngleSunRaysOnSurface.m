function cosineAngleOfIncidence = getAngleSunRaysOnSurface(surfSlopeDeg,surfOutwardNormal,year,day,clockHrs,geoLocation,dayLightHrs)
% Function to calculate the cosine of angle of incidence on a flat surface.

% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        surfSlopeDeg (1,1) {mustBeNumeric,mustBeInRange(surfSlopeDeg,0,180)}
        surfOutwardNormal (1,2) {mustBeReal}
        year (1,1) {mustBeGreaterThan(year,0),mustBeInteger}
        day (1,1) {mustBeNumeric,mustBeInteger,mustBeGreaterThan(day,0)}
        clockHrs (1,1) {mustBeNumeric,mustBeInRange(clockHrs,0,24)}
        geoLocation (1,3) table {mustBeNonempty}
        dayLightHrs (1,1) {mustBeNumeric,mustBeNonnegative}
    end
    sunAngles = getSolarRadiationAngle(year,day,clockHrs,geoLocation,dayLightHrs);

    beta  = deg2rad(surfSlopeDeg);
    omega = deg2rad(sunAngles.solarHrAngle);
    delta = deg2rad(sunAngles.declinationAngleOnThatDay);
    phi   = deg2rad(sunAngles.solarAltitudeDeg);
    % phi   = deg2rad(str2num(geoLocation.Latitude{1,1}(1:end-1)));
    % sunRiseTime = sunAngles.sunrise;
    % sunSetTime  = sunAngles.sunset;

    % Azimuth : Angle between sun rays and south direction on a horizontal
    % plane. Negative during morning hours, positive after noon ie. 
    % sunAngles.surfaceAzimuthAngle is negative in morning, and positive
    % post noon time. The angle is measured from South (-Y axis); it is
    % positive in clockwise direction and negative in anti-clockwise
    % direction. Hence, the actual angle on the 4-quadrant plane is 
    % calculated as (270 - sunAngles.surfaceAzimuthAngle), wrt +X axis. 
    % 
    % Hence: sun is at angle = 270 - sunAngles.surfaceAzimuthAngle from +X
    % axis or East
    % 
    % Above is true for south facing surfaces in Northern hemisphere. Need
    % to account for horizontal surface orientation in the 4-quadrant
    % plane, ie. whether it is facing east, or west, or south-east, or
    % south-west.
    % 
    % surfOutwardNormal is used to estimate the surface orientation in the 
    % 4-quadrant plane. This is done in the conditional statements below.

    if strcmp(sunAngles.hemisphereNS,"Northern")
        % if surfOutwardNormal(1,2) > 0
        %     angleChangeFromSouth = min(180,max(0,90+rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
        % else
        %     angleChangeFromSouth = min(90,max(0,90-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
        % end
        % cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);
        % cosineAngleOfIncidence = max(0,cosineAngleOfIncidence);
        if surfOutwardNormal(1,2) > 0
            % North facing
            if surfOutwardNormal(1,1) == 0
                % Facing North
                cosineAngleOfIncidence = 0;
            elseif surfOutwardNormal(1,1) > 0
                % disp("Facing Towards 1st Quadrant - north east")
                angleChangeFromSouth = min(180,max(90,90+rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1)))))); %% Was PLUS sign originally
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle < 0 
                        % disp('Morning sun')
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) + abs(angleChangeFromSouth) < 90 % Afternoon sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);
                end
            else
                % Facing Towards 2nd Quadrant - north west

                % angleChangeFromSouth = min(270,max(0,270+rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                angleChangeFromSouth = min(180,max(0,90+rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
               
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle > 0 % Afternoon sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) > abs(angleChangeFromSouth) % Morning sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            end
        else
            % South facing
            if surfOutwardNormal(1,1) == 0
                % Facing South, -Y
                angleChangeFromSouth = 0;
                cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
            elseif surfOutwardNormal(1,1) > 0
                % Facing Towards 4th Quadrant - south east
                angleChangeFromSouth = -min(90,max(0,90-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle < 0 % Morning sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) + abs(angleChangeFromSouth) < 90 % Afternoon sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            elseif surfOutwardNormal(1,1) < 0
                % Facing Towards 3rd Quadrant - south west
                angleChangeFromSouth = min(90,max(0,90-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle > 0 % Afternoon sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) > abs(angleChangeFromSouth) % Morning sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromSouth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            end
        end
    else % SOUTHERN HEMISPHERE
        if surfOutwardNormal(1,2) > 0
            % North facing
            if surfOutwardNormal(1,1) == 0
                % Facing North
                angleChangeFromNorth = 0;
                cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);
            elseif surfOutwardNormal(1,1) > 0
                % Facing Towards 1st Quadrant - north east
                angleChangeFromNorth = min(90,max(0,rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle < 0 % Morning sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) + abs(angleChangeFromNorth) < 90 % Afternoon sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            else
                % Facing Towards 2nd Quadrant - north west
                angleChangeFromNorth = min(360,max(0,270-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle > 0 % Afternoon sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) > abs(angleChangeFromNorth) % Morning sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            end
        else
            % South facing
            if surfOutwardNormal(1,1) == 0
                % Facing South, -Y
                cosineAngleOfIncidence = 0;
            elseif surfOutwardNormal(1,1) > 0
                % Facing Towards 4th Quadrant - south east
                angleChangeFromNorth = min(180,max(0,90-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle < 0 % Morning sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) + abs(angleChangeFromNorth) < 90 % Afternoon sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            elseif surfOutwardNormal(1,1) < 0
                % Facing Towards 3rd Quadrant - south west
                % angleChangeFromNorth = min(270,max(0,180+rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                angleChangeFromNorth = min(180,max(0,90-rad2deg(atan(abs(surfOutwardNormal(1,2)/surfOutwardNormal(1,1))))));
                if beta > 0 % For horizontal surfaces, direction does not matter and hence the check with sunlight hours skipped.
                    if sunAngles.surfaceAzimuthAngle > 0 % Afternoon sun
                        cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                    else
                        if abs(sunAngles.surfaceAzimuthAngle) > abs(angleChangeFromNorth) % Morning sunlight still falling on surface
                            cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                        else
                            cosineAngleOfIncidence = 0;
                        end
                    end
                else
                    cosineAngleOfIncidence = getCosineAngleOfIncidenceOnSurface(phi,delta,beta,deg2rad(angleChangeFromNorth),omega);%*(clockHrs>=sunRiseTime && clockHrs<=sunSetTime);
                end
            end
        end
    end
end