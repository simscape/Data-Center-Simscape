function runTestOnFileList(NameValueArgs)
    arguments
        NameValueArgs.Path (:,1) string {mustBeNonempty}
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
    end
    
    [~,fileNameVec,fileExtVec] = fileparts(NameValueArgs.Path);
    failures = 0;
    totalCases = size(NameValueArgs.Path,1);

    for k = 1:totalCases
        strDispNum = strcat("(",num2str(k),"/",num2str(totalCases),")");
        modelName = fileNameVec(k,1);
        modelExtn = fileExtVec(k,1);
        try
            if or(or(modelExtn==".slx",modelExtn==".mdl"),or(modelExtn==".mlx",modelExtn==".m"))
                tK = tic;
                if or(modelExtn==".slx",modelExtn==".mdl")
                    load_system(modelName);
                    sim(modelName); %#ok<NASGU>
                    bdclose(modelName);
                else
                    run(modelName);
                end
                dt = round(toc(tK),1);
                disp(strcat(strDispNum,"✅ File ",modelName,modelExtn," passed the test in ~ ",num2str(dt)," seconds."));
            else
                failures = failures + 1;
                disp(strcat(strDispNum,"❌ File ",modelName,modelExtn," could not be run."));
            end
        catch ME
            failures = failures + 1;
            disp(strcat(strDispNum,"❌ File ",modelName,modelExtn," failed the test.")); %#ok<AGROW>
        end
    end
    disp(strcat("All files tested. ",num2str(round(1-failures/totalCases,2)*100),"% files passed the test."))
end