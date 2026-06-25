%% Room Volume
% 
% This block is used to specify a block-shaped air volume inside a room.
% You can add heat to the air volume through the input port _S_. The node 
% _M_ is the Thermal node to the thermal mass of air in the block. The
% output port _T_ provides temperature of the air mass. You can use one
% |Room Volume| block to define a room or have multiple |Room Volume|
% blocks connected to each other to represent the descritized room air
% volume.

% Copyright 2025 The MathWorks, Inc.

%% Room Volume
% * *Room length*, |length|, specified as a scalar value. It specifies the
% air mass block length.
% * *Room width*, |width|, specified as a scalar value. It specifies the
% air mass block width.
% * *Room height*, |height|, specified as a scalar value. It specifies the
% air mass block height.