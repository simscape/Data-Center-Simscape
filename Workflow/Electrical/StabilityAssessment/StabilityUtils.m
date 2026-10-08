classdef (Sealed) StabilityUtils
%STABILITYUTILS Static utility methods for PFC stability math and simulation helpers.
% Copyright 2025-2026 The MathWorks, Inc.

    methods (Static)

        function Z_cl = computeImpedance(f, C, Kp, Ki, P, V)
        %COMPUTEIMPEDANCE Closed-loop output impedance of PI-controlled DC bus.
        %   Z_cl(s) = s / (C*s^2 + (Kp/V - P/V^2)*s + Ki/V)

            s = 1j*2*pi*f;
            b = Kp/V - P/V^2;
            Z_cl = s ./ (C*s.^2 + b*s + Ki/V);
        end

        function amp = computeAmplification(SCR_vals, f_osc, V_rms, P_base, XR, Y_at_fosc, N_dc)
        %COMPUTEAMPLIFICATION Grid amplification factor A = 1/|1 - T| at f_osc.

            if nargin < 7, N_dc = 1; end

            f_line = 60;
            amp = zeros(size(SCR_vals));

            for k = 1:numel(SCR_vals)
                Z_base = V_rms^2 / (SCR_vals(k) * P_base);
                X_grid = Z_base * XR / sqrt(1 + XR^2);
                R_grid = X_grid / XR;
                L_grid = X_grid / (2*pi*f_line);
                Z_grid = R_grid + 1j*2*pi*f_osc*L_grid;
                T = Z_grid * (N_dc * Y_at_fosc);
                amp(k) = 1 / abs(1 - T);
            end
        end

        function T_all = computeLoopGain(f, SCR_vals, V_rms, P_base, XR, Y_pfc)
        %COMPUTELOOPGAIN Middlebrook loop gain T = Z_grid * Y_pfc for SCR sweep.

            f_line = 60;
            T_all = cell(1, numel(SCR_vals));

            for k = 1:numel(SCR_vals)
                Z_base = V_rms^2 / (SCR_vals(k) * P_base);
                X_grid = Z_base * XR / sqrt(1 + XR^2);
                R_grid = X_grid / XR;
                L_grid = X_grid / (2*pi*f_line);
                Z_grid = R_grid + 1j*2*pi*f.*L_grid;
                T_all{k} = Z_grid .* Y_pfc;
            end
        end

        function [T_grid, G_DVC, G_sync, K_scalar] = computeGridLoopGain(f, params)
        %COMPUTEGRIDLOOPGAIN Fan et al. grid-side feedback loop gain.

            s = 1j*2*pi*f;

            Kp = params.Kp;
            Ki = params.Ki;
            tau_DC = params.tau_DC;
            tau_i = params.tau_i;
            omega_sync = params.omega_sync;
            Xg = params.Xg;
            id_op = params.id_op;
            V_nom = params.V_nom;

            num_DVC = Kp*s + Ki;
            den_DVC = 2*tau_DC*tau_i*s.^3 + 2*tau_DC*s.^2 + Kp*s + Ki;
            G_DVC = num_DVC ./ den_DVC;

            G_sync = omega_sync ./ (s + omega_sync);

            K_scalar = (Xg * id_op / V_nom)^2;

            T_grid = -G_DVC .* G_sync .* K_scalar;
        end

        function [f, P] = computeFFT(signal, dt)
        %COMPUTEFFT Single-sided FFT amplitude spectrum with zero-padding.

            N = length(signal);
            df_target = 0.05;
            N_pad = max(N, round(1 / (df_target * dt)));
            N_half = floor(N_pad/2);
            Y = fft(signal - mean(signal), N_pad);
            P = 2*abs(Y(1:N_half)) / N;
            f = (0:N_half-1).' / (N_pad * dt);
            P = P(:);
            f = f(:);
        end

        function [R, L] = gridImpedance(cfg, SCR)
        %GRIDIMPEDANCE Compute cable R (Ohm) and L (mH) for a given SCR.

            V_nom = cfg.OperatingPoint.V_nom;
            P_base = cfg.P_base_grid;
            XR = cfg.OperatingPoint.XR;
            f_line = cfg.OperatingPoint.f_line;

            Z_base = V_nom^2 / (SCR * P_base);
            X = Z_base * XR / sqrt(1 + XR^2);
            R = X / XR;
            L = X / (2*pi*f_line) * 1000;
        end

        function simOut = runSingleSim(s, Kp, Ki, StopTime)
        %RUNSINGLESIM Run one Simscape simulation at specified Kp, Ki, and StopTime.
            cfg = s.Cfg;
            C = cfg.Controller.C;
            gains = repmat(struct('Kp', Kp, 'Ki', Ki), cfg.n_pfc, 1);
            s.configureBlocks(PFCGains=gains, CDc=C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, StopTime=StopTime);
            for k = 1:cfg.n_pfc
                set_param(cfg.PFCBlocks(k), cfg.BlockParams.G_damp, '0.01');
            end
            simOut = sim(cfg.ModelName);
        end

        function [sigma_offset, b_ups, Kp_ups_equiv, T_damping] = upsDamping(sigma_sim, sigma_ode_pred, Kp_vals, cfg)
        %UPSDAMPING Extract UPS damping offset from ODE vs Simscape growth rates.
            C = cfg.Controller.C;
            V0 = cfg.OperatingPoint.V_dc;
            sigma_offset = mean(sigma_sim - sigma_ode_pred);
            b_ups = -sigma_offset * 2 * C;
            Kp_ups_equiv = b_ups * V0;
            measured_slope = diff(sigma_sim) / diff(Kp_vals);
            ode_slope = -1/(2*C*V0);
            T_damping = table(sigma_offset, b_ups, Kp_ups_equiv, Kp_ups_equiv/cfg.Kp_crit*100, ...
                measured_slope, ode_slope, measured_slope/ode_slope*100, ...
                VariableNames=["sigma_offset","b_ups","Kp_equiv","pct_Kp_crit", ...
                "dSigma_dKp_sim","dSigma_dKp_ode","slope_match_pct"]);
        end

        function stress = combinedStress(s)
        %COMBINEDSTRESS Run 2x2 grid/AFE stress matrix and compute interaction ratio.
            cfg = s.Cfg;
            sp = cfg.SimlogPaths;
            V_nom = cfg.OperatingPoint.V_nom;
            SCR_test = 5;
            P_base = cfg.P_base_grid;
            Z_grid = V_nom^2 / (SCR_test * P_base);
            XR = cfg.OperatingPoint.XR;
            X_g = Z_grid * XR / sqrt(1 + XR^2);
            R_g = X_g / XR;
            L_g = X_g / (2*pi*cfg.OperatingPoint.f_line);

            afeCtrl_su = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
            nomAFEKpExpr_su = get_param(afeCtrl_su, 'KpVoltage');
            nomAFEKiExpr_su = get_param(afeCtrl_su, 'KiVoltage');

            gains = repmat(struct('Kp',cfg.Controller.Kp,'Ki',cfg.Controller.Ki), cfg.n_pfc, 1);
            gains(1) = struct('Kp',30,'Ki',8000);

            AFE_nom = [cfg.AFEController.Kp, cfg.AFEController.Ki];
            AFE_deg = [0.2, 10];
            cases = {
                "Strong + Nominal AFE",   1e-3, 1e-3,      AFE_nom;
                "Weak + Nominal AFE",     R_g,  L_g*1000,  AFE_nom;
                "Strong + Degraded AFE",  1e-3, 1e-3,      AFE_deg;
                "Weak + Degraded AFE",    R_g,  L_g*1000,  AFE_deg};

            ups_ripple = zeros(4,1);
            pfc_ripple = zeros(4,1);

            for ii = 1:4
                s.configureBlocks(PFCGains=gains, ...
                    CableR=cases{ii,2}, CableL=cases{ii,3}, ...
                    AFEKp=cases{ii,4}(1), AFEKi=cases{ii,4}(2), StopTime=10);
                out = sim(cfg.ModelName);
                [t_out, v_ups] = StabilityStudy.extractSimlog(out.simlog, sp.ups_vdc, 'V');
                [~, v_pfc] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{1}, 'V');
                idx = t_out > 1.0;
                ups_ripple(ii) = max(v_ups(idx)) - min(v_ups(idx));
                pfc_ripple(ii) = max(v_pfc(idx)) - min(v_pfc(idx));
            end

            s.configureBlocks(...
                PFCGains=repmat(struct('Kp',cfg.Controller.Kp,'Ki',cfg.Controller.Ki), cfg.n_pfc, 1), ...
                CableR=1e-3, CableL=1e-3);
            set_param(afeCtrl_su, 'KpVoltage', nomAFEKpExpr_su, 'KiVoltage', nomAFEKiExpr_su);

            delta_grid = ups_ripple(2) - ups_ripple(1);
            delta_afe  = ups_ripple(3) - ups_ripple(1);
            delta_both = ups_ripple(4) - ups_ripple(1);
            interaction = delta_both / (delta_grid + delta_afe);

            stress.r5b = table(["Strong+NomAFE";"Weak+NomAFE";"Strong+DegAFE";"Weak+DegAFE"], ...
                ups_ripple, pfc_ripple, ...
                VariableNames=["Case","UPS_Ripple_Vpp","PFC_Ripple_Vpp"]);

            ups_baseline = ups_ripple(1);
            stress.T_interaction = table( ...
                ["Weak grid only (SCR=5)"; ...
                 "Degraded AFE only (Kp=0.2)"; ...
                 "Both combined"; ...
                 "Sum of individual deltas"], ...
                [ups_ripple(2); ups_ripple(3); ups_ripple(4); NaN], ...
                [delta_grid; delta_afe; delta_both; delta_grid + delta_afe], ...
                [delta_grid/ups_baseline*100; ...
                 delta_afe/ups_baseline*100; ...
                 delta_both/ups_baseline*100; ...
                 (delta_grid+delta_afe)/ups_baseline*100], ...
                VariableNames=["Condition","UPS_Ripple_Vpp","Delta_from_Baseline_V","Pct_Increase"]);

            if interaction < 0.9
                classif = "Subadditive";
            elseif interaction < 1.1
                classif = "Additive";
            else
                classif = "Superlinear";
            end
            if interaction <= 1.1
                implication = "Independent derating OK";
            else
                implication = "Combined margin required";
            end
            stress.T_verdict = table(interaction, classif, implication, ...
                VariableNames=["Interaction_Ratio","Classification","Design_Implication"]);

            stress.interaction = interaction;
            stress.ups_ripple = ups_ripple;
            stress.pfc_ripple = pfc_ripple;
        end

        function res = runITTrayFreqValidation(Kp_vals, Ki, C, V0)
        %RUNITTRAYFREQVALIDATION Validate ODE natural frequency against ITTray Simscape.
        %   Sweeps Kp on the ITTray model with G_damp ≈ 0 and frozen workload,
        %   measures oscillation frequency from Vdc zero-crossings, and compares
        %   against the analytical f_n = sqrt(Ki/(C*V0))/(2*pi).

            mdl = 'ITTray';
            if ~bdIsLoaded(mdl), load_system(mdl); end

            pfc_blk = sprintf('%s/PSU PFC Stage\n(Average Model)', mdl);
            cp_blk = sprintf('%s/Compute Profile\nSource (LLM Workload\nGenerator)', mdl);

            set_param(cp_blk, 'idleUtil','0.5','fwdUtil','0.5', ...
                'bwdUtil','0.5','commSyncUtil','0.5');
            set_param(pfc_blk, 'G_damp', '0.001');
            set_param(mdl, 'StopTime', '12');

            n = numel(Kp_vals);
            f_meas = zeros(1, n);
            Vpp = zeros(1, n);

            for jj = 1:n
                set_param(pfc_blk, 'Kp_pfc', num2str(Kp_vals(jj)), ...
                    'Ki_pfc', num2str(Ki), 'C_dc', num2str(C));

                simOut = sim(mdl);
                t_k = double(simOut.simlog.PSU_PFC_Stage_Average_Model.v_dc.series.time);
                v_k = double(simOut.simlog.PSU_PFC_Stage_Average_Model.v_dc.series.values);

                idx = t_k > 3 & t_k < 9;
                dv = v_k(idx) - mean(v_k(idx));
                t_w = t_k(idx);
                Vpp(jj) = max(dv) - min(dv);

                zc = find(dv(1:end-1) <= 0 & dv(2:end) > 0);
                if numel(zc) >= 2
                    f_meas(jj) = 1 / mean(diff(t_w(zc)));
                else
                    f_meas(jj) = NaN;
                end
            end

            set_param(pfc_blk, 'Kp_pfc', '8000', 'Ki_pfc', '40000', ...
                'C_dc', '0.5', 'G_damp', '5.0');
            set_param(cp_blk, 'idleUtil','0.60','fwdUtil','0.92', ...
                'bwdUtil','0.98','commSyncUtil','0.65');

            f_pred = sqrt(Ki / (C * V0)) / (2*pi);
            err_pct = abs(f_meas - f_pred) / f_pred * 100;

            res.f_meas = f_meas;
            res.f_pred = f_pred;
            res.Vpp = Vpp;
            res.Kp_vals = Kp_vals;
            res.T_freq = table(Kp_vals', f_meas', repmat(f_pred,n,1), err_pct', Vpp', ...
                VariableNames=["Kp","f_simscape_Hz","f_ODE_Hz","error_pct","Vpp_V"]);
        end

    end
end
