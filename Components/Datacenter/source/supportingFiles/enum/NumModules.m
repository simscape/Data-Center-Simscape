classdef NumModules < int32
% Enumeration class for selecting the number of CHB modules per phase leg.

% Copyright 2025 The MathWorks, Inc.

enumeration
    one(1)
    two(2)
    three(3)
    four(4)
    five(5)
    six(6)
    seven(7)
    eight(8)
    nine(9)
    ten(10)
end

methods (Static, Hidden)
    function map = displayText()
        map = containers.Map;
        map('one') = '1';
        map('two') = '2';
        map('three') = '3';
        map('four') = '4';
        map('five') = '5';
        map('six') = '6';
        map('seven') = '7';
        map('eight') = '8';
        map('nine') = '9';
        map('ten') = '10';
    end
end
end
