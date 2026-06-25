function updatedFloorplan = addRoomToFloorPlan(NameValueArgs)
% Function to add room to a floor plan.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.FloorPlan struct
        NameValueArgs.NewRoom string {mustBeNonempty}
        NameValueArgs.Vertex (1,2) simscape.Value
        NameValueArgs.Length (1,1) simscape.Value
        NameValueArgs.Width (1,1) simscape.Value
        NameValueArgs.Angle (1,1) simscape.Value {simscape.mustBeCommensurateUnit(NameValueArgs.Angle, "deg")} = simscape.Value(0, "deg")
        NameValueArgs.Plot (1,1) {mustBeMember(NameValueArgs.Plot,[1,0])} = 0
    end

    % Convert data to appropiate units
    vertex   = value(NameValueArgs.Vertex,'m');
    wid      = value(NameValueArgs.Width, 'm');
    len      = value(NameValueArgs.Length,'m');
    theta    = value(NameValueArgs.Angle, 'deg');
    roomName = NameValueArgs.NewRoom;

    roomModel = addNewRoomToFloorPlan(vertex,wid,len,theta,roomName);
    updatedFloorplan = [NameValueArgs.FloorPlan,roomModel];
        
    if NameValueArgs.Plot
        strName = [];
        for i = 1:length(updatedFloorplan)
            if i>1
                strName = strcat(strName,', ',updatedFloorplan(1,i).name);
            else
                strName = updatedFloorplan(1,i).name;
            end
        end
        figure('Name',strName);
        plotFloorPlanLayout(PlotData=updatedFloorplan,Type="room");
        xlabel('West \leftarrow   Length (m)   East \rightarrow');ylabel('South \leftarrow   Length (m)   North \rightarrow');
        title(strcat('Apartment: ',strName));
   end
end
