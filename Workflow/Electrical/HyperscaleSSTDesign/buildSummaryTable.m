function T = buildSummaryTable(caseMetrics)
%BUILDSUMMARYTABLE Create a summary table from collected case metrics.
%
%   T = buildSummaryTable(caseMetrics)
%
%   caseMetrics is a struct array with fields:
%     .name       - scenario name (string)
%     .Vdc_mean   - mean DC bus voltage (V)
%     .Vdc_std    - standard deviation (V)
%     .Vdc_pp     - peak-to-peak voltage (V)
%     .Inference - BBU effectiveness string

% Copyright 2026 The MathWorks, Inc.

nCases = numel(caseMetrics);
Scenario = strings(nCases, 1);
Vdc_Mean = zeros(nCases, 1);
Vdc_Std = zeros(nCases, 1);
Vdc_PeakPeak = zeros(nCases, 1);
Inference = strings(nCases, 1);

for k = 1:nCases
    Scenario(k) = caseMetrics(k).name;
    Vdc_Mean(k) = caseMetrics(k).Vdc_mean;
    Vdc_Std(k) = caseMetrics(k).Vdc_std;
    Vdc_PeakPeak(k) = caseMetrics(k).Vdc_pp;
    Inference(k) = caseMetrics(k).bbuVerdict;
end

T = table(Scenario, Vdc_Mean, Vdc_Std, Vdc_PeakPeak, Inference, ...
    VariableNames=["Scenario", "Vdc Mean (V)", "Vdc Std (V)", ...
    "Vdc Peak-Peak (V)", "Inference"]);
end
