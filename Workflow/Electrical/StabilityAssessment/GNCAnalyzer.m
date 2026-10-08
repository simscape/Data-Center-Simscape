classdef (Sealed) GNCAnalyzer < handle
%GNCANALYZER MIMO admittance-based stability analysis (Generalized Nyquist Criterion).
% Copyright 2025-2026 The MathWorks, Inc.

    properties (SetAccess = private)
        Cfg         struct
        Pal         struct
        Admittance  struct
        Analysis    struct
        TimeDomain  struct
    end

    methods

        function obj = GNCAnalyzer(cfg)
        %GNCANALYZER Create MIMO admittance analyzer for given configuration.
            obj.Cfg = cfg;
            obj.Pal = StabilityStudy.setupGroot();
        end

        %% ================= ADMITTANCE SCAN =================
        function runAdmittanceScan(obj, options)
        %RUNADMITTANCESCAN PRBS injection to estimate 2x2 DQ admittance.
            arguments
                obj
                options.U_levels (1,:) double = [0.5, 0.7, 0.9]
                options.Axes     (1,:) string = ["D-axis", "Q-axis"]
            end

            mdl = obj.Cfg.ModelName;
            scan = obj.Cfg.GNC;
            U_levels = options.U_levels;
            axes_scan = options.Axes;
            nU = numel(U_levels);
            nAxes = numel(axes_scan);

            simIn(1:nU*nAxes) = Simulink.SimulationInput(mdl);
            idx = 0;
            for u = 1:nU
                for a = 1:nAxes
                    idx = idx + 1;
                    simIn(idx) = GNCAnalyzer.configureScanInput(mdl, scan, axes_scan(a), U_levels(u));
                end
            end

            scanData = parsim(simIn, 'ShowProgress', 'on', ...
                'TransferBaseWorkspaceVariables', 'on', 'UseFastRestart', 'off');

            for ii = 1:numel(scanData)
                if scanData(ii).ErrorMessage ~= ""
                    warning('Scan %d failed: %s', ii, scanData(ii).ErrorMessage);
                end
            end

            Y_all = cell(1, nU);
            for u = 1:nU
                idxRange = (u-1)*nAxes + (1:nAxes);
                dataScan = scanData(idxRange);
                scanner = configureAdmittanceScanner(dataScan, axes_scan, scan.f, scan);
                Y_all{u} = estimateAdmittances(scanner);
            end

            obj.Admittance = struct('Y_all', {Y_all}, 'scanData', scanData, 'U_levels', U_levels);
        end

        %% ================= GNC ANALYSIS =================
        function runAnalysis(obj, Y_all, Z_grid_all, options)
        %RUNANALYSIS Generalized Nyquist Criterion stability assessment.
            arguments
                obj
                Y_all            (1,:) cell
                Z_grid_all       (1,:) cell
                options.U_levels (1,:) double = [0.5, 0.7, 0.9]
                options.SCR_vals (1,:) double = [10, 3, 2]
                options.NumFreq  (1,1) double = 2000
            end

            gnc = obj.Cfg.GNC;
            nU = numel(options.U_levels);
            nSCR = numel(options.SCR_vals);

            wpos = 2*pi*logspace(log10(gnc.f(1)), log10(gnc.f(end)), options.NumFreq);
            w_nyquist = [-fliplr(wpos), wpos];

            encircTable = zeros(nU, nSCR);
            distTable = zeros(nU, nSCR);
            marginTable = zeros(nU, nSCR);
            eigData = cell(nU, nSCR);

            for u = 1:nU
                Y = Y_all{u};
                for k = 1:nSCR
                    L_loop = Z_grid_all{k} * Y;
                    Ljw = freqresp(L_loop, w_nyquist);
                    nEig = size(Ljw, 1);
                    eigL = zeros(nEig, length(w_nyquist));
                    eigL(:,1) = eig(Ljw(:,:,1));
                    for ii = 2:length(w_nyquist)
                        eigL(:,ii) = GNCAnalyzer.trackEigenvalues(eigL(:,ii-1), eig(Ljw(:,:,ii)));
                    end

                    total_N = 0;
                    for ei = 1:nEig
                        z = eigL(ei,:) + 1;
                        dtheta = diff(unwrap(angle(z)));
                        total_N = total_N + round(-sum(dtheta) / (2*pi));
                    end
                    encircTable(u, k) = total_N;
                    distTable(u, k) = min(abs(eigL(:) + 1));

                    nPos = length(wpos);
                    eigL_pos = eigL(:, nPos+1:end);
                    mag_pos = abs(eigL_pos);
                    min_PM = Inf;
                    for ei = 1:nEig
                        crossings = find(diff(sign(mag_pos(ei,:) - 1)) ~= 0);
                        for ci = 1:numel(crossings)
                            idx_c = crossings(ci);
                            PM = 180 - abs(angle(eigL_pos(ei, idx_c))) * 180/pi;
                            if PM < min_PM, min_PM = PM; end
                        end
                    end
                    if isinf(min_PM), min_PM = 180; end
                    marginTable(u, k) = min_PM;
                    eigData{u, k} = eigL;
                end
            end

            nCases = nU * nSCR;
            col_U = zeros(nCases, 1);
            col_SCR = zeros(nCases, 1);
            col_Encirc = zeros(nCases, 1);
            col_Dist = zeros(nCases, 1);
            col_PM = zeros(nCases, 1);
            col_Status = strings(nCases, 1);
            col_Robust = strings(nCases, 1);

            idx = 0;
            for u = 1:nU
                for k = 1:nSCR
                    idx = idx + 1;
                    col_U(idx) = options.U_levels(u) * 100;
                    col_SCR(idx) = options.SCR_vals(k);
                    col_Encirc(idx) = encircTable(u, k);
                    col_Dist(idx) = distTable(u, k);
                    col_PM(idx) = marginTable(u, k);
                    if encircTable(u, k) <= 0
                        if marginTable(u, k) > 45
                            col_Status(idx) = "STABLE";
                        elseif marginTable(u, k) > 15
                            col_Status(idx) = "MARGINAL";
                        else
                            col_Status(idx) = "CRITICAL";
                        end
                    else
                        col_Status(idx) = sprintf("UNSTABLE(%d)", encircTable(u, k));
                    end
                    if encircTable(u, k) > 0
                        col_Robust(idx) = "Unstable";
                    elseif distTable(u, k) >= 0.9
                        col_Robust(idx) = "Robust";
                    elseif distTable(u, k) >= 0.5
                        col_Robust(idx) = "Marginal";
                    else
                        col_Robust(idx) = "Poor";
                    end
                end
            end

            obj.Analysis.encircTable = encircTable;
            obj.Analysis.distTable = distTable;
            obj.Analysis.marginTable = marginTable;
            obj.Analysis.eigData = eigData;
            obj.Analysis.w_nyquist = w_nyquist;
            obj.Analysis.T_stability = table(col_U, col_SCR, col_Encirc, col_Dist, col_PM, col_Status, col_Robust, ...
                'VariableNames', {'Load (%)', 'Grid SCR', 'Encirclements', 'Min Distance to -1', 'Phase Margin (deg)', 'Status', 'Robustness (min dist)'});
        end

        %% ================= TIME-DOMAIN VALIDATION =================
        function runTimeDomain(obj, options)
        %RUNTIMEDOMAIN Time-domain validation of GNC predictions.
            arguments
                obj
                options.SCR_vals (1,:) double = [10, 3, 2]
                options.U        (1,1) double = 0.9
                options.StopTime (1,1) double = 4
            end

            mdl = obj.Cfg.ModelName;
            gnc = obj.Cfg.GNC;
            nSCR = numel(options.SCR_vals);

            R_cable_fixed = 0.001;
            L_cable_fixed = 1e-6;

            simIn(1:nSCR) = Simulink.SimulationInput(mdl);
            for k = 1:nSCR
                Z_base = gnc.V_nom^2 / (options.SCR_vals(k) * gnc.P_base);
                X_grid = Z_base * gnc.XR / sqrt(1 + gnc.XR^2);
                R_grid = X_grid / gnc.XR;
                L_grid = X_grid / (2*pi*gnc.f_line);

                R_rlc = max(R_grid - R_cable_fixed, 1e-4);
                L_rlc = max(L_grid - L_cable_fixed, 1e-7);

                simIn(k) = Simulink.SimulationInput(mdl);
                simIn(k) = simIn(k).setVariable('scan.Vd', 0);
                simIn(k) = simIn(k).setVariable('scan.Vq', 0);
                simIn(k) = simIn(k).setVariable('scan.Vdc', 0);
                simIn(k) = simIn(k).setVariable('scan.f', gnc.f);
                simIn(k) = simIn(k).setVariable('scan.samplingfrequency', gnc.samplingfrequency);
                simIn(k) = simIn(k).setVariable('scan.start', gnc.start);
                simIn(k) = simIn(k).setVariable('scan.end', gnc.end);
                simIn(k) = simIn(k).setVariable('G1', 0);
                simIn(k) = simIn(k).setVariable('G2', 1);
                simIn(k) = simIn(k).setBlockParameter(mdl + "/Utility A/PS Constant1", 'constant', num2str(options.U));
                simIn(k) = simIn(k).setBlockParameter( ...
                    mdl + "/Measurement A/Measurements/RLC (Three-Phase)", 'R', num2str(R_rlc));
                simIn(k) = simIn(k).setBlockParameter( ...
                    mdl + "/Measurement A/Measurements/RLC (Three-Phase)", 'L', num2str(L_rlc));
                simIn(k) = simIn(k).setModelParameter('StopTime', num2str(options.StopTime));
                simIn(k) = simIn(k).setModelParameter('LoadInitialState', 'off');
            end

            save_system(mdl);
            outVal = parsim(simIn, 'ShowProgress', 'on', ...
                'TransferBaseWorkspaceVariables', 'on', 'UseFastRestart', 'off');

            obj.TimeDomain.out = outVal;
            obj.TimeDomain.SCR_vals = options.SCR_vals;
            obj.TimeDomain.U = options.U;
        end

    end

    methods (Static)

        function Z_grid_all = gncGridZ(cfg, options)
        %GNCGRIDZ Build 2x2 DQ-frame grid impedance for multiple SCR values.
            arguments
                cfg              (1,1) struct
                options.SCR_vals (1,:) double = [10, 3, 2]
            end

            gnc = cfg.GNC;
            s = tf('s');
            omega0 = 2*pi*gnc.f_line;
            nSCR = numel(options.SCR_vals);
            Z_grid_all = cell(1, nSCR);

            for k = 1:nSCR
                Z_base = gnc.V_nom^2 / (options.SCR_vals(k) * gnc.P_base);
                X = Z_base * gnc.XR / sqrt(1 + gnc.XR^2);
                R = X / gnc.XR;
                L = X / (2*pi*gnc.f_line);

                R_eff = R - gnc.R_internal;
                L_eff = L - gnc.L_internal;

                zg = R_eff + s*L_eff;
                Z_grid_all{k} = [zg, 1j*omega0*L_eff*tf(1); ...
                                 -1j*omega0*L_eff*tf(1), zg];
            end
        end

        function results = computeLoopGainMIMO(Y_meas, SCR_vals, cfg, options)
        %COMPUTELOOPGAINMIMO MIMO GNC using measured 2x2 DQ admittance.
            arguments
                Y_meas
                SCR_vals        (1,:) double
                cfg             (1,1) struct
                options.NumFreq (1,1) double = 2000
            end

            gnc = cfg.GNC;
            omega0 = 2*pi*gnc.f_line;
            nSCR = numel(SCR_vals);

            wpos = 2*pi*logspace(log10(gnc.f(1)), log10(gnc.f(end)), options.NumFreq);
            w_nyquist = [-fliplr(wpos), wpos];
            nW = numel(w_nyquist);
            nHalf = numel(wpos);

            Yjw = freqresp(Y_meas, w_nyquist);

            encircTable = zeros(1, nSCR);
            distTable = zeros(1, nSCR);
            marginTable = zeros(1, nSCR);
            eigData = cell(1, nSCR);

            for k = 1:nSCR
                Z_base = gnc.V_nom^2 / (SCR_vals(k) * gnc.P_base);
                X = Z_base * gnc.XR / sqrt(1 + gnc.XR^2);
                R = X / gnc.XR;
                L = X / (2*pi*gnc.f_line);
                R_eff = R - gnc.R_internal;
                L_eff = L - gnc.L_internal;

                eigL = zeros(2, nW);
                for ii = 1:nW
                    s_val = 1j*w_nyquist(ii);
                    Z_dq = [R_eff + s_val*L_eff,        1j*omega0*L_eff; ...
                            -1j*omega0*L_eff,            R_eff + s_val*L_eff];
                    Y_ii = Yjw(:,:,ii);
                    L_mat = Z_dq * Y_ii;
                    eigL(:,ii) = eig(L_mat);
                end

                for ii = 2:nW
                    eigL(:,ii) = GNCAnalyzer.trackEigenvalues(eigL(:,ii-1), eigL(:,ii));
                end

                total_N = 0;
                for ei = 1:2
                    z = eigL(ei,:) + 1;
                    dtheta = diff(unwrap(angle(z)));
                    total_N = total_N + round(-sum(dtheta) / (2*pi));
                end
                encircTable(k) = total_N;
                distTable(k) = min(abs(eigL(:) + 1));

                eigL_pos = eigL(:, nHalf+1:end);
                mag_pos = abs(eigL_pos);
                min_PM = Inf;
                for ei = 1:2
                    crossings = find(diff(sign(mag_pos(ei,:) - 1)) ~= 0);
                    for ci = 1:numel(crossings)
                        idx_c = crossings(ci);
                        PM = abs(180 - abs(angle(eigL_pos(ei, idx_c))) * 180/pi);
                        if PM < min_PM, min_PM = PM; end
                    end
                end
                if isinf(min_PM), min_PM = 180; end
                marginTable(k) = min_PM;
                eigData{k} = eigL;
            end

            status_str = strings(nSCR, 1);
            robust_str = strings(nSCR, 1);
            for k = 1:nSCR
                if encircTable(k) <= 0
                    if marginTable(k) > 45
                        status_str(k) = "STABLE";
                    elseif marginTable(k) > 15
                        status_str(k) = "MARGINAL";
                    else
                        status_str(k) = "CRITICAL";
                    end
                else
                    status_str(k) = sprintf("UNSTABLE(%d)", encircTable(k));
                end
                if encircTable(k) > 0
                    robust_str(k) = "Unstable";
                elseif distTable(k) >= 0.9
                    robust_str(k) = "Robust";
                elseif distTable(k) >= 0.5
                    robust_str(k) = "Marginal";
                else
                    robust_str(k) = "Poor";
                end
            end

            f_cdm = logspace(log10(gnc.f(1)), log10(gnc.f(end)), 200);
            w_cdm = 2*pi*f_cdm;
            Y_cdm = freqresp(Y_meas, w_cdm);
            Ydd_cdm = abs(squeeze(Y_cdm(1,1,:)));
            Ydq_cdm = abs(squeeze(Y_cdm(1,2,:)));
            CDM = max(Ydq_cdm ./ Ydd_cdm);

            results.encircTable = encircTable;
            results.distTable = distTable;
            results.marginTable = marginTable;
            results.eigData = eigData;
            results.w_nyquist = w_nyquist;
            results.CDM = CDM;
            results.T_stability = table(SCR_vals(:), encircTable(:), distTable(:), marginTable(:), ...
                categorical(status_str), categorical(robust_str), ...
                VariableNames=["Grid SCR", "Encirclements", "Min Distance to -1", "Phase Margin (deg)", "Status", "Robustness (min dist)"]);
        end

        function tracked = trackEigenvalues(prev, curr)
        %TRACKEIGENVALUES Match eigenvalues across frequency points by nearest distance.
            n = length(prev);
            tracked = zeros(n,1);
            used = false(n,1);
            for i = 1:n
                dists = abs(curr - prev(i));
                dists(used) = Inf;
                [~, bestIdx] = min(dists);
                tracked(i) = curr(bestIdx);
                used(bestIdx) = true;
            end
        end

        function plotEigNyquist(results, SCR_vals)
        %PLOTEIGNYQUIST Eigenvalue Nyquist loci tiled by grid SCR.
            pal = StabilityStudy.setupGroot();
            nSCR = numel(SCR_vals);
            colors = {pal.blue, pal.green};

            figure('Name', 'GNC Eigenvalue Nyquist');
            tl = tiledlayout(1, nSCR, 'TileSpacing', 'compact', 'Padding', 'compact');
            for k = 1:nSCR
                nexttile;
                eigL = results.eigData{k};
                nEig = size(eigL, 1);

                theta = linspace(0, 2*pi, 200);
                plot(cos(theta)-1, sin(theta), '--', 'Color', [0.6 0.6 0.6], ...
                    'LineWidth', 0.6, 'HandleVisibility', 'off');
                hold on;
                h = gobjects(nEig, 1);
                for ei = 1:nEig
                    h(ei) = plot(real(eigL(ei,:)), imag(eigL(ei,:)), ...
                        'Color', colors{ei}, 'LineWidth', 1.5);
                end
                plot(-1, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2, ...
                    'HandleVisibility', 'off');
                hold off;

                N = results.encircTable(k);
                d = results.distTable(k);
                if N > 0
                    status = sprintf('UNSTABLE(%d)', N);
                elseif results.marginTable(k) > 45
                    status = 'STABLE';
                elseif results.marginTable(k) > 15
                    status = 'MARGINAL';
                else
                    status = 'CRITICAL';
                end
                title(sprintf('SCR = %g\n%s, d = %.2f', SCR_vals(k), status, d));
                axis equal; grid on;
                xlabel('Real'); ylabel('Imaginary');
                legend(h, {'\lambda_1', '\lambda_2'}, 'Location', 'best');
            end
            title(tl, 'GNC Eigenvalue Nyquist Loci (90% Load)');
        end

        function plotEigBode(results, SCR_vals)
        %PLOTEIGBODE Eigenvalue Bode (magnitude + phase) overlaid by SCR.
            pal = StabilityStudy.setupGroot();
            nSCR = numel(SCR_vals);
            scr_colors = {pal.blue, pal.orange, pal.red};

            nHalf = numel(results.w_nyquist) / 2;
            f_pos = results.w_nyquist(nHalf+1:end) / (2*pi);

            figure('Name', 'GNC Eigenvalue Bode');
            tl = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

            hMag = gobjects(nSCR, 1);
            nexttile; hold on;
            for k = 1:nSCR
                eigL_pos = results.eigData{k}(:, nHalf+1:end);
                mag1 = 20*log10(abs(eigL_pos(1,:)));
                mag2 = 20*log10(abs(eigL_pos(2,:)));
                hMag(k) = semilogx(f_pos, mag1, 'Color', scr_colors{k}, 'LineWidth', 1.5);
                semilogx(f_pos, mag2, '--', 'Color', scr_colors{k}, 'LineWidth', 1.2, ...
                    'HandleVisibility', 'off');
            end
            yline(0, '--k', 'LineWidth', 0.6, 'HandleVisibility', 'off');
            hold off;
            ylabel('Magnitude (dB)'); grid on;
            set(gca, 'XScale', 'log');
            legend(hMag, arrayfun(@(s) sprintf('SCR = %g', s), SCR_vals, 'UniformOutput', false), ...
                'Location', 'best');

            hPh = gobjects(nSCR, 1);
            nexttile; hold on;
            for k = 1:nSCR
                eigL_pos = results.eigData{k}(:, nHalf+1:end);
                ph1 = angle(eigL_pos(1,:)) * 180/pi;
                ph2 = angle(eigL_pos(2,:)) * 180/pi;
                hPh(k) = semilogx(f_pos, ph1, 'Color', scr_colors{k}, 'LineWidth', 1.5);
                semilogx(f_pos, ph2, '--', 'Color', scr_colors{k}, 'LineWidth', 1.2, ...
                    'HandleVisibility', 'off');
            end
            yline(-180, '--k', 'LineWidth', 0.6, 'HandleVisibility', 'off');
            hold off;
            ylabel('Phase (deg)'); xlabel('Frequency (Hz)'); grid on;
            set(gca, 'XScale', 'log');
            legend(hPh, arrayfun(@(s) sprintf('SCR = %g', s), SCR_vals, 'UniformOutput', false), ...
                'Location', 'best');

            title(tl, 'GNC Eigenvalue Bode (90% Load)');
        end

        function plotUtilSweep(gnc_all, SCR_vals, U_pct)
        %PLOTUTILSWEEP Utilization sweep — eigenvalue loci at multiple load levels.
            pal = StabilityStudy.setupGroot();
            nSCR = numel(SCR_vals);
            nU = numel(gnc_all);
            load_colors = {pal.blue, pal.orange, pal.red};
            leg_labels = arrayfun(@(p) sprintf('%d%%', p), U_pct, 'UniformOutput', false);
            eig_labels = {'\lambda_1', '\lambda_2'};
            theta = linspace(0, 2*pi, 200);

            figure('Name', 'GNC Utilization Sweep');
            tl = tiledlayout(2, nSCR, 'TileSpacing', 'compact', 'Padding', 'compact');
            for ei = 1:2
                for k = 1:nSCR
                    nexttile;
                    plot(cos(theta)-1, sin(theta), '--', 'Color', [0.6 0.6 0.6], ...
                        'LineWidth', 0.6, 'HandleVisibility', 'off');
                    hold on;
                    h = gobjects(nU, 1);
                    for u = 1:nU
                        eigL = gnc_all{u}.eigData{k};
                        h(u) = plot(real(eigL(ei,:)), imag(eigL(ei,:)), ...
                            'Color', load_colors{u}, 'LineWidth', 1.5);
                    end
                    plot(-1, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2, ...
                        'HandleVisibility', 'off');
                    hold off;
                    title(sprintf('SCR = %g  (%s)', SCR_vals(k), eig_labels{ei}));
                    axis equal; grid on;
                    xlabel('Real'); ylabel('Imaginary');
                    legend(h, leg_labels, 'Location', 'best');
                end
            end
            title(tl, 'GNC Utilization Sweep — Eigenvalue Loci');
        end

    end

    methods (Static, Access = private)

        function simIn = configureScanInput(mdl, scan, axis, U)
        %CONFIGURESCANINPUT Configure SimulationInput for PRBS admittance injection.
            simIn = Simulink.SimulationInput(mdl);
            switch axis
                case "D-axis"
                    simIn = simIn.setVariable('scan.Vd', scan.Vd);
                    simIn = simIn.setVariable('scan.Vq', 0);
                    simIn = simIn.setVariable('scan.Vdc', 0);
                case "Q-axis"
                    simIn = simIn.setVariable('scan.Vd', 0);
                    simIn = simIn.setVariable('scan.Vq', scan.Vq);
                    simIn = simIn.setVariable('scan.Vdc', 0);
            end
            simIn = simIn.setVariable('scan.f', scan.f);
            simIn = simIn.setVariable('scan.samplingfrequency', scan.samplingfrequency);
            simIn = simIn.setVariable('scan.start', scan.start);
            simIn = simIn.setVariable('scan.end', scan.end);
            simIn = simIn.setVariable('G1', 0);
            simIn = simIn.setVariable('G2', 1);
            simIn = simIn.setBlockParameter(mdl + "/Utility A/PS Constant1", 'constant', num2str(U));
            simIn = simIn.setModelParameter('StopTime', num2str(scan.end + 0.5));
        end

    end

end
