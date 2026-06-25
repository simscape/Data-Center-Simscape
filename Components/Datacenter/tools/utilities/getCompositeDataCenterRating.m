function rating = getCompositeDataCenterRating(NameValueArgs)
    arguments (Input)
        NameValueArgs.BlockPath string {mustBeNonempty}
        NameValueArgs.Display logical {mustBeNumericOrLogical} = false
    end

    arguments (Output)
        rating (1,1) simscape.Value
    end
    
    x = libinfo(NameValueArgs.BlockPath);
    libSearch = "datacenter_lib/Datacenter Server";
    rating = simscape.Value(0,"kW");
    for i = 1:size(x,1)
        if contains(x(i,1).ReferenceBlock,libSearch)
            rating = rating + getDataCenterRating(BlockPath=x(i,1).Block);
        end
    end

    if NameValueArgs.Display
        disp(strcat("*** Data center rating = ",num2str(round(value(rating,"kW"),1))," kW."));
    end
end