function models = updatePathList(NameValueArgs)
    arguments
        NameValueArgs.Path (:,1) string {mustBeNonempty}
        NameValueArgs.IgnoreDirectory (:,1) string {mustBeNonempty}
        NameValueArgs.IgnoreCase logical {mustBeNumericOrLogical} = false
    end
    
    [dirVec,~,~] = fileparts(NameValueArgs.Path);
    
    ignoreList = false(size(NameValueArgs.Path,1),1);
    for i = 1:size(NameValueArgs.IgnoreDirectory,1)
        ignore = contains(dirVec,NameValueArgs.IgnoreDirectory(i,1),"IgnoreCase",NameValueArgs.IgnoreCase);
        ignoreList = or(ignoreList,ignore);
    end

    models = NameValueArgs.Path(~ignoreList,:);
end