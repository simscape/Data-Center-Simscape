% Copyright 2025 - 2026 The MathWorks, Inc.

relstr = matlabRelease().Release;
disp("This MATLAB Release: " + relstr);
prjRoot = currentProject().RootFolder;
disp(strcat("Project root: ",prjRoot));

testHarness = getFileListAtPath(Path=fullfile(prjRoot,"**","test"),...
                                Type="SLX-file",DisplayList=true);

workFlows = getFileListAtPath(Path=fullfile(prjRoot,"Workflow"),...
                              Type="M-file",DisplayList=true);
testFileList = [testHarness;workFlows];
clear testHarness workFlows

% testFileList = updatePathList(Path=testFileList,...
%                               IgnoreDirectory=["documentation";"SupportingFiles"],...
%                               IgnoreCase=true);

runTestOnFileList(Path=testFileList);