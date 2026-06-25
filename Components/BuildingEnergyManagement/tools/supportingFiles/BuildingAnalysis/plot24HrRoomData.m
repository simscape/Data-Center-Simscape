function plot24HrRoomData(NameValueArgs)
% Plot 24hr variation data.
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.TableData24Hr (:,28) table {mustBeNonempty}
        NameValueArgs.DataName string {mustBeNonempty}
    end
    
    tblData = table2array(NameValueArgs.TableData24Hr(:,5:28));
    numData = size(NameValueArgs.TableData24Hr,1);
    lblData = strings(1,numData);
    lblTick = strings(1,24);
    
    for i = 1:numData
        lblData(1,i) = strcat("Apt#",num2str(NameValueArgs.TableData24Hr.Apartment(i,1)),",Room#",num2str(NameValueArgs.TableData24Hr.Room(i,1))," (",NameValueArgs.TableData24Hr.RoomName(i,1),")");
    end
    for i = 1:24
        if i < 10
            lblTick(1,i) = strcat("0",num2str(i),":00");
        else
            lblTick(1,i) = strcat(num2str(i),":00");
        end
    end

    figure("Name",NameValueArgs.DataName);
    if numData < 24
        plot(tblData');
    else
        plot(tblData);
    end
    legend(lblData,"Location","bestoutside");
    ylabel(NameValueArgs.DataName);
    xticks(1:24); xticklabels(lblTick); 
end