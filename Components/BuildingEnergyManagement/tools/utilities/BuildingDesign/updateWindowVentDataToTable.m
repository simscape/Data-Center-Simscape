function tblWinVentData = updateWindowVentDataToTable(NameValueArgs)
% Update tabluar data for window and vent definition.
% 
% For more details, see <a href="matlab:web('FunctionReferenceList.html')">Function Reference List</a>
% 
% Copyright 2024 - 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.OpeningData (:,3) {mustBeNonempty}
        NameValueArgs.DataTable (:,6) table {mustBeNonempty}
    end

    tblWinVentData = NameValueArgs.DataTable;
    for i = 1:size(NameValueArgs.OpeningData,1)
        id = find(and(tblWinVentData.("From Point")==NameValueArgs.OpeningData(i,1),...
                      tblWinVentData.("To Point")==NameValueArgs.OpeningData(i,2)));
        for j = 1:size(id,1) 
            % Update all rooms with same external wall
            tblWinVentData.("Window (0-1)")(id(j,1),1) = NameValueArgs.OpeningData(i,3);
        end
    end
    disp("*** Completed update of table data."); disp(" "); disp(tblWinVentData);
end