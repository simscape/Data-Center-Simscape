function newApartment = copyMoveRotateForNewApartment(NameValueArgs)
% Function to create a new copy of the apartment by moving it a certain
% distance and/or rotating it by a certain angle (degree).
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.Apartment struct {mustBeNonempty}
        NameValueArgs.MoveDistance (1,2) simscape.Value
        NameValueArgs.RotationAngle (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.RotationAngle, "deg")}
        NameValueArgs.RotateAboutRoom string
        NameValueArgs.Tol (1,1) {mustBeNonnegative, mustBeLessThan(NameValueArgs.Tol,100)}
    end

    nRooms = numel(fieldnames(NameValueArgs.Apartment));
    oneAptUnit = [];
    degVal = value(NameValueArgs.RotationAngle,'deg');
    rotateAboutVertex = [0,0];
    id = 0; errorInRotation = false;
    if degVal ~= 0
        for i = 1:nRooms
            if NameValueArgs.Apartment.("room"+num2str(i)).name == NameValueArgs.RotateAboutRoom
                id = i;
            end
        end
        errorInRotation = false;
        if id ~= 0
            rotateAboutVertex = NameValueArgs.Apartment.("room"+num2str(id)).geometry.dim.vertex + value(NameValueArgs.MoveDistance,'m');
        else
            errorInRotation = true;
        end
    end
    if ~errorInRotation
        for i = 1:nRooms
            length     = NameValueArgs.Apartment.("room"+num2str(i)).geometry.dim.length;
            width      = NameValueArgs.Apartment.("room"+num2str(i)).geometry.dim.width;
            theta      = NameValueArgs.Apartment.("room"+num2str(i)).geometry.dim.theta + degVal;
            vertex     = NameValueArgs.Apartment.("room"+num2str(i)).geometry.dim.vertex + value(NameValueArgs.MoveDistance,'m');
            if degVal ~= 0 && i ~= id
                [delX,delY] = rotateVerticesAboutAnotherPoint(vertex,rotateAboutVertex,degVal);
                vertex = vertex - [delX,delY];
            end
            roomName   = NameValueArgs.Apartment.("room"+num2str(i)).name;
            roomModel  = addNewRoomToFloorPlan(vertex,width,length,theta,roomName);
            oneAptUnit = [oneAptUnit,roomModel];
        end
        newApartment = defineSingleApartmentUnit(Apartment=oneAptUnit,Tol=NameValueArgs.Tol);
    else
        disp('Error encountered during rotation. You must ensure you have provided a valid room name to rotate the unit about.');
        newApartment = [];
    end
end