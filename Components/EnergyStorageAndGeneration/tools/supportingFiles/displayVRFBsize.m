%[text] # Calculate VRFB Rating
%[text] Run this live script to calculate the VRFB rating. The block for VRFB must be selected before you run this live script. You must also specify a nominal current for the VRFB.
rating = getVRFBrating(BlockPath=gcb,... %[output:group:340133a6] %[output:9943db20]
                       NominalCurrent=simscape.Value(30,"A"),... %[output:9943db20]
                       Diagnostics=true); %[output:group:340133a6] %[output:9943db20]
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:9943db20]
%   data: {"dataType":"text","outputData":{"text":"*** VRFB rating = 7.8kW, 2170.8Ahr.\n*** Operation duration ~ 72.4hr.\n","truncated":false}}
%---
