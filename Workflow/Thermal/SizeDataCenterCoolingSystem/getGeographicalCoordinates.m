% Copyright 2026 The MathWorks, Inc.

function coordinates = getGeographicalCoordinates(data)
    val = cell2mat(data); 
    coordinates = str2double(val(1:end-1));
end