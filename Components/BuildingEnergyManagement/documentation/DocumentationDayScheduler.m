%% Day Scheduler
% 
% This block is used to specify daily pattern of heat source in every room
% of the building. The output port _S_ connects to the building custom
% library port _S_.

% Copyright 2025 The MathWorks, Inc.

%% Parameters
% * *Number of rooms in the building*, |numRooms|, specified as a scalar 
% value. It specifies the total number of rooms in the building for all the
% apartments.
% * *Room index*, |roomIndex|, specified as a vector. It specifies the
% index of the room to reference in the vector based on it's apartment and
% room number properties.
% * *Heat source matrix for all rooms*, |heatSource|, specified as a matrix 
% of column length 24, with each column denoting an hour of the day. The
% number of roms in the matrix must be equal to the *Number of rooms in the
% building*.
%
%% Block Parameteriztion Support
% The parameters for this block must be set using the utilities provided in
% the project, namely |initialize24HrRoomData| and
% |set24HrRoomDataSystemModel|.