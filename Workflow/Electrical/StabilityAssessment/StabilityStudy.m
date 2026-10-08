classdef (Sealed) StabilityStudy < handle
%STABILITYSTUDY Unified stability analysis for datacenter power converters.
% Copyright 2025-2026 The MathWorks, Inc.

    properties (SetAccess = private)
        Cfg     struct
        Pal     struct
    end

    properties (SetAccess = private)
        Setup           struct = struct()
        Baseline        struct = struct()
        FirmwareBug     struct = struct()
        WeakGrid        struct = struct()
        UPSIsolation    struct = struct()
        AFEDegradation  struct = struct()
        StabilityMap    struct = struct()
        ImpedanceScan   struct = struct()
        UPSBypassDemo   struct = struct()
    end

    properties (Dependent)
        f_osc
        Kp_crit
    end

    %% ===================== CONSTRUCTOR =====================
    methods

        function obj = StabilityStudy(options)
            %STABILITYSTUDY Create stability analysis object for datacenter power converters.
            arguments
                options.ModelName        (1,1) string
                options.PFCBlocks        (1,:) string
                options.UPSBlock         (1,1) string = ""
                options.CableBlock       (1,1) string = ""
                options.RLCBlock         (1,1) string = ""
                options.ITTrayBlocks     (1,:) string = string.empty
                options.SimlogPaths      (1,1) struct
                options.BlockParams      (1,1) struct
                options.AFEWorkspaceVars (1,1) struct = ...
                    struct('kpVoltage',"ups.AFE.kpVoltage",'kiVoltage',"ups.AFE.kiVoltage")
                options.InverterWorkspaceVars (1,1) struct = struct('kpVd', "invKpVd", 'kiVd', "invKiVd")
                options.OperatingPoint   (1,1) struct
                options.Load             (1,1) struct
                options.Controller       (1,1) struct
                options.UPSController    (1,1) struct = struct('Kp',20,'Ki',300,'C',16,'V_dc',800)
                options.AFEController    (1,1) struct = struct('Kp',20,'Ki',300)
                options.Topology         (1,1) struct = struct('N_total',400,'N_pfc',[133,134,133])
                options.ITTray           (1,1) struct = struct( ...
                    'numRack',3,'nGPU',[8,8,8],'nCPU',[1,1,1], ...
                    'nTray',216,'dcdc_P_rated',[2.07e6,2.07e6,2.07e6], ...
                    'dcdc_eff',0.80,'Ngpu',5184)
                options.SetupScript      (1,1) string = ""
                options.AddPath          (1,:) string = string.empty
                options.ScanFrequencies  (1,:) double = unique([0.5:0.25:20, 21:1:100, 102:2:500])
                options.ScanFs           (1,1) double = 5e3
                options.ScanStart        (1,1) double = 2.0
                options.ScanEnd          (1,1) double = 6.0
                options.PerturbAmplitude (1,1) double = 0.03
                options.R_internal       (1,1) double = 0.002
                options.L_internal       (1,1) double = 2e-6
                options.XR_grid          (1,1) double = 5
                options.P_base_gnc       (1,1) double = 8e6
                options.V_nom_gnc        (1,1) double = 480
            end

            cfg = options;
            cfg.n_pfc = numel(cfg.PFCBlocks);
            cfg.n_itTrays = cfg.ITTray.numRack;
            cfg.P_pfc = cfg.Load.P_total / cfg.OperatingPoint.eta;
            cfg.P_per_pfc = cfg.Load.P_total / cfg.Topology.N_total;
            cfg.Kp_crit = cfg.P_per_pfc / cfg.OperatingPoint.V_dc;

            if isfield(cfg.Load, 'P_facility')
                cfg.P_facility = cfg.Load.P_facility;
                cfg.N_pfc_facility = cfg.Load.N_pfc_facility;
            else
                cfg.P_facility = cfg.P_pfc;
                cfg.N_pfc_facility = cfg.n_pfc;
            end
            cfg.N_scale = cfg.N_pfc_facility / cfg.n_pfc;
            cfg.P_base_grid = cfg.P_facility / 3;

            cfg.GNC.f = cfg.ScanFrequencies;
            cfg.GNC.samplingfrequency = cfg.ScanFs;
            cfg.GNC.start = cfg.ScanStart;
            cfg.GNC.end = cfg.ScanEnd;
            cfg.GNC.Vd = cfg.PerturbAmplitude;
            cfg.GNC.Vq = cfg.PerturbAmplitude;
            cfg.GNC.Vdc = 0;
            cfg.GNC.R_internal = cfg.R_internal;
            cfg.GNC.L_internal = cfg.L_internal;
            cfg.GNC.XR = cfg.XR_grid;
            cfg.GNC.P_base = cfg.P_base_gnc;
            cfg.GNC.V_nom = cfg.V_nom_gnc;
            cfg.GNC.f_line = cfg.OperatingPoint.f_line;

            obj.Cfg = cfg;
            obj.Pal = StabilityStudy.setupGroot();
        end

    end

    %% ===================== DEPENDENT PROPERTIES =====================
    methods

        function val = get.f_osc(obj)
            %GET.F_OSC Return dominant oscillation frequency from firmware bug analysis.
            assert(~isempty(fieldnames(obj.FirmwareBug)), ...
                'StabilityStudy:NotRun', 'Run runFirmwareBug first to obtain f_osc.');
            val = obj.FirmwareBug.f_osc;
        end

        function val = get.Kp_crit(obj)
            %GET.KP_CRIT Return critical proportional gain Kp_crit = P/V0.
            val = obj.Cfg.Kp_crit;
        end

    end

    %% ===================== PUBLIC INFRASTRUCTURE =====================
    methods

        function configureBlocks(obj, options)
            %CONFIGUREBLOCKS Set Simscape block parameters and workspace gains for simulation.
            arguments
                obj
                options.PFCGains        (:,1) struct = struct.empty
                options.CDc             (1,1) double = NaN
                options.GDamp           (1,1) double = NaN
                options.CableR          (1,1) double = NaN
                options.CableL          (1,1) double = NaN
                options.UPSCapacitance  (1,1) double = NaN
                options.UPSKiDC         (1,1) double = NaN
                options.RLC_R           (1,1) double = NaN
                options.RLC_L           (1,1) double = NaN
                options.AFEKp           (1,1) double = NaN
                options.AFEKi           (1,1) double = NaN
                options.InvKpVd         (1,1) double = NaN
                options.InvKiVd         (1,1) double = NaN
                options.StopTime        (1,1) double = NaN
                options.MaxStep         (1,1) double = NaN
                options.UPSMode         (1,1) string = ""
                options.NoiseAmplitude  (1,1) double = NaN
            end

            cfg = obj.Cfg;            bp = cfg.BlockParams;            N_pfc = cfg.Topology.N_pfc;
            if ~isempty(options.PFCGains)
                for k = 1:numel(options.PFCGains)
                    if k > cfg.n_pfc, break; end
                    scale = N_pfc(k);
                    StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.Kp, num2str(scale * options.PFCGains(k).Kp));
                    StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.Ki, num2str(scale * options.PFCGains(k).Ki));
                end
            end

            if ~isnan(options.CDc)
                for k = 1:cfg.n_pfc
                    scale = N_pfc(k);
                    StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.C_dc, num2str(scale * options.CDc));
                end
            end

            if ~isnan(options.GDamp)
                for k = 1:cfg.n_pfc
                    scale = N_pfc(k);
                    StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.G_damp, num2str(scale * options.GDamp));
                end
            end

            if ~isnan(options.CableR)
                set_param(cfg.CableBlock, bp.R, num2str(options.CableR));            end
            if ~isnan(options.CableL)
                set_param(cfg.CableBlock, bp.L, num2str(options.CableL));            end

            if ~isnan(options.RLC_R)
                set_param(cfg.RLCBlock, 'R', num2str(options.RLC_R));            end
            if ~isnan(options.RLC_L)
                set_param(cfg.RLCBlock, 'L', num2str(options.RLC_L));            end

            if ~isnan(options.UPSCapacitance)
                set_param(cfg.UPSBlock, bp.capacitance, num2str(options.UPSCapacitance));            end

            if ~isnan(options.UPSKiDC) && isfield(bp, 'kiDC')
                set_param(cfg.UPSBlock, bp.kiDC, num2str(options.UPSKiDC));            end

            afeCtrl = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
            if ~isnan(options.AFEKp)
                set_param(afeCtrl, 'KpVoltage', num2str(options.AFEKp));
            end
            if ~isnan(options.AFEKi)
                set_param(afeCtrl, 'KiVoltage', num2str(options.AFEKi));
            end

            if ~isnan(options.InvKpVd)
                evalin('base', sprintf('invKpVd = %.8f;', options.InvKpVd));
            end
            if ~isnan(options.InvKiVd)
                evalin('base', sprintf('invKiVd = %.8f;', options.InvKiVd));
            end

            if ~isnan(options.StopTime)
                set_param(cfg.ModelName, 'StopTime', num2str(options.StopTime));            end
            if ~isnan(options.MaxStep)
                set_param(cfg.ModelName, 'MaxStep', num2str(options.MaxStep));            end

            mdl = char(cfg.ModelName);
            solverCfg = [mdl '/Solver Configuration'];
            if options.UPSMode == "bypass"
                set_param([mdl '/Step1'], 'Before', '1', 'After', '1');
                set_param([mdl '/Step3'], 'Before', '0', 'After', '0');
                set_param([mdl '/Step4'], 'Before', '1', 'After', '1');
                set_param(solverCfg, 'MaxNonlinIter', '3');
            elseif options.UPSMode == "normal"
                set_param([mdl '/Step1'], 'Before', '0', 'After', '0');
                set_param([mdl '/Step3'], 'Before', '1', 'After', '1');
                set_param([mdl '/Step4'], 'Before', '0', 'After', '0');
                set_param(solverCfg, 'MaxNonlinIter', '1');
            end

            if ~isnan(options.NoiseAmplitude)
                cpBlk = char(cfg.ModelName) + "/ComputeProfile";
                set_param(cpBlk, 'noiseAmplitude', num2str(options.NoiseAmplitude));
            end

            set_param(cfg.ModelName, 'SimscapeLogType', 'all');
            set_param(cfg.ModelName, 'SimscapeLogDecimation', 50);
            set_param(cfg.ModelName, 'SimscapeLogLimitData', 'off');
            set_param(cfg.ModelName, 'ReturnWorkspaceOutputs', 'on');        end

    end

    %% ===================== SCENARIO METHODS (stubs — filled next) =====================
    methods

        function runSetup(obj, options)
            %RUNSETUP Compute analytical PFC voltage-loop frequency and impedance.
            arguments
                obj
                options.Plot      (1,1) logical = true
                options.FreqRange (1,2) double = [0.01, 1000]
                options.NumPoints (1,1) double = 1000
                options.BuggyGains (1,1) struct = struct('Kp',33,'Ki',600)
            end

            cfg = obj.Cfg;
            pal = obj.Pal;

            % AddPath is a legacy option; project path covers all files now.
            for p = cfg.AddPath
                if p ~= "", addpath(p); end
            end
            % Setup script must run in base workspace for Simulink.
            if cfg.SetupScript ~= ""
                evalin('base', cfg.SetupScript);
            end

            if ~bdIsLoaded(cfg.ModelName)
                load_system(cfg.ModelName);
            end
            set_param(cfg.ModelName, 'SimscapeLogType', 'none');
            set_param(cfg.ModelName, 'SimscapeLogToSDI', 'off');
            set_param(cfg.ModelName, 'SignalLogging', 'on');
            set_param(cfg.ModelName, 'SignalLoggingName', 'logsout');
            set_param(cfg.ModelName, 'ReturnWorkspaceOutputs', 'on');
            V_op = cfg.OperatingPoint.V_dc;
            C = cfg.Controller.C;
            Kp = cfg.Controller.Kp;
            Ki = cfg.Controller.Ki;
            P = cfg.P_per_pfc;
            omega_n = sqrt(Ki / (C * V_op));
            f_n = omega_n / (2*pi);
            zeta = (Kp/V_op - P/V_op^2) / (2*sqrt(C * Ki/V_op));
            % Bode peak of Z_cl(s)=s/(Cs²+bs+Ki/V) is at omega_n, not omega_d
            f_res = f_n;

            r.omega_n = omega_n;
            r.f_n = f_n;
            r.zeta = zeta;
            r.f_res = f_res;
            r.Kp_crit = cfg.Kp_crit;            r.pal = pal;
            r.mdl = cfg.ModelName;
            r.T_freq = table(omega_n, f_n, zeta, f_res, cfg.Kp_crit, ...
                VariableNames=["Natural Freq (rad/s)", "Natural Freq (Hz)", ...
                "Damping Ratio", "Resonant Freq (Hz)", "Critical Kp (W/V)"]);

            Kp_b = options.BuggyGains.Kp;
            Ki_b = options.BuggyGains.Ki;
            zeta_buggy = (Kp_b/V_op - P/V_op^2) / (2*sqrt(C * Ki_b/V_op));
            omega_n_buggy = sqrt(Ki_b / (C * V_op));
            f_n_buggy = omega_n_buggy / (2*pi);

            r.zeta_buggy = zeta_buggy;
            r.f_n_buggy = f_n_buggy;
            r.T_buggy = table(Kp_b, Ki_b, zeta_buggy, f_n_buggy, ...
                VariableNames=["Kp (W/V)", "Ki (W/(V*s))", ...
                "Damping Ratio", "Natural Freq (Hz)"]);

            f_bode = logspace(log10(options.FreqRange(1)), log10(options.FreqRange(2)), options.NumPoints);
            Z_cl = StabilityUtils.computeImpedance(f_bode, C, Kp, Ki, P, V_op);
            Z_cl_buggy = StabilityUtils.computeImpedance(f_bode, C, Kp_b, Ki_b, P, V_op);
            r.f_bode = f_bode;
            r.Z_cl = Z_cl;
            r.Z_cl_buggy = Z_cl_buggy;
            r.Kp_b = Kp_b;
            r.FreqRange = options.FreqRange;

            obj.Setup = r;

            if options.Plot, obj.plotSetup(); end
        end

        function runBaseline(obj, options)
            %RUNBASELINE Simulate nominal operation and extract steady-state metrics.
            arguments
                obj
                options.Plot     (1,1) logical = true
                options.StopTime (1,1) double = 6
            end

            cfg = obj.Cfg;            pal = obj.Pal;
            sp = cfg.SimlogPaths;            V_op = cfg.OperatingPoint.V_dc;            V_ups = cfg.UPSController.V_dc;
            open_system(cfg.ModelName);
            obj.initOperatingPoint();
            gains_nominal = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            obj.configureBlocks(PFCGains=gains_nominal, CDc=cfg.Controller.C, ...
                GDamp=cfg.Controller.G_damp, CableR=1e-3, CableL=1e-3, StopTime=options.StopTime);
            out = sim(cfg.ModelName);
            [t, v_pfc0] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{1}, 'V');
            [~, v_pfc1] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{2}, 'V');
            [~, v_pfc2] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{3}, 'V');
            [~, i_ac0]  = StabilityStudy.extractSimlog(out.simlog, sp.pfc_iac{1}, 'A');
            [~, i_ac1]  = StabilityStudy.extractSimlog(out.simlog, sp.pfc_iac{2}, 'A');
            [t_ups, v_ups_dc] = StabilityStudy.extractSimlog(out.simlog, sp.ups_vdc, 'V');

            dt = mean(diff(t));
            win = max(round(1/(2*60*dt)), 50);
            n_wins = floor(numel(i_ac0)/win);
            t_rms = zeros(n_wins,1);
            I_rms0 = zeros(n_wins,1);
            I_rms1 = zeros(n_wins,1);
            for k = 1:n_wins
                rng = (k-1)*win+1 : k*win;
                t_rms(k) = mean(t(rng));
                I_rms0(k) = sqrt(mean(i_ac0(rng).^2));
                I_rms1(k) = sqrt(mean(i_ac1(rng).^2));
            end

            t_ss = 1.0;
            ss = t > t_ss;

            r.t = t;
            r.v_pfc = [v_pfc0, v_pfc1, v_pfc2];
            r.i_ac = [i_ac0, i_ac1];
            r.t_ups = t_ups;
            r.v_ups = v_ups_dc;
            r.t_rms = t_rms;
            r.I_rms0 = I_rms0;
            r.I_rms1 = I_rms1;
            r.t_ss = t_ss;
            r.ss = ss;
            r.dt = dt;
            r.simOut = out;

            t_ups_ss = max(t_ss, options.StopTime/2);
            ss_ups = t_ups > t_ups_ss;
            pfc_ripple = max(v_pfc0(ss)) - min(v_pfc0(ss));
            ups_ripple = max(v_ups_dc(ss_ups)) - min(v_ups_dc(ss_ups));
            r.T_metrics = table( ...
                V_op, min(v_pfc0(ss)), max(v_pfc0(ss)), pfc_ripple, std(v_pfc0(ss)), ...
                V_ups, min(v_ups_dc(ss_ups)), max(v_ups_dc(ss_ups)), ups_ripple, ...
                VariableNames=["PFC Nominal (V)", "PFC Min (V)", "PFC Max (V)", "PFC Ripple Vpp (V)", "PFC StdDev (V)", ...
                    "UPS Nominal (V)", "UPS Min (V)", "UPS Max (V)", "UPS Ripple Vpp (V)"]);

            r.V_op = V_op;
            r.V_ups = V_ups;
            r.StopTime = options.StopTime;
            r.pal = pal;

            obj.Baseline = r;

            if options.Plot, obj.plotBaseline(); end
        end
        function runFirmwareBug(obj, options)
            %RUNFIRMWAREBUG Simulate degraded PFC firmware and characterize limit cycle.
            arguments
                obj
                options.Plot          (1,1) logical = true
                options.BuggyGains    (1,1) struct = struct('Kp',33,'Ki',600)
                options.BuggyIndex    (1,1) double = 1
                options.StopTime      (1,1) double = 40
                options.AnalysisStart (1,1) double = 20
                options.VirusPower    (1,1) double = 5000
                options.FreqExcite    (1,:) double = [0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.7,1,2,5,10]
            end

            cfg = obj.Cfg;
            V_op = cfg.OperatingPoint.V_dc;
            P = cfg.P_per_pfc;
            C = cfg.Controller.C;
            Kp = cfg.Controller.Kp;
            Ki = cfg.Controller.Ki;
            gains = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            gains(options.BuggyIndex) = options.BuggyGains;
            obj.configureBlocks(PFCGains=gains, CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, StopTime=options.StopTime);

            set_param(cfg.PFCBlocks(options.BuggyIndex), cfg.BlockParams.G_damp, '0.01');
            out = sim(cfg.ModelName);
            sp = cfg.SimlogPaths;
            [t, v0] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{1}, 'V');
            v_others = cell(1, cfg.n_pfc-1);
            for k = 2:cfg.n_pfc
                [~, v_others{k-1}] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{k}, 'V');
            end

            idx_ss = t > options.AnalysisStart;
            v_analysis = v0(idx_ss);
            dt = mean(diff(t(idx_ss)));
            [f_fft, P_fft] = StabilityUtils.computeFFT(v_analysis, dt);
            [~, idx_pk] = max(P_fft(2:end));
            f_osc_val = f_fft(idx_pk + 1);

            Z_cl_excite = abs(StabilityUtils.computeImpedance(options.FreqExcite, C, Kp, Ki, P, V_op));
            V_ripple_pred = options.VirusPower * Z_cl_excite;

            f_n = sqrt(Ki / (C * V_op)) / (2*pi);
            zeta = (Kp/V_op - P/V_op^2) / (2*sqrt(C * Ki/V_op));
            f_res = f_n;
            Q_factor = 1 / (2*zeta);

            r.f_osc = f_osc_val;
            r.Q_factor = Q_factor;
            r.f_res = f_res;
            r.T_ripple = table(options.FreqExcite(:), 20*log10(Z_cl_excite(:)), V_ripple_pred(:), ...
                VariableNames=["Frequency (Hz)", "Impedance (dB)", "Predicted Ripple (V)"]);
            r.t = t;
            r.v0 = v0;
            r.v_others = v_others;
            r.f_fft = f_fft;
            r.P_fft = P_fft;
            r.Z_cl_excite = Z_cl_excite;
            r.V_ripple_pred = V_ripple_pred;
            r.FreqExcite = options.FreqExcite;
            r.VirusPower = options.VirusPower;
            r.StopTime = options.StopTime;
            r.AnalysisStart = options.AnalysisStart;

            obj.FirmwareBug = r;

            if options.Plot, obj.plotFirmwareBug(); end
        end
        function runWeakGrid(obj, options)
            %RUNWEAKGRID Middlebrook loop-gain analysis and SCR sweep simulation.
            arguments
                obj
                options.Plot      (1,1) logical = true
                options.SCR_sweep (1,:) double = [3, 5, 10, 50]
                options.SCR_sim   (1,:) double = [10, 3, 2]
                options.SCR_fine  (1,:) double = linspace(3, 50, 200)
                options.N_dc      (1,:) double = [1, 2, 5, 10]
                options.XR        (1,1) double = 10
                options.TauRms    (1,1) double = 0.040
                options.G_damp    (1,1) double = 0
                options.StopTime  (1,1) double = 5
                options.AnalysisStart (1,1) double = 0.5
                options.BuggyGains (1,1) struct = struct('Kp',30,'Ki',8000)
                options.BuggyIndex (1,1) double = 1
                options.AllBuggyForSCR (1,1) logical = false
                options.AFEDegraded (1,1) struct = struct('Kp',0.05,'Ki',10)
                options.NumFreqPoints (1,1) double = 500
                options.SimulateSCR (1,1) logical = true
                options.Y_measured      = []
            end

            cfg = obj.Cfg;            pal = obj.Pal;
            f_osc_val = obj.f_osc;
            V_nom = cfg.OperatingPoint.V_nom;
            eta = cfg.OperatingPoint.eta;
            P_load_total = cfg.Load.P_total;
            N_scale = cfg.N_scale;
            V_base_grid = 480;
            P_base_grid = cfg.Load.P_facility;            XR_grid = cfg.XR_grid;

            tau_rms = options.TauRms;
            f_tau = 1 / (2*pi*tau_rms);
            Y_0 = P_load_total / (3 * (V_base_grid/sqrt(3))^2 * eta^2);
            f_grid = logspace(-2, 3, options.NumFreqPoints);
            s_grid = 1j*2*pi*f_grid;
            Y_pfc_dyn = Y_0 * (tau_rms*s_grid - 1) ./ (1 + tau_rms*s_grid) + options.G_damp * N_scale;

            r.f_grid = f_grid;
            r.Y_pfc_dyn = Y_pfc_dyn;
            r.f_tau = f_tau;

            T_all = StabilityUtils.computeLoopGain( ...
                f_grid, options.SCR_sweep, V_base_grid, ...
                P_base_grid, XR_grid, Y_pfc_dyn);

            peak_T_dB = zeros(size(options.SCR_sweep));
            f_peak = zeros(size(options.SCR_sweep));
            phase_at_peak = zeros(size(options.SCR_sweep));
            gain_margin_dB = zeros(size(options.SCR_sweep));
            for k = 1:numel(options.SCR_sweep)
                [max_T, idx_max] = max(abs(T_all{k}));
                peak_T_dB(k) = 20*log10(max_T);
                f_peak(k) = f_grid(idx_max);
                phase_at_peak(k) = rad2deg(angle(T_all{k}(idx_max)));
                phase_deg = rad2deg(angle(T_all{k}));
                cross_idx = find(diff(sign(phase_deg + 180)) ~= 0);
                if isempty(cross_idx)
                    gain_margin_dB(k) = Inf;
                else
                    [gm_worst, ~] = min(-20*log10(abs(T_all{k}(cross_idx))));
                    gain_margin_dB(k) = gm_worst;
                end
            end
            status_gm = strings(numel(options.SCR_sweep), 1);
            for k = 1:numel(options.SCR_sweep)
                if isinf(gain_margin_dB(k))
                    status_gm(k) = "STABLE (no phase crossover)";
                elseif gain_margin_dB(k) > 6
                    status_gm(k) = "STABLE";
                elseif gain_margin_dB(k) > 0
                    status_gm(k) = "MARGINAL";
                else
                    status_gm(k) = "UNSTABLE";
                end
            end
            r.T_gainMargin = table(options.SCR_sweep(:), peak_T_dB(:), f_peak(:), ...
                phase_at_peak(:), gain_margin_dB(:), categorical(status_gm), ...
                VariableNames=["Grid SCR", "Peak Sensitivity (dB)", "Peak Freq (Hz)", ...
                "Phase at Peak (deg)", "Gain Margin (dB)", "Status"]);
            r.T_all = T_all;
            r.SCR_sweep = options.SCR_sweep;
            r.V_nom = V_nom;
            r.pal = pal;
            r.StopTime = options.StopTime;
            r.AnalysisStart = options.AnalysisStart;
            r.N_dc = options.N_dc;
            r.f_osc = f_osc_val;

            if ~isempty(options.Y_measured)
                mimo = GNCAnalyzer.computeLoopGainMIMO(options.Y_measured, options.SCR_sim, cfg);
                r.T_gncMIMO = mimo.T_stability;
                r.CDM = mimo.CDM;
            end

            if options.SimulateSCR
                afeCtrl_wg = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
                nomAFEKpExpr_wg = get_param(afeCtrl_wg, 'KpVoltage');
                nomAFEKiExpr_wg = get_param(afeCtrl_wg, 'KiVoltage');

                gains = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
                gains(options.BuggyIndex) = options.BuggyGains;
                obj.configureBlocks(PFCGains=gains, CDc=cfg.Controller.C, GDamp=options.G_damp, ...
CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7, StopTime=options.StopTime);

                out = sim(cfg.ModelName);
                sp = cfg.SimlogPaths;
                [t_grid, i_ac] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_iac{options.BuggyIndex}, 'A');
                dt = t_grid(2) - t_grid(1);
                N_cyc = round(1/(60*dt));
                i_rms_envelope = sqrt(movmean(i_ac.^2, N_cyc));
                idx_ss = t_grid > options.AnalysisStart;
                delta_I_rms = max(i_rms_envelope(idx_ss)) - min(i_rms_envelope(idx_ss));
                I_rms_mean = mean(i_rms_envelope(idx_ss));

                r.delta_I_rms = delta_I_rms;
                r.I_rms_mean = I_rms_mean;

                V_scale = V_nom;

                V_base_scr = 480;
                P_base_scr = cfg.Load.P_facility;                XR_scr = cfg.XR_grid;
                R_internal = cfg.R_internal;
                L_internal = cfg.L_internal;
                f_line = cfg.OperatingPoint.f_line;                n_scr = numel(options.SCR_sim);

                healthy_gains_scr = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
                if options.AllBuggyForSCR
                    healthy_gains_scr = repmat(options.BuggyGains, cfg.n_pfc, 1);                end
                obj.configureBlocks(PFCGains=healthy_gains_scr);
                set_param(cfg.ModelName, 'LoadInitialState', 'off');                out_scr = cell(1, n_scr);
                Z_grid_vals = zeros(1, n_scr);
                diverged = false(1, n_scr);
                for k = 1:n_scr
                    Z_base_k = V_base_scr^2 / (options.SCR_sim(k) * P_base_scr);
                    X_k = Z_base_k * XR_scr / sqrt(1 + XR_scr^2);
                    R_k = X_k / XR_scr;
                    L_k = X_k / (2*pi*f_line);
                    Z_grid_vals(k) = Z_base_k;
                    R_rlc = max(R_k - R_internal, 1e-4);
                    L_rlc = max(L_k - L_internal, 1e-7);
                    obj.configureBlocks(RLC_R=R_rlc, RLC_L=L_rlc);
                    try
                        out_scr{k} = sim(cfg.ModelName);                    catch ME
                        fprintf('SCR=%g simulation diverged: %s\n', options.SCR_sim(k), ME.message);
                        diverged(k) = true;
                    end
                end
                healthy_gains = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
                obj.configureBlocks(PFCGains=healthy_gains, CableR=1e-3, CableL=1e-3, ...
                    RLC_R=1e-4, RLC_L=1e-7);
                set_param(afeCtrl_wg, 'KpVoltage', nomAFEKpExpr_wg, 'KiVoltage', nomAFEKiExpr_wg);
                V_pcc_3ph = cell(1, n_scr);
                I_pcc_3ph = cell(1, n_scr);
                t_pcc_all = cell(1, n_scr);
                flicker_pct = zeros(1, n_scr);
                i_ripple_pct = zeros(1, n_scr);
                V_pcc_min = zeros(1, n_scr);
                V_pcc_max = zeros(1, n_scr);
                dV_pcc = zeros(1, n_scr);
                I_scale = 100e6 / (sqrt(3) * 480);

                for k = 1:n_scr
                    if diverged(k)
                        V_pcc_3ph{k} = NaN; I_pcc_3ph{k} = NaN; t_pcc_all{k} = NaN;
                        V_pcc_max(k) = NaN; V_pcc_min(k) = NaN; dV_pcc(k) = NaN;
                        flicker_pct(k) = NaN; i_ripple_pct(k) = NaN;
                        continue;
                    end
                    rmsV_node = out_scr{k}.get('simlog').Measurement_A.Measurements.PS_RMS_Estimator.O;
                    rmsI_node = out_scr{k}.get('simlog').Measurement_A.Measurements.PS_RMS_Estimator1.O;
                    t_k = rmsV_node.series.time;
                    v_rms_pu = rmsV_node.series.values;
                    i_rms_pu = rmsI_node.series.values;
                    idx_k = t_k > options.AnalysisStart;
                    V_pcc_3ph{k} = v_rms_pu(idx_k,:) * V_scale;
                    I_pcc_3ph{k} = i_rms_pu(idx_k,:) * I_scale;
                    t_pcc_all{k} = t_k(idx_k);
                    v_a = v_rms_pu(idx_k,1);
                    i_a = i_rms_pu(idx_k,1);
                    V_pcc_max(k) = max(v_a) * V_scale;
                    V_pcc_min(k) = min(v_a) * V_scale;
                    dV_pcc(k) = V_pcc_max(k) - V_pcc_min(k);
                    flicker_pct(k) = (max(v_a) - min(v_a)) / mean(v_a) * 100;
                    i_ripple_pct(k) = (max(i_a) - min(i_a)) / mean(i_a) * 100;
                end
                V_pcc_rms = cell(1, n_scr);
                for k = 1:n_scr
                    if ~diverged(k), V_pcc_rms{k} = V_pcc_3ph{k}(:,1);
                    else, V_pcc_rms{k} = NaN; end
                end

                status_flk = strings(n_scr, 1);
                for k = 1:n_scr
                    if diverged(k)
                        status_flk(k) = "DIVERGED";
                    elseif flicker_pct(k) > 10
                        status_flk(k) = "SEVERE";
                    elseif flicker_pct(k) > 5
                        status_flk(k) = "WARNING";
                    elseif flicker_pct(k) > 3
                        status_flk(k) = "IEC LIMIT";
                    else
                        status_flk(k) = "OK";
                    end
                end
                r.T_flicker = table(options.SCR_sim(:), Z_grid_vals(:), dV_pcc(:), flicker_pct(:), ...
                    V_pcc_min(:), V_pcc_max(:), categorical(status_flk), ...
                    VariableNames=["Grid SCR", "Grid Impedance (Ohm)", "PCC Voltage Swing (V)", ...
                    "PCC Flicker (%)", "PCC Min (V)", "PCC Max (V)", "Status"]);
                r.V_pcc_rms = V_pcc_rms;
                r.V_pcc_3ph = V_pcc_3ph;
                r.I_pcc_3ph = I_pcc_3ph;
                r.t_pcc = t_pcc_all;
                r.diverged = diverged;
            end

            s_osc = 1j*2*pi*f_osc_val;
            Y_at_fosc = Y_0 * (tau_rms*s_osc - 1) / (1 + tau_rms*s_osc) + options.G_damp * N_scale;
            amplification = StabilityUtils.computeAmplification( ...
                options.SCR_fine, f_osc_val, V_base_grid, ...
                P_base_grid, XR_grid, Y_at_fosc);
            r.amplification = amplification;
            r.SCR_fine = options.SCR_fine;
            r.Y_at_fosc = Y_at_fosc;
            r.V_base_grid = V_base_grid;
            r.P_base_grid = P_base_grid;
            r.XR_grid = XR_grid;

            obj.configureBlocks(CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7);

            obj.WeakGrid = r;

            if options.Plot, obj.plotWeakGrid(); end
        end
        function runUPSIsolation(obj, options)
            %RUNUPSISOLATION Verify PFC decoupling from grid via UPS double-conversion.
            arguments
                obj
                options.Plot          (1,1) logical = true
                options.SCR_extreme   (1,1) double = 5
                options.StopTime      (1,1) double = 5
                options.StopTimeRes   (1,1) double = 5
                options.AnalysisStart (1,1) double = 0.5
                options.AnalysisStartRes (1,1) double = 0.5
                options.BuggyGains    (1,1) struct = struct('Kp',30,'Ki',8000)
                options.C_ups_undersized (1,1) double = 0.05
                options.AFEDegradedRes (1,1) struct = struct('Kp', 0.2, 'Ki', 10)
                options.StopTimeRes2  (1,1) double = 15
            end

            cfg = obj.Cfg;            pal = obj.Pal;
            f_osc_val = obj.f_osc;
            V_nom = cfg.OperatingPoint.V_nom;
            V_ups = cfg.UPSController.V_dc;
            V_op = cfg.OperatingPoint.V_dc;
            C_ups_nom = cfg.UPSController.C;
            Kp_ups = cfg.UPSController.Kp;
            Ki_ups = cfg.UPSController.Ki;
            P_total = cfg.Load.P_total;
            XR = cfg.XR_grid;
            f_line = cfg.OperatingPoint.f_line;
            P_base = cfg.P_base_grid;            Z_grid_extreme = V_nom^2 / (options.SCR_extreme * P_base);
            X_extreme = Z_grid_extreme * XR / sqrt(1 + XR^2);
            R_extreme = X_extreme / XR;
            L_extreme = X_extreme / (2*pi*f_line);

            gains_healthy = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            gains_buggy = gains_healthy;
            gains_buggy(1) = options.BuggyGains;

            sp = cfg.SimlogPaths;            pfc_buggy_path = sp.pfc_vdc{1};

            obj.configureBlocks(PFCGains=gains_healthy, CDc=cfg.Controller.C, GDamp=0, ...
CableR=1e-3, CableL=1e-3, UPSKiDC=Ki_ups, StopTime=options.StopTime);
            out_strong = sim(cfg.ModelName);
            obj.configureBlocks(CableR=R_extreme, CableL=L_extreme*1000);
            out_weak = sim(cfg.ModelName);
            obj.configureBlocks(PFCGains=gains_buggy, CableR=1e-3, CableL=1e-3);
            out_fw_strong = sim(cfg.ModelName);
            obj.configureBlocks(CableR=R_extreme, CableL=L_extreme*1000);
            out_fw_weak = sim(cfg.ModelName);
            [t_strong, v_pfc0_strong] = StabilityStudy.extractSimlog(out_strong.simlog, pfc_buggy_path, 'V');
            [~, v_ups_strong] = StabilityStudy.extractSimlog(out_strong.simlog, sp.ups_vdc, 'V');
            [t_weak, v_pfc0_weak] = StabilityStudy.extractSimlog(out_weak.simlog, pfc_buggy_path, 'V');
            [~, v_ups_weak] = StabilityStudy.extractSimlog(out_weak.simlog, sp.ups_vdc, 'V');
            [t_fws, v_fws] = StabilityStudy.extractSimlog(out_fw_strong.simlog, pfc_buggy_path, 'V');
            [t_fww, v_fww] = StabilityStudy.extractSimlog(out_fw_weak.simlog, pfc_buggy_path, 'V');

            idx_ss_s = t_fws > options.AnalysisStart;
            idx_ss_w = t_fww > options.AnalysisStart;
            ripple_strong = max(v_fws(idx_ss_s)) - min(v_fws(idx_ss_s));
            ripple_weak = max(v_fww(idx_ss_w)) - min(v_fww(idx_ss_w));

            r.T_isolation = table(categorical(["Strong grid";"SCR = " + string(options.SCR_extreme)]), ...
                [ripple_strong; ripple_weak], ...
                VariableNames=["Grid Condition", "PFC Ripple Vpp (V)"]);

            r.t_strong = t_strong; r.v_pfc0_strong = v_pfc0_strong; r.v_ups_strong = v_ups_strong;
            r.t_weak = t_weak; r.v_pfc0_weak = v_pfc0_weak; r.v_ups_weak = v_ups_weak;
            r.t_fws = t_fws; r.v_fws = v_fws;
            r.t_fww = t_fww; r.v_fww = v_fww;
            r.V_op = V_op; r.V_ups = V_ups;
            r.SCR_extreme = options.SCR_extreme;
            r.StopTime = options.StopTime;
            r.AnalysisStart = options.AnalysisStart;
            r.pal = pal;

            % Scenario F: UPS DC Bus Resonance
            omega_n_ups = sqrt(Ki_ups / (C_ups_nom * V_ups));
            f_n_ups = omega_n_ups / (2*pi);
            zeta_ups = (Kp_ups/V_ups - P_total/V_ups^2) / (2*sqrt(C_ups_nom * Ki_ups/V_ups));
            Q_ups = 1 / (2*zeta_ups);

            C_ups_res = options.C_ups_undersized;
            omega_n_ups_res = sqrt(Ki_ups / (C_ups_res * V_ups));
            f_n_ups_res = omega_n_ups_res / (2*pi);
            zeta_ups_res = (Kp_ups/V_ups - P_total/V_ups^2) / (2*sqrt(C_ups_res * Ki_ups/V_ups));
            Q_ups_res = 1 / (2*zeta_ups_res);

            r.T_upsParams = table(categorical(["Nominal C";"Undersized C"]), ...
                [f_n_ups; f_n_ups_res], [zeta_ups; zeta_ups_res], [Q_ups; Q_ups_res], ...
                VariableNames=["Configuration", "Natural Freq (Hz)", "Damping Ratio", "Q Factor"]);

            f_bode_ups = logspace(-2, 2, 500);
            Z_cl_ups_nom = StabilityUtils.computeImpedance(f_bode_ups, C_ups_nom, Kp_ups, Ki_ups, P_total, V_ups);
            Z_cl_ups_res = StabilityUtils.computeImpedance(f_bode_ups, C_ups_res, Kp_ups, Ki_ups, P_total, V_ups);
            r.f_bode_ups = f_bode_ups;
            r.Z_cl_ups_nom = Z_cl_ups_nom;
            r.Z_cl_ups_res = Z_cl_ups_res;

            afeCtrl_iso = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
            nomAFEKpExpr_iso = get_param(afeCtrl_iso, 'KpVoltage');
            nomAFEKiExpr_iso = get_param(afeCtrl_iso, 'KiVoltage');

            gains_all_buggy = repmat(options.BuggyGains, cfg.n_pfc, 1);
            obj.configureBlocks(PFCGains=gains_all_buggy, CDc=cfg.Controller.C, GDamp=0, ...
CableR=1e-3, CableL=1e-3, StopTime=options.StopTimeRes, UPSCapacitance=C_ups_nom);
            try
                out_ups_nom = sim(cfg.ModelName);
            catch ME
                fprintf('UPS resonance (nominal C) diverged: %s\n', ME.message);
                out_ups_nom = [];
            end

            obj.configureBlocks(UPSCapacitance=C_ups_res, ...
                AFEKp=options.AFEDegradedRes.Kp, AFEKi=options.AFEDegradedRes.Ki, ...
                StopTime=options.StopTimeRes2);
            try
                out_ups_res = sim(cfg.ModelName);
            catch ME
                fprintf('UPS resonance (undersized C + degraded AFE) diverged: %s\n', ME.message);
                out_ups_res = [];
            end

            set_param(afeCtrl_iso, 'KpVoltage', nomAFEKpExpr_iso, 'KiVoltage', nomAFEKiExpr_iso);
            if ~isempty(out_ups_nom) && ~isempty(out_ups_res)
                [t_un, v_ups_nom_t] = StabilityStudy.extractSimlog(out_ups_nom.simlog, sp.ups_vdc, 'V');
                [t_ur, v_ups_res_t] = StabilityStudy.extractSimlog(out_ups_res.simlog, sp.ups_vdc, 'V');
                [~, v_pfc0_nom_t] = StabilityStudy.extractSimlog(out_ups_nom.simlog, pfc_buggy_path, 'V');
                [~, v_pfc0_res_t] = StabilityStudy.extractSimlog(out_ups_res.simlog, pfc_buggy_path, 'V');
                idx_un = t_un > options.AnalysisStartRes;
                idx_ur = t_ur > options.AnalysisStartRes;
                ups_ripple_nom = max(v_ups_nom_t(idx_un)) - min(v_ups_nom_t(idx_un));
                ups_ripple_res = max(v_ups_res_t(idx_ur)) - min(v_ups_res_t(idx_ur));
                pfc0_ripple_nom = max(v_pfc0_nom_t(idx_un)) - min(v_pfc0_nom_t(idx_un));
                pfc0_ripple_res = max(v_pfc0_res_t(idx_ur)) - min(v_pfc0_res_t(idx_ur));
            elseif ~isempty(out_ups_nom)
                [t_un, v_ups_nom_t] = StabilityStudy.extractSimlog(out_ups_nom.simlog, sp.ups_vdc, 'V');
                [~, v_pfc0_nom_t] = StabilityStudy.extractSimlog(out_ups_nom.simlog, pfc_buggy_path, 'V');
                idx_un = t_un > options.AnalysisStartRes;
                ups_ripple_nom = max(v_ups_nom_t(idx_un)) - min(v_ups_nom_t(idx_un));
                pfc0_ripple_nom = max(v_pfc0_nom_t(idx_un)) - min(v_pfc0_nom_t(idx_un));
                ups_ripple_res = NaN; pfc0_ripple_res = NaN;
                t_ur = []; v_ups_res_t = []; v_pfc0_res_t = [];
            else
                ups_ripple_nom = NaN; ups_ripple_res = NaN;
                pfc0_ripple_nom = NaN; pfc0_ripple_res = NaN;
                t_un = []; t_ur = []; v_ups_nom_t = []; v_ups_res_t = [];
                v_pfc0_nom_t = []; v_pfc0_res_t = [];
            end

            r.T_resonance = table(categorical(["Nominal C";"Undersized C"]), ...
                [ups_ripple_nom; ups_ripple_res], [pfc0_ripple_nom; pfc0_ripple_res], ...
                [ups_ripple_res/max(ups_ripple_nom,0.01); NaN], ...
                VariableNames=["Configuration", "UPS Ripple Vpp (V)", "PFC Ripple Vpp (V)", "Amplification Factor"]);

            r.t_un = t_un; r.v_ups_nom_t = v_ups_nom_t; r.v_pfc0_nom_t = v_pfc0_nom_t;
            r.t_ur = t_ur; r.v_ups_res_t = v_ups_res_t; r.v_pfc0_res_t = v_pfc0_res_t;
            r.C_ups_nom = C_ups_nom; r.C_ups_res = C_ups_res;
            r.f_n_ups = f_n_ups; r.f_n_ups_res = f_n_ups_res;
            r.f_osc = f_osc_val;
            r.AFEDegradedRes = options.AFEDegradedRes;
            r.StopTimeRes = options.StopTimeRes;
            r.StopTimeRes2 = options.StopTimeRes2;

            obj.configureBlocks(UPSCapacitance=C_ups_nom, CableR=1e-3, CableL=1e-3);

            obj.UPSIsolation = r;

            if options.Plot, obj.plotUPSIsolation(); end
        end
        function runAFEDegradation(obj, options)
            %RUNAFEDEGRADATION Sweep AFE controller gains and quantify UPS bus ripple.
            arguments
                obj
                options.Plot          (1,1) logical = true
                options.StopTime      (1,1) double = 5
                options.AnalysisStart (1,1) double = 0.5
                options.BuggyGains    (1,1) struct = struct('Kp',30,'Ki',8000)
                options.AFE_cases     (:,1) struct = struct( ...
                    'label', {'Nominal','Mild (-10x Kp)', ...
                              'Moderate (-100x Kp, -30x Ki)', ...
                              'Severe (-400x Kp, -30x Ki)'}, ...
                    'Kp', {20, 2, 0.2, 0.05}, ...
                    'Ki', {300, 50, 10, 10})
                options.SCR_grid_test (1,1) double = 10
            end

            cfg = obj.Cfg;            pal = obj.Pal;
            f_osc_val = obj.f_osc;
            V_ups = cfg.UPSController.V_dc;
            V_op = cfg.OperatingPoint.V_dc;
            V_nom = cfg.OperatingPoint.V_nom;
            C_ups = cfg.UPSController.C;
            P_total = cfg.Load.P_total;
            Kp_AFE_nom = cfg.AFEController.Kp;
            Ki_AFE_nom = cfg.AFEController.Ki;
            afeCtrl_ = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
            nomAFEKpExpr_ = get_param(afeCtrl_, 'KpVoltage');
            nomAFEKiExpr_ = get_param(afeCtrl_, 'KiVoltage');
            XR = cfg.XR_grid;
            f_line = cfg.OperatingPoint.f_line;
            AFE_cases = options.AFE_cases;
            n_cases = numel(AFE_cases);
            colors_G = {pal.blue, pal.green, pal.orange, pal.red};

            f_analysis = logspace(-2, 2, 500);
            s_analysis = 1j*2*pi*f_analysis;

            L_all = cell(1, n_cases);
            S_all = cell(1, n_cases);
            for k = 1:n_cases
                Gc = AFE_cases(k).Kp + AFE_cases(k).Ki ./ s_analysis;
                Gp = P_total ./ (C_ups * V_ups * s_analysis);
                L_all{k} = Gc .* Gp;
                S_all{k} = 1 ./ (1 + L_all{k});
            end

            L_at_fosc = zeros(n_cases, 1);
            S_at_fosc = zeros(n_cases, 1);
            for k = 1:n_cases
                L_mag = abs((AFE_cases(k).Kp + AFE_cases(k).Ki/(1j*2*pi*f_osc_val)) * ...
                    P_total / (C_ups * V_ups * 1j*2*pi*f_osc_val));
                L_at_fosc(k) = 20*log10(L_mag);
                S_at_fosc(k) = 20*log10(1/(1+L_mag));
            end

            r.T_rejection = table(categorical(string({AFE_cases.label}')), ...
                [AFE_cases.Kp]', [AFE_cases.Ki]', L_at_fosc, S_at_fosc, ...
                VariableNames=["AFE Case", "Kp (W/V)", "Ki (W/(V*s))", "Loop Gain (dB)", "Sensitivity (dB)"]);
            r.f_analysis = f_analysis;
            r.L_all = L_all;
            r.S_all = S_all;
            r.AFE_cases = AFE_cases;
            r.colors_G = colors_G;
            r.f_osc = f_osc_val;
            r.V_ups = V_ups;
            r.V_op = V_op;
            r.StopTime = options.StopTime;
            r.AnalysisStart = options.AnalysisStart;
            r.pal = pal;

            gains_mixed = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            gains_mixed(1) = options.BuggyGains;
            obj.configureBlocks(PFCGains=gains_mixed, CDc=cfg.Controller.C, GDamp=0, ...
CableR=1e-3, CableL=1e-3, UPSCapacitance=C_ups, StopTime=options.StopTime);

            sp = cfg.SimlogPaths;
            pfc0_path = sp.pfc_vdc{1};

            out_G = cell(1, n_cases);
            for k = 1:n_cases
                obj.configureBlocks(AFEKp=AFE_cases(k).Kp, AFEKi=AFE_cases(k).Ki);
                out_G{k} = sim(cfg.ModelName);
            end

            ups_ripple = zeros(1, n_cases);
            pfc_ripple = zeros(1, n_cases);
            ups_mean = zeros(1, n_cases);
            for k = 1:n_cases
                [t_k, v_ups_k] = StabilityStudy.extractSimlog(out_G{k}.simlog, sp.ups_vdc, 'V');
                [~, v_pfc_k] = StabilityStudy.extractSimlog(out_G{k}.simlog, pfc0_path, 'V');
                idx_ss = t_k > options.AnalysisStart;
                ups_ripple(k) = max(v_ups_k(idx_ss)) - min(v_ups_k(idx_ss));
                pfc_ripple(k) = max(v_pfc_k(idx_ss)) - min(v_pfc_k(idx_ss));
                ups_mean(k) = mean(v_ups_k(idx_ss));
            end

            r.T_ripple = table(categorical(string({AFE_cases.label}')), ...
                ups_ripple(:), pfc_ripple(:), ups_mean(:), ...
                VariableNames=["AFE Case", "UPS Ripple Vpp (V)", "PFC Ripple Vpp (V)", "UPS Mean (V)"]);
            r.ups_ripple = ups_ripple;
            r.pfc_ripple = pfc_ripple;
            r.out_G = out_G;
            r.sp = sp;
            r.pfc0_path = pfc0_path;

            P_base = cfg.P_base_grid;            Z_base_test = V_nom^2 / (options.SCR_grid_test * P_base);
            X_test = Z_base_test * XR / sqrt(1 + XR^2);
            R_test = X_test / XR;
            L_test = X_test / (2*pi*f_line);

            try
                obj.configureBlocks(CableR=R_test, CableL=L_test*1000, AFEKp=Kp_AFE_nom, AFEKi=Ki_AFE_nom);
                out_scr3_nom = sim(cfg.ModelName);
                obj.configureBlocks(AFEKp=AFE_cases(end).Kp, AFEKi=AFE_cases(end).Ki);
                out_scr3_deg = sim(cfg.ModelName);
                [t_nom3, v_ups_nom3] = StabilityStudy.extractSimlog(out_scr3_nom.simlog, sp.ups_vdc, 'V');
                [t_deg3, v_ups_deg3] = StabilityStudy.extractSimlog(out_scr3_deg.simlog, sp.ups_vdc, 'V');
                idx_n = t_nom3 > options.AnalysisStart;
                idx_d = t_deg3 > options.AnalysisStart;
                rip_nom_scr = max(v_ups_nom3(idx_n)) - min(v_ups_nom3(idx_n));
                rip_deg_scr = max(v_ups_deg3(idx_d)) - min(v_ups_deg3(idx_d));
            catch
                rip_nom_scr = NaN;
                rip_deg_scr = NaN;
            end

            obj.configureBlocks(CableR=1e-3, CableL=1e-3);
            set_param(afeCtrl_, 'KpVoltage', nomAFEKpExpr_, 'KiVoltage', nomAFEKiExpr_);

            r.rip_nom_scr3 = rip_nom_scr;
            r.rip_deg_scr3 = rip_deg_scr;
            if ~isnan(rip_nom_scr)
                r.t_nom3 = t_nom3;
                r.v_ups_nom3 = v_ups_nom3;
                r.t_deg3 = t_deg3;
                r.v_ups_deg3 = v_ups_deg3;
            end
            r.SCR_grid_test = options.SCR_grid_test;

            gains_healthy = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            obj.configureBlocks(PFCGains=gains_healthy, CDc=cfg.Controller.C, GDamp=0, ...
CableR=1e-3, CableL=1e-3, UPSKiDC=cfg.UPSController.Ki);
            obj.AFEDegradation = r;

            if options.Plot, obj.plotAFEDegradation(); end
        end
        function runStabilityMap(obj, options)
            %RUNSTABILITYMAP Compute damping ratio vs proportional gain map.
            arguments
                obj
                options.Plot    (1,1) logical = true
                options.KpRange (1,2) double = [0, 350]
                options.KpNominal (1,1) double = 200
                options.KpBuggy (1,1) double = 33
            end

            cfg = obj.Cfg;            pal = obj.Pal;
            V = cfg.OperatingPoint.V_dc;
            P = cfg.P_per_pfc;
            C = cfg.Controller.C;
            Ki = cfg.Controller.Ki;
            Kp_sweep = linspace(options.KpRange(1), options.KpRange(2), 200);
            zeta_sweep = (Kp_sweep/V - P/V^2) ./ (2*sqrt(C*Ki/V));

            zeta_nominal = interp1(Kp_sweep, zeta_sweep, options.KpNominal);
            zeta_buggy = interp1(Kp_sweep, zeta_sweep, options.KpBuggy);

            r.Kp_sweep = Kp_sweep;
            r.zeta_sweep = zeta_sweep;
            r.KpRange = options.KpRange;
            r.Ki = Ki;
            r.KpNominal = options.KpNominal;
            r.KpBuggy = options.KpBuggy;
            r.zeta_nominal = zeta_nominal;
            r.zeta_buggy = zeta_buggy;
            r.Kp_crit = cfg.Kp_crit;            r.pal = pal;

            obj.StabilityMap = r;

            if options.Plot, obj.plotStabilityMap(); end
        end
        function runImpedanceScan(obj, options)
            %RUNIMPEDANCESCAN Nyquist impedance scan for firmware penetration limit.
            arguments
                obj
                options.Plot      (1,1) logical = true
                options.BuggyKp   (1,1) double = 33
                options.HealthyKp (1,1) double = 200
                options.Ki        (1,1) double = 600
                options.FreqHz    (1,:) double = logspace(-2, 2, 1000)
                options.Fractions (1,:) double = 0:0.05:1
                options.MarginThreshold (1,1) double = 0.9
            end

            cfg = obj.Cfg;
            V = cfg.OperatingPoint.V_dc;
            P_total = cfg.Load.P_total;
            C_unit = cfg.Controller.C;
            Ki = options.Ki;
            Kp_h = options.HealthyKp;
            Kp_b = options.BuggyKp;
            P_unit = P_total / 400;
            N_total = 400;

            s = tf('s');
            w_vec = 2*pi*options.FreqHz;

            pfcImpedance = @(Kp_agg, Ki_agg, C_agg, P_agg) ...
                V*(s + Ki_agg/Kp_agg) / (C_agg*V*s^2 + (Kp_agg - P_agg/V)*s + Ki_agg);

            fracs = options.Fractions;
            encirclements = zeros(size(fracs));
            min_dist = zeros(size(fracs));

            for i = 1:numel(fracs)
                N_buggy = round(fracs(i) * N_total);
                N_healthy = N_total - N_buggy;

                Y_total = tf(0);
                if N_buggy > 0
                    Z_b = pfcImpedance(N_buggy*Kp_b, N_buggy*Ki, N_buggy*C_unit, N_buggy*P_unit);
                    Y_total = Y_total + 1/Z_b;
                end
                if N_healthy > 0
                    Z_h = pfcImpedance(N_healthy*Kp_h, N_healthy*Ki, N_healthy*C_unit, N_healthy*P_unit);
                    Y_total = Y_total + 1/Z_h;
                end

                L_i = (1/Y_total) * P_total / V^2;
                [re_i, im_i] = nyquist(L_i, w_vec);
                re_i = squeeze(re_i); im_i = squeeze(im_i);
                z_i = complex(re_i + 1, im_i);
                dtheta = diff(unwrap(angle(z_i)));
                encirclements(i) = round(sum(dtheta) / (2*pi));
                min_dist(i) = min(abs(complex(re_i, im_i) - (-1)));
            end

            idx_crit = find(encirclements ~= 0, 1);
            if ~isempty(idx_crit)
                frac_crit = fracs(idx_crit);
            else
                frac_crit = NaN;
            end

            idx_marginal = find(min_dist < options.MarginThreshold, 1);
            if ~isempty(idx_marginal)
                frac_marginal = fracs(idx_marginal);
            else
                frac_marginal = NaN;
            end

            frac_show = [1/3, 0.80];
            for f_add = [frac_marginal, frac_crit]
                if ~isnan(f_add) && ~any(abs(frac_show - f_add) < 0.01)
                    frac_show = sort([frac_show, f_add]);
                end
            end
            scenario_fracs = [0, frac_show];
            scenario_labels = cell(1, numel(scenario_fracs));
            scenario_colors = cell(1, numel(scenario_fracs));
            color_pool = {'b', [0 0.6 0], [0.8 0.5 0], 'r', [0.5 0 0.5]};
            for i = 1:numel(scenario_fracs)
                f_i = scenario_fracs(i);
                idx_match = find(abs(fracs - f_i) < 0.001, 1);
                if abs(f_i - frac_crit) < 0.01
                    scenario_labels{i} = sprintf('%.0f%% (unstable, N=%d)', f_i*100, encirclements(idx_match));
                elseif abs(f_i - frac_marginal) < 0.01
                    scenario_labels{i} = sprintf('%.0f%% (marginal)', f_i*100);
                elseif ~isempty(idx_match) && encirclements(idx_match) ~= 0
                    scenario_labels{i} = sprintf('%.0f%% degraded (N=%d)', f_i*100, encirclements(idx_match));
                else
                    scenario_labels{i} = sprintf('%.0f%% degraded', f_i*100);
                end
                scenario_colors{i} = color_pool{min(i, numel(color_pool))};
            end
            scenarios = struct('frac', num2cell(scenario_fracs), ...
                'label', scenario_labels, 'color', scenario_colors);

            L_systems = cell(1, numel(scenarios));
            for i = 1:numel(scenarios)
                N_buggy = round(scenarios(i).frac * N_total);
                N_healthy = N_total - N_buggy;
                Y_tot = tf(0);
                if N_buggy > 0
                    Z_b = pfcImpedance(N_buggy*Kp_b, N_buggy*Ki, N_buggy*C_unit, N_buggy*P_unit);
                    Y_tot = Y_tot + 1/Z_b;
                end
                if N_healthy > 0
                    Z_h = pfcImpedance(N_healthy*Kp_h, N_healthy*Ki, N_healthy*C_unit, N_healthy*P_unit);
                    Y_tot = Y_tot + 1/Z_h;
                end
                L_systems{i} = (1/Y_tot) * P_total / V^2;
            end

            r.fractions = fracs;
            r.encirclements = encirclements;
            r.min_dist = min_dist;
            r.frac_critical = frac_crit;
            r.N_critical = round(frac_crit * N_total);
            r.frac_marginal = frac_marginal;
            r.N_marginal = round(frac_marginal * N_total);
            r.MarginThreshold = options.MarginThreshold;
            r.L_systems = L_systems;
            r.scenarios = scenarios;
            r.FreqHz = options.FreqHz;
            r.w_vec = w_vec;
            r.Kp_h = Kp_h;
            r.Kp_b = Kp_b;
            r.P_total = P_total;
            r.V = V;
            r.pal = obj.Pal;

            obj.ImpedanceScan = r;

            if options.Plot, obj.plotImpedanceScan(); end
        end

        function runUPSBypassDemo(obj, options)
            %RUNUPSBYPASSDEMO Four-case study: firmware bug, bypass+weak grid, SCR sweep, degraded AFE.
            arguments
                obj
                options.Plot          (1,1) logical = true
                options.BuggyGains    (1,1) struct = struct('Kp',33,'Ki',600)
                options.BuggyIndex    (1,1) double = 1
                options.StopTime      (1,1) double = 7
                options.AnalysisStart (1,1) double = 0.5
                options.SCR_sweep     (1,:) double = [10, 5, 3]
                options.AFE_degraded  (1,1) struct = struct('Kp',8,'Ki',120)
                options.BuggyNoiseAmp (1,1) double = 0.10
            end

            cfg = obj.Cfg;
            pal = obj.Pal;
            sp = cfg.SimlogPaths;
            V_op = cfg.OperatingPoint.V_dc;
            V_nom = cfg.OperatingPoint.V_nom;
            V_ups = cfg.UPSController.V_dc;
            f_line = cfg.OperatingPoint.f_line;
            bi = options.BuggyIndex;

            gains_healthy = repmat(struct('Kp', cfg.Controller.Kp, 'Ki', cfg.Controller.Ki), cfg.n_pfc, 1);
            gains_buggy = gains_healthy;
            gains_buggy(bi) = options.BuggyGains;

            nomNoiseAmp = str2double(get_param(char(cfg.ModelName) + "/ComputeProfile", 'noiseAmplitude'));
            afeCtrl_ = char(cfg.ModelName) + "/UPS/Rectifier/PFC Rectifier Controller";
            nomAFEKpExpr = get_param(afeCtrl_, 'KpVoltage');
            nomAFEKiExpr = get_param(afeCtrl_, 'KiVoltage');
            restoreFcn = @() StabilityStudy.restoreUPSDemo(cfg, gains_healthy, ...
                nomNoiseAmp, afeCtrl_, nomAFEKpExpr, nomAFEKiExpr);
            restoreAll = onCleanup(restoreFcn);

            obj.initOperatingPoint();

            extractAll = @(out) obj.extractPFCSignals(out, sp, cfg.n_pfc, options.AnalysisStart);

            % --- Case 1: Firmware Bug — forced resonance under workload fluctuation ---
            obj.configureBlocks(UPSMode="normal", PFCGains=gains_buggy, ...
                CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7, ...
                MaxStep=2e-3, StopTime=options.StopTime, ...
                NoiseAmplitude=options.BuggyNoiseAmp);
            set_param(cfg.ModelName, 'LoadInitialState', 'off');
            out_fw = sim(cfg.ModelName);
            firmware = extractAll(out_fw);

            dt_fw = mean(diff(firmware.t{1}));
            [f_fft_fw, P_fft_fw] = StabilityUtils.computeFFT(firmware.v{bi}, dt_fw);
            [~, idx_pk] = max(P_fft_fw(2:end));
            firmware.f_osc = f_fft_fw(idx_pk + 1);
            firmware.f_fft = f_fft_fw;
            firmware.P_fft = P_fft_fw;

            [firmware.t_ups, firmware.v_ups] = StabilityStudy.extractSimlog( ...
                out_fw.get('simlog'), sp.ups_vdc, 'V');
            idx_fw_ups = firmware.t_ups > options.AnalysisStart;
            firmware.t_ups = firmware.t_ups(idx_fw_ups);
            firmware.v_ups = firmware.v_ups(idx_fw_ups);

            % --- Case 2: Bypass + Weak Grid — grid disturbances reach PFCs ---
            V_base_scr = 480;
            P_base_scr = cfg.Load.P_facility;
            XR_scr = cfg.XR_grid;
            R_internal = cfg.R_internal;
            L_internal = cfg.L_internal;

            SCR_try = sort(options.SCR_sweep, 'ascend');
            out_bp = [];
            SCR_bypass = NaN;
            for jj = 1:numel(SCR_try)
                SCR_bypass = SCR_try(jj);
                Z_base_bp = V_base_scr^2 / (SCR_bypass * P_base_scr);
                X_bp = Z_base_bp * XR_scr / sqrt(1 + XR_scr^2);
                R_bp = X_bp / XR_scr;
                L_bp = X_bp / (2*pi*f_line);
                obj.configureBlocks(UPSMode="bypass", PFCGains=gains_healthy, ...
                    CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                    CableR=1e-3, CableL=1e-3, ...
                    RLC_R=max(R_bp - R_internal, 1e-4), RLC_L=max(L_bp - L_internal, 1e-7), ...
                    MaxStep=2e-3, StopTime=options.StopTime, ...
                    NoiseAmplitude=nomNoiseAmp);
                set_param(cfg.ModelName, 'LoadInitialState', 'off');
                try
                    out_bp = sim(cfg.ModelName);
                    break;
                catch ME
                    fprintf('Bypass SCR=%g diverged: %s\n', SCR_bypass, ME.message);
                end
            end
            if isempty(out_bp)
                error('StabilityStudy:bypassDiverged', ...
                    'Bypass simulation diverged at all SCR values: %s', mat2str(SCR_try));
            end
            bypass = extractAll(out_bp);
            bypass.SCR = SCR_bypass;

            dt_bp = mean(diff(bypass.t{1}));
            [f_fft_bp, P_fft_bp] = StabilityUtils.computeFFT(bypass.v{1}, dt_bp);
            [~, idx_bp] = max(P_fft_bp(2:end));
            bypass.f_osc = f_fft_bp(idx_bp + 1);

            % --- Case 3: SCR Sweep (UPS Connected, healthy PFCs) ---
            obj.configureBlocks(UPSMode="normal", PFCGains=gains_healthy, ...
                CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7, ...
                StopTime=options.StopTime, ...
                NoiseAmplitude=nomNoiseAmp);

            V_scale = V_nom;

            n_scr = numel(options.SCR_sweep);
            set_param(cfg.ModelName, 'LoadInitialState', 'off');
            out_scr = cell(1, n_scr);
            diverged = false(1, n_scr);
            scr_pfc = cell(1, n_scr);
            extractSCR = @(out) obj.extractPFCSignals(out, sp, cfg.n_pfc, options.AnalysisStart);
            for k = 1:n_scr
                Z_base_k = V_base_scr^2 / (options.SCR_sweep(k) * P_base_scr);
                X_k = Z_base_k * XR_scr / sqrt(1 + XR_scr^2);
                R_k = X_k / XR_scr;
                L_k = X_k / (2*pi*f_line);
                obj.configureBlocks(RLC_R=max(R_k - R_internal, 1e-4), ...
                    RLC_L=max(L_k - L_internal, 1e-7));
                try
                    out_scr{k} = sim(cfg.ModelName);
                    scr_pfc{k} = extractSCR(out_scr{k});
                    [t_ups_raw, v_ups_raw] = StabilityStudy.extractSimlog( ...
                        out_scr{k}.get('simlog'), sp.ups_vdc, 'V');
                    idx_ups_k = t_ups_raw > options.AnalysisStart;
                    scr_pfc{k}.t_ups = t_ups_raw(idx_ups_k);
                    scr_pfc{k}.v_ups = v_ups_raw(idx_ups_k);
                catch ME
                    fprintf('SCR=%g simulation diverged: %s\n', options.SCR_sweep(k), ME.message);
                    diverged(k) = true;
                end
            end
            V_pcc_rms = cell(1, n_scr);
            t_pcc = cell(1, n_scr);
            flicker_pct = zeros(1, n_scr);
            V_pcc_min = zeros(1, n_scr);
            V_pcc_max = zeros(1, n_scr);
            dV_pcc = zeros(1, n_scr);
            pfc_ripple_scr = zeros(n_scr, cfg.n_pfc);
            ups_ripple_scr = zeros(1, n_scr);
            for k = 1:n_scr
                if diverged(k)
                    V_pcc_rms{k} = NaN; t_pcc{k} = NaN;
                    V_pcc_max(k) = NaN; V_pcc_min(k) = NaN;
                    dV_pcc(k) = NaN; flicker_pct(k) = NaN;
                    pfc_ripple_scr(k,:) = NaN;
                    ups_ripple_scr(k) = NaN;
                    continue;
                end
                rms_k = out_scr{k}.get('simlog').Measurement_A.Measurements.PS_RMS_Estimator.O;
                t_k = rms_k.series.time;
                v_rms_pu = rms_k.series.values;
                idx_k = t_k > options.AnalysisStart;
                V_pcc_rms{k} = v_rms_pu(idx_k, 1) * V_scale;
                t_pcc{k} = t_k(idx_k);
                v_a = v_rms_pu(idx_k, 1);
                V_pcc_max(k) = max(v_a) * V_scale;
                V_pcc_min(k) = min(v_a) * V_scale;
                dV_pcc(k) = V_pcc_max(k) - V_pcc_min(k);
                flicker_pct(k) = (max(v_a) - min(v_a)) / mean(v_a) * 100;
                pfc_ripple_scr(k,:) = scr_pfc{k}.ripple;
                ups_ripple_scr(k) = max(scr_pfc{k}.v_ups) - min(scr_pfc{k}.v_ups);
            end

            status_flk = strings(n_scr, 1);
            for k = 1:n_scr
                if diverged(k), status_flk(k) = "DIVERGED";
                elseif V_pcc_min(k) < 0.8 * V_nom, status_flk(k) = "COLLAPSE";
                elseif flicker_pct(k) > 10, status_flk(k) = "SEVERE";
                elseif flicker_pct(k) > 5, status_flk(k) = "WARNING";
                elseif flicker_pct(k) > 3, status_flk(k) = "IEC LIMIT";
                else, status_flk(k) = "OK";
                end
            end

            ups_ripple_scr(status_flk == "COLLAPSE") = NaN;

            T_scr = table(options.SCR_sweep(:), dV_pcc(:), flicker_pct(:), ...
                V_pcc_min(:), V_pcc_max(:), ...
                pfc_ripple_scr(:,1), pfc_ripple_scr(:,2), pfc_ripple_scr(:,3), ...
                ups_ripple_scr(:), categorical(status_flk), ...
                VariableNames=["Grid SCR", "PCC Voltage Swing (V)", "PCC Flicker (%)", ...
                    "PCC Min (V)", "PCC Max (V)", ...
                    "PFC A Ripple Vpp (V)", "PFC B Ripple Vpp (V)", "PFC C Ripple Vpp (V)", ...
                    "UPS Ripple Vpp (V)", "Status"]);

            scr_sweep = struct('V_pcc_rms', {V_pcc_rms}, 't_pcc', {t_pcc}, ...
                'diverged', diverged, 'SCR', options.SCR_sweep, 'pfc', {scr_pfc});

            % --- Case 4: Degraded AFE — load fluctuations amplified on UPS DC bus ---
            % Run nominal-AFE baseline with healthy PFCs for comparison
            obj.configureBlocks(UPSMode="normal", PFCGains=gains_healthy, ...
                CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7, ...
                StopTime=options.StopTime, MaxStep=2e-3, ...
                NoiseAmplitude=nomNoiseAmp);
            set_param(cfg.ModelName, 'LoadInitialState', 'off');
            out_afe_nom = sim(cfg.ModelName);
            afe_nom = extractAll(out_afe_nom);
            [t_nom_raw, v_nom_raw] = StabilityStudy.extractSimlog( ...
                out_afe_nom.get('simlog'), sp.ups_vdc, 'V');
            idx_nom_f = t_nom_raw > options.AnalysisStart;
            afe_nom.t_ups = t_nom_raw(idx_nom_f);
            afe_nom.v_ups = v_nom_raw(idx_nom_f);

            % Run degraded-AFE with healthy PFCs
            obj.configureBlocks(UPSMode="normal", PFCGains=gains_healthy, ...
                CDc=cfg.Controller.C, GDamp=cfg.Controller.G_damp, ...
                CableR=1e-3, CableL=1e-3, RLC_R=1e-4, RLC_L=1e-7, ...
                AFEKp=options.AFE_degraded.Kp, AFEKi=options.AFE_degraded.Ki, ...
                StopTime=options.StopTime, MaxStep=2e-3, ...
                NoiseAmplitude=nomNoiseAmp);
            set_param(cfg.ModelName, 'LoadInitialState', 'off');
            out_afe = sim(cfg.ModelName);
            afe_deg = extractAll(out_afe);

            dt_afe = mean(diff(afe_deg.t{1}));
            [f_fft_afe, P_fft_afe] = StabilityUtils.computeFFT(afe_deg.v{1}, dt_afe);
            [~, idx_afe] = max(P_fft_afe(2:end));
            afe_deg.f_osc = f_fft_afe(idx_afe + 1);

            [t_deg_raw, v_deg_raw] = StabilityStudy.extractSimlog( ...
                out_afe.get('simlog'), sp.ups_vdc, 'V');
            idx_deg_f = t_deg_raw > options.AnalysisStart;
            afe_deg.t_ups = t_deg_raw(idx_deg_f);
            afe_deg.v_ups = v_deg_raw(idx_deg_f);

            t_ups_ss = max(options.AnalysisStart, options.StopTime - 2);
            idx_nom_ups = afe_nom.t_ups > t_ups_ss;
            idx_afe_ups = afe_deg.t_ups > t_ups_ss;
            ups_ripple_nom = max(afe_nom.v_ups(idx_nom_ups)) - min(afe_nom.v_ups(idx_nom_ups));
            ups_ripple_deg = max(afe_deg.v_ups(idx_afe_ups)) - min(afe_deg.v_ups(idx_afe_ups));
            ups_std_nom = std(afe_nom.v_ups(idx_nom_ups));
            ups_std_deg = std(afe_deg.v_ups(idx_afe_ups));

            C_ups = cfg.UPSController.C;
            bw_nom = StabilityStudy.afeBandwidth(cfg.AFEController.Kp, cfg.AFEController.Ki, C_ups);
            bw_deg = StabilityStudy.afeBandwidth(options.AFE_degraded.Kp, options.AFE_degraded.Ki, C_ups);

            status_afe = strings(2, 1);
            for jj = 1:2
                vpp = [ups_ripple_nom; ups_ripple_deg];
                if vpp(jj) > 40, status_afe(jj) = "SEVERE";
                elseif vpp(jj) > 10, status_afe(jj) = "WARNING";
                else, status_afe(jj) = "OK"; end
            end

            T_afe = table( ...
                categorical(["Nominal AFE"; "Degraded AFE"]), ...
                [cfg.AFEController.Kp; options.AFE_degraded.Kp], ...
                [cfg.AFEController.Ki; options.AFE_degraded.Ki], ...
                [ups_ripple_nom; ups_ripple_deg], ...
                [ups_std_nom; ups_std_deg], ...
                [bw_nom; bw_deg], ...
                categorical(status_afe), ...
                VariableNames=["AFE Controller", "AFE Kp (W/V)", "AFE Ki (W/(V*s))", ...
                    "UPS Ripple Vpp (V)", "UPS StdDev (V)", "Loop Bandwidth (Hz)", "Status"]);

            % Comparison table
            T_comparison = table( ...
                categorical(["Case 1: Firmware Bug"; "Case 2: Bypass+WeakGrid"; ...
                    "Case 4: Degraded AFE"]), ...
                [firmware.ripple(1); bypass.ripple(1); afe_deg.ripple(1)], ...
                [firmware.ripple(2); bypass.ripple(2); afe_deg.ripple(2)], ...
                [firmware.ripple(3); bypass.ripple(3); afe_deg.ripple(3)], ...
                [firmware.std_v(1); bypass.std_v(1); afe_deg.std_v(1)], ...
                [firmware.f_osc; bypass.f_osc; afe_deg.f_osc], ...
                VariableNames=["Failure Case", ...
                    "PFC A Ripple Vpp (V)", "PFC B Ripple Vpp (V)", "PFC C Ripple Vpp (V)", ...
                    "PFC A StdDev (V)", "Dominant Oscillation (Hz)"]);

            r.firmware = firmware;
            r.bypass = bypass;
            r.scr_sweep = scr_sweep;
            r.afe_nominal = afe_nom;
            r.afe_degraded = afe_deg;
            r.T_comparison = T_comparison;
            r.T_scr = T_scr;
            r.T_afe = T_afe;
            r.V_op = V_op;
            r.V_nom = V_nom;
            r.V_ups = V_ups;
            r.StopTime = options.StopTime;
            r.AnalysisStart = options.AnalysisStart;
            r.BuggyIndex = bi;
            r.BuggyGains = options.BuggyGains;
            r.AFE_degraded = options.AFE_degraded;
            r.pal = pal;

            obj.UPSBypassDemo = r;

            if options.Plot, obj.plotUPSBypassDemo(); end
        end

        function runAll(obj, options)
            %RUNALL Execute all analysis scenarios in sequence.
            arguments
                obj
                options.Plot    (1,1) logical = true
                options.Force   (1,1) logical = false
            end
            if options.Force || isempty(fieldnames(obj.Setup)),          obj.runSetup(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.Baseline)),       obj.runBaseline(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.FirmwareBug)),    obj.runFirmwareBug(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.WeakGrid)),       obj.runWeakGrid(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.UPSIsolation)),   obj.runUPSIsolation(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.AFEDegradation)), obj.runAFEDegradation(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.StabilityMap)),   obj.runStabilityMap(Plot=options.Plot); end
            if options.Force || isempty(fieldnames(obj.ImpedanceScan)),  obj.runImpedanceScan(Plot=options.Plot); end
        end

        function plotSetup(obj)
            %PLOTSETUP Plot closed-loop impedance magnitude and phase.
            r = obj.Setup;
            pal = obj.Pal;

            figure('Position', [100 100 900 400])
            tiledlayout(1,2, 'TileSpacing', 'compact', 'Padding', 'compact')

            f_crit = [0.5 3];
            patch_color = [1 0.90 0.90];

            ax1 = nexttile;
            hZ1 = semilogx(r.f_bode, 20*log10(abs(r.Z_cl)), 'Color', pal.blue, 'LineWidth', 1.8); hold on
            hZb1 = semilogx(r.f_bode, 20*log10(abs(r.Z_cl_buggy)), '-', 'Color', pal.orange, 'LineWidth', 1.5);
            hRes1 = xline(r.f_res, '--', 'Color', pal.red, 'LineWidth', 1.2);
            yl1 = ylim(ax1);
            hp1 = patch(ax1, 'XData', [f_crit(1) f_crit(2) f_crit(2) f_crit(1)], ...
                'YData', [yl1(1) yl1(1) yl1(2) yl1(2)], ...
                'FaceColor', patch_color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
            uistack(hp1, 'bottom')
            legend(ax1, [hZ1, hZb1, hRes1, hp1], ...
                {sprintf('Nominal (K_p = %d)', obj.Cfg.Controller.Kp), ...
                 sprintf('Buggy (K_p = %d)', r.Kp_b), ...
                 sprintf('f_{res} = %.2f Hz', r.f_res), ...
                 'CPL critical band'}, ...
                'Location', 'southwest', 'FontSize', 7)
            xlabel('Frequency (Hz)'); ylabel('|Z_{cl}| (dB)')
            title('Closed-Loop Impedance: Load \rightarrow V_{dc}')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim(r.FreqRange)

            ax2 = nexttile;
            hZ2 = semilogx(r.f_bode, rad2deg(angle(r.Z_cl)), 'Color', pal.blue, 'LineWidth', 1.8); hold on
            hZb2 = semilogx(r.f_bode, rad2deg(angle(r.Z_cl_buggy)), '-', 'Color', pal.orange, 'LineWidth', 1.5);
            hRes2 = xline(r.f_res, '--', 'Color', pal.red, 'LineWidth', 1.2);
            yline(0, ':', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            yl2 = ylim(ax2);
            hp2 = patch(ax2, 'XData', [f_crit(1) f_crit(2) f_crit(2) f_crit(1)], ...
                'YData', [yl2(1) yl2(1) yl2(2) yl2(2)], ...
                'FaceColor', patch_color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
            uistack(hp2, 'bottom')
            legend(ax2, [hZ2, hZb2, hRes2, hp2], ...
                {sprintf('Nominal (K_p = %d)', obj.Cfg.Controller.Kp), ...
                 sprintf('Buggy (K_p = %d)', r.Kp_b), ...
                 sprintf('f_{res} = %.2f Hz', r.f_res), ...
                 'CPL critical band'}, ...
                'Location', 'southwest', 'FontSize', 7)
            xlabel('Frequency (Hz)'); ylabel('Phase (deg)')
            title('Phase of Z_{cl}')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim(r.FreqRange)
        end
        function plotBaseline(obj)
            %PLOTBASELINE Eight-panel overview of nominal PFC and UPS operation.
            r = obj.Baseline;
            pal = obj.Pal;
            V_op = r.V_op;
            V_ups = r.V_ups;
            t = r.t;
            t_ups = r.t_ups;
            v_pfc0 = r.v_pfc(:,1);
            v_pfc1 = r.v_pfc(:,2);
            v_pfc2 = r.v_pfc(:,3);
            v_ups_dc = r.v_ups;
            t_rms = r.t_rms;
            I_rms0 = r.I_rms0;
            I_rms1 = r.I_rms1;
            t_ss = r.t_ss;
            ss = r.ss;
            dt = r.dt;

            ds = max(1, floor(numel(t)/15000));
            idx = 1:ds:numel(t);
            ds_ups = max(1, floor(numel(t_ups)/15000));
            idx_ups = 1:ds_ups:numel(t_ups);
            v_err0 = v_pfc0 - V_op;

            figure('Position', [40 40 1600 1000], 'Color', 'w', 'Name', 'DC Stability — Baseline');
            set(gcf, 'Position', [100 50 1100 900])
            tl = tiledlayout(4, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
            title(tl, 'DataCenterStability — Healthy Baseline', 'FontSize', 14, 'FontWeight', 'bold');

            nexttile;
            StabilityStudy.drawBands(gca, [t_ss t(end)], StabilityStudy.getBands("pfc", pal, V_dc=V_op));
            hold on
            plot(t(idx), v_pfc0(idx), 'Color', pal.blue, 'LineWidth', 1.2);
            plot(t(idx), v_pfc1(idx), 'Color', pal.green, 'LineWidth', 1.0);
            plot(t(idx), v_pfc2(idx), 'Color', pal.orange, 'LineWidth', 1.0);
            yline(V_op, '--', 'V_{ref}', 'Color', pal.grey, 'LineWidth', 0.8, 'LabelHorizontalAlignment', 'left');
            ylabel('V_{dc} (V)'); title('PFC DC Bus Voltage');
            legend({'PFC A', 'PFC B', 'PFC C'}, 'Location', 'northeastoutside');
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel', []);

            nexttile;
            StabilityStudy.drawBands(gca, [t_ss t_ups(end)], StabilityStudy.getBands("ups", pal, V_ups=V_ups));
            hold on
            plot(t_ups(idx_ups), v_ups_dc(idx_ups), 'Color', pal.purple, 'LineWidth', 1.2);
            yline(V_ups, '--', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8, 'LabelHorizontalAlignment', 'left');
            ylabel('V_{dc} (V)'); title('UPS DC Bus (800V)');
            xlim([t_ss t_ups(end)]); grid on; set(gca, 'XTickLabel', []);

            nexttile;
            plot(t_rms, I_rms0, 'Color', pal.red, 'LineWidth', 1.2);
            ylabel('I_{rms} (A)'); title('PFC A AC Current (RMS)');
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel', []);

            nexttile;
            plot(t_rms, I_rms1, 'Color', pal.ltblue, 'LineWidth', 1.2);
            ylabel('I_{rms} (A)'); title('PFC B AC Current');
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel', []);

            nexttile;
            plot(t(idx), v_err0(idx), 'Color', pal.grey, 'LineWidth', 0.8);
            yline(0, '-', 'Color', 'k', 'LineWidth', 0.5);
            ylabel('\DeltaV (V)'); title('PFC A Voltage Error');
            xlabel('Time (s)'); xlim([t_ss t(end)]); grid on;

            nexttile;
            v_spread = max(r.v_pfc, [], 2) - min(r.v_pfc, [], 2);
            plot(t(idx), v_spread(idx), 'Color', pal.orange, 'LineWidth', 1.2);
            ylabel('\DeltaV_{spread} (V)'); title('Voltage Spread Across PFCs');
            xlabel('Time (s)'); xlim([t_ss t(end)]); grid on;

            nexttile;
            v_ss = v_pfc0(ss) - mean(v_pfc0(ss));
            N_fft = 2^floor(log2(min(numel(v_ss), 65536)));
            f_spec = (0:N_fft/2-1) / (N_fft * dt);
            Y = abs(fft(v_ss(1:N_fft))) / N_fft * 2;
            Y = Y(1:N_fft/2);
            stem(f_spec(f_spec < 20), Y(f_spec < 20), 'filled', 'Color', pal.blue, 'MarkerSize', 3, 'LineWidth', 0.8);
            xlabel('Frequency (Hz)'); ylabel('|V_{dc} ripple| (V)');
            title('DC Bus Spectrum (PFC A)'); grid on; xlim([0 20]);

            nexttile;
            histogram(v_pfc0(ss), 60, 'FaceColor', pal.blue, 'EdgeColor', 'none', 'FaceAlpha', 0.6); hold on
            histogram(v_pfc1(ss), 60, 'FaceColor', pal.green, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
            xline(V_op, '--', 'V_{ref}', 'Color', pal.red, 'LineWidth', 1.2);
            xline(V_op*0.95, ':', '-5%', 'Color', pal.grey); xline(V_op*1.05, ':', '+5%', 'Color', pal.grey);
            xlabel('V_{dc} (V)'); ylabel('Count');
            title('Voltage Distribution'); grid on;
            legend({'PFC A', 'PFC B'}, 'Location', 'northeastoutside');
        end
        function plotFirmwareBug(obj)
            %PLOTFIRMWAREBUG Voltage waveforms, FFT, and impedance for buggy PFC.
            r = obj.FirmwareBug;
            pal = obj.Pal;
            V_op = obj.Cfg.OperatingPoint.V_dc;
            t = r.t;
            v0 = r.v0;
            t_ss = r.AnalysisStart;

            figure('Position', [100 100 900 550])
            tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            StabilityStudy.drawBands(ax1, [t_ss r.StopTime], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax1, 'on')
            plot(ax1, t, v0, 'Color', pal.red, 'LineWidth', 1.2, 'DisplayName', 'PFC A (degraded)')
            pfcLetters = 'BC';
            for k = 1:numel(r.v_others)
                plot(ax1, t, r.v_others{k}, 'Color', pal.blue, ...
                    'LineWidth', 1.0, 'DisplayName', sprintf('PFC %c', pfcLetters(k)))
            end
            yline(V_op, ':', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            ylabel('V_{dc} (V)'); title('DC Bus Voltage — Firmware Bug (Resonance from Load Profile)')
            xlim(ax1, [t_ss r.StopTime])
            legend('Location', 'northeast'); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax2 = nexttile;
            hold(ax2, 'on')
            plot(ax2, t, v0 - V_op, 'Color', pal.red, 'LineWidth', 1.2)
            yline(0, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            xlabel('Time (s)'); ylabel('Voltage Error (V)')
            title('Voltage Error — Load Steps Excite Underdamped PFC Resonance'); xlim(ax2, [t_ss r.StopTime])
            set(gca, 'XGrid', 'on', 'YGrid', 'on')

            mask_f = r.f_fft < 20;
            figure('Position', [100 100 700 350])
            hold on
            h_stem = stem(r.f_fft(mask_f), r.P_fft(mask_f), 'filled', 'MarkerSize', 3, 'LineWidth', 1.2);
            h_stem.Color = pal.blue; h_stem.MarkerFaceColor = pal.blue;
            xline(r.f_osc, '--', sprintf('f_{osc} = %.2f Hz', r.f_osc), 'Color', pal.red, 'LineWidth', 1.2)
            xlabel('Frequency (Hz)'); ylabel('Amplitude (V)')
            title('FFT of DC Bus Voltage (Buggy PFC)')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([0 20])

            figure('Position', [100 100 900 400])
            tiledlayout(1,2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax5 = nexttile;
            StabilityStudy.drawBands(ax5, [0.01 1000], StabilityStudy.getBands("gain", pal))
            hold(ax5, 'on')
            semilogx(ax5, r.FreqExcite, 20*log10(r.Z_cl_excite), '-o', 'Color', pal.blue, ...
                'LineWidth', 1.5, 'MarkerFaceColor', pal.blue, 'MarkerSize', 5)
            xline(r.f_res, '--', sprintf('f_{res}=%.2f Hz', r.f_res), 'Color', pal.red, 'LineWidth', 1.2)
            xlabel('Frequency (Hz)'); ylabel('|Z_{cl}| (dB)')
            title('Closed-Loop Impedance at Excitation Frequencies')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([0.01 1000])

            ax6 = nexttile;
            hold(ax6, 'on')
            semilogx(ax6, r.FreqExcite, r.V_ripple_pred, '-s', 'Color', pal.red, ...
                'LineWidth', 1.5, 'MarkerFaceColor', pal.red, 'MarkerSize', 5)
            xline(r.f_res, '--', sprintf('f_{res}=%.2f Hz', r.f_res), 'Color', pal.red, 'LineWidth', 1.2)
            xlabel('Frequency (Hz)'); ylabel('Predicted V_{ripple} (V)')
            title(sprintf('Voltage Ripple from %g W Power Virus', r.VirusPower))
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([0.01 1000])
        end
        function plotWeakGrid(obj)
            %PLOTWEAKGRID Admittance, loop gain, Nyquist, PCC, and amplification plots.
            r = obj.WeakGrid;
            pal = obj.Pal;
            colors_scr = {pal.red, pal.orange, [0.75 0.60 0.10], pal.green};

            figure('Position', [100 100 1000 400])
            tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            fill(ax1, [0.01 r.f_tau r.f_tau 0.01], [-30 -30 10 10], pal.red, ...
                'FaceAlpha', 0.04, 'EdgeColor', 'none', 'HandleVisibility', 'off')
            hold(ax1, 'on')
            fill(ax1, [r.f_tau 1000 1000 r.f_tau], [-30 -30 10 10], pal.green, ...
                'FaceAlpha', 0.04, 'EdgeColor', 'none', 'HandleVisibility', 'off')
            semilogx(ax1, r.f_grid, 20*log10(abs(r.Y_pfc_dyn)), 'Color', pal.blue, 'LineWidth', 1.8)
            xline(ax1, r.f_tau, '--', sprintf('f_{\\tau}=%.1f Hz', r.f_tau), 'Color', pal.red, 'LineWidth', 1.0)
            xlabel(ax1, 'Frequency (Hz)'); ylabel(ax1, '|Y_{pfc}| (dB S)')
            title(ax1, 'PFC Input Admittance — Magnitude')
            set(ax1, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax1, [0.01 1000])

            ax2 = nexttile;
            bandsPhase = struct('lo', {-90, 90}, 'hi', {90, 180}, ...
                'color', {pal.green, pal.red}, 'alpha', {0.06, 0.04});
            StabilityStudy.drawBands(ax2, [0.01 1000], bandsPhase)
            semilogx(ax2, r.f_grid, rad2deg(angle(r.Y_pfc_dyn)), 'Color', pal.blue, 'LineWidth', 1.8)
            hold(ax2, 'on')
            xline(ax2, r.f_tau, '--', 'Color', pal.red, 'LineWidth', 1.0)
            yline(ax2, 0, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            xlabel(ax2, 'Frequency (Hz)'); ylabel(ax2, 'Phase (deg)')
            title(ax2, 'PFC Input Admittance — Phase')
            set(ax2, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax2, [0.01 1000]); ylim(ax2, [-180 180])

            figure('Position', [100 100 1000 400])
            tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            StabilityStudy.drawBands(ax1, [0.01 1000], struct('lo', {-80, 0}, 'hi', {0, 20}, ...
                'color', {pal.green, pal.red}, 'alpha', {0.08, 0.06}))
            hold(ax1, 'on')
            for k = 1:numel(r.SCR_sweep)
                semilogx(ax1, r.f_grid, 20*log10(abs(r.T_all{k})), 'Color', colors_scr{k}, 'LineWidth', 1.8)
            end
            yline(ax1, 0, '--', '0 dB', 'Color', pal.grey, 'LineWidth', 1.0)
            xlabel(ax1, 'Frequency (Hz)'); ylabel(ax1, '|T| (dB)')
            title(ax1, 'Middlebrook Loop Gain — Magnitude')
            scr_labels = arrayfun(@(x) sprintf('SCR=%.1g', x), ...
                r.SCR_sweep, 'UniformOutput', false);
            legend(ax1, scr_labels, 'Location', 'northeastoutside')
            set(ax1, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax1, [0.01 1000])

            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [0.01 1000], struct('lo', {-120, -180}, 'hi', {-180, -270}, ...
                'color', {pal.orange, pal.red}, 'alpha', {0.06, 0.06}))
            hold(ax2, 'on')
            for k = 1:numel(r.SCR_sweep)
                semilogx(ax2, r.f_grid, rad2deg(angle(r.T_all{k})), 'Color', colors_scr{k}, 'LineWidth', 1.8)
            end
            yline(ax2, -180, '--', '-180\circ', 'Color', pal.grey, 'LineWidth', 1.0)
            xlabel(ax2, 'Frequency (Hz)'); ylabel(ax2, 'Phase (deg)')
            title(ax2, 'Middlebrook Loop Gain — Phase')
            legend(ax2, scr_labels, 'Location', 'northeastoutside')
            set(ax2, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax2, [0.01 1000])

            figure('Position', [100 100 600 500])
            hold on
            theta_circ = linspace(0, 2*pi, 200);
            plot(cos(theta_circ), sin(theta_circ), '--', 'Color', pal.grey, 'LineWidth', 0.8)
            for k = 1:numel(r.SCR_sweep)
                plot(real(r.T_all{k}), imag(r.T_all{k}), 'Color', colors_scr{k}, 'LineWidth', 1.5)
            end
            plot(-1, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2)
            xlabel('Real'); ylabel('Imaginary')
            title('Nyquist: Z_{grid} \cdot Y_{pfc}')
            legend([arrayfun(@(x) sprintf('SCR=%.1g', x), r.SCR_sweep, 'UniformOutput', false), ...
                {'Unit circle', 'Critical (-1,0)'}], 'Location', 'northeastoutside')
            set(gca, 'XGrid', 'on', 'YGrid', 'on')
            max_T = max(cellfun(@(t) max(abs(t)), r.T_all));
            lim = min(max_T * 1.1, 50);
            xlim([-lim lim]); ylim([-lim lim])
            axis equal

            if isfield(r, 'V_pcc_3ph')
                V_nom = r.V_nom;
                n_scr = numel(r.t_pcc);
                phase_labels = {'Phase A', 'Phase B', 'Phase C'};
                scr_legend = arrayfun(@(x) sprintf('SCR=%.1g', x), [10, 3, 2], 'UniformOutput', false);

                figure('Position', [100 100 1200 900])
                tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

                for ph = 1:3
                    ax = nexttile(ph*2-1);
                    StabilityStudy.drawBands(ax, [r.AnalysisStart r.StopTime], ...
                        StabilityStudy.getBands("pcc", pal, V_nom=V_nom))
                    hold(ax, 'on')
                    for k = 1:n_scr
                        if r.diverged(k), continue; end
                        plot(ax, r.t_pcc{k}, r.V_pcc_3ph{k}(:,ph), ...
                            'Color', colors_scr{k}, 'LineWidth', 1.8)
                    end
                    yline(ax, V_nom, ':', sprintf('V_{nom}=%dV', V_nom), 'Color', pal.grey, 'LineWidth', 0.8)
                    ylabel(ax, 'V_{RMS} (V)')
                    title(ax, [phase_labels{ph} ' — RMS Voltage'])
                    set(ax, 'XGrid', 'on', 'YGrid', 'on')
                    xlim(ax, [r.AnalysisStart r.StopTime])
                    if ph == 1, legend(ax, scr_legend(~r.diverged), 'Location', 'northeastoutside'); end
                    if ph == 3, xlabel(ax, 'Time (s)'); end

                    ax = nexttile(ph*2);
                    hold(ax, 'on')
                    for k = 1:n_scr
                        if r.diverged(k), continue; end
                        plot(ax, r.t_pcc{k}, r.I_pcc_3ph{k}(:,ph), ...
                            'Color', colors_scr{k}, 'LineWidth', 1.8)
                    end
                    ylabel(ax, 'I_{RMS} (A)')
                    title(ax, [phase_labels{ph} ' — RMS Current'])
                    set(ax, 'XGrid', 'on', 'YGrid', 'on')
                    xlim(ax, [r.AnalysisStart r.StopTime])
                    if ph == 1, legend(ax, scr_legend(~r.diverged), 'Location', 'northeastoutside'); end
                    if ph == 3, xlabel(ax, 'Time (s)'); end
                end
                sgtitle('PCC Voltage & Current per Phase — SCR Sweep')
            end

            colors_n = {pal.blue, pal.green, pal.orange, pal.red};

            figure('Position', [100 100 1000 400])
            tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax2 = nexttile;
            bands = StabilityStudy.getBands("amplification", pal);
            StabilityStudy.drawBands(ax2, [min(r.SCR_fine) max(r.SCR_fine)], bands)
            hold(ax2, 'on')
            plot(ax2, r.SCR_fine, r.amplification, 'Color', pal.red, 'LineWidth', 1.8)
            yline(ax2, 1, ':', 'No amplification', 'Color', pal.grey, 'LineWidth', 0.8)
            yline(ax2, 2, '--', '2\times (6 dB)', 'Color', pal.blue, 'LineWidth', 1.0)
            xlabel(ax2, 'SCR'); ylabel(ax2, 'Amplification Factor')
            title(ax2, sprintf('Grid Amplification (f_{osc}=%.1f Hz)', r.f_osc))
            set(ax2, 'XGrid', 'on', 'YGrid', 'on')
            xlim(ax2, [min(r.SCR_fine) max(r.SCR_fine)])

            ax3 = nexttile;
            StabilityStudy.drawBands(ax3, [min(r.SCR_fine) max(r.SCR_fine)], bands)
            hold(ax3, 'on')
            for k = 1:numel(r.N_dc)
                amp_n = StabilityUtils.computeAmplification( ...
                    r.SCR_fine, r.f_osc, r.V_base_grid, ...
                    r.P_base_grid, r.XR_grid, r.Y_at_fosc, r.N_dc(k));
                plot(ax3, r.SCR_fine, amp_n, 'Color', colors_n{k}, 'LineWidth', 1.8)
            end
            yline(ax3, 1, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            yline(ax3, 5, '--', 'Severe', 'Color', pal.red, 'LineWidth', 1.0)
            xlabel(ax3, 'SCR'); ylabel(ax3, 'Amplification Factor')
            title(ax3, 'Multiple DCs on Shared Feeder')
            n_labels = arrayfun(@(x) sprintf('N=%d', x), ...
                r.N_dc, 'UniformOutput', false);
            legend(ax3, n_labels, 'Location', 'northeastoutside')
            set(ax3, 'XGrid', 'on', 'YGrid', 'on')
            xlim(ax3, [min(r.SCR_fine) max(r.SCR_fine)]); ylim(ax3, [0 10])
        end
        function plotUPSIsolation(obj)
            %PLOTUPSISOLATION Grid isolation and UPS resonance comparison plots.
            r = obj.UPSIsolation;
            pal = obj.Pal;
            V_op = r.V_op;
            V_ups = r.V_ups;

            figure('Position', [100 100 900 550])
            tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            StabilityStudy.drawBands(ax1, [r.AnalysisStart r.StopTime], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax1, 'on')
            plot(ax1, r.t_strong, r.v_pfc0_strong, 'Color', pal.blue, 'LineWidth', 1.8)
            plot(ax1, r.t_weak, r.v_pfc0_weak, '--', 'Color', pal.red, 'LineWidth', 1.2)
            yline(V_op, ':', 'V_{ref}', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('PFC V_{dc} (V)'); title('PFC DC Bus — Grid Strength Has NO Effect (UPS Isolated)')
            legend('Strong grid', sprintf('Extreme weak (SCR=%.1f)', r.SCR_extreme), 'Location', 'northeastoutside')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([r.AnalysisStart r.StopTime])

            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [r.AnalysisStart r.StopTime], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
            hold(ax2, 'on')
            plot(ax2, r.t_strong, r.v_ups_strong, 'Color', pal.blue, 'LineWidth', 1.8)
            plot(ax2, r.t_weak, r.v_ups_weak, '--', 'Color', pal.red, 'LineWidth', 1.2)
            yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('UPS V_{dc} (V)'); xlabel('Time (s)')
            title('UPS DC Bus — Slight Perturbation but Stable')
            legend('Strong grid', sprintf('SCR=%.1f', r.SCR_extreme), 'Location', 'northeastoutside')
            set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([r.AnalysisStart r.StopTime])

            figure('Position', [100 100 900 400])
            tiledlayout(1,1); ax = nexttile;
            StabilityStudy.drawBands(ax, [r.AnalysisStart-1 r.StopTime], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax, 'on')
            plot(ax, r.t_fws, r.v_fws, 'Color', pal.blue, 'LineWidth', 1.8)
            plot(ax, r.t_fww, r.v_fww, '--', 'Color', pal.red, 'LineWidth', 1.2)
            ylabel('PFC V_{dc} (V)'); xlabel('Time (s)')
            title('Firmware Bug: Identical at Extreme SCR vs Strong Grid')
            legend('Strong grid', sprintf('SCR=%.1f', r.SCR_extreme), 'Location', 'northeastoutside')
            set(ax, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax, [r.AnalysisStart-1 r.StopTime])

            figure('Position', [100 100 900 400])
            tiledlayout(1,1); ax = nexttile;
            StabilityStudy.drawBands(ax, [0.01 100], StabilityStudy.getBands("gain", pal))
            hold(ax, 'on')
            semilogx(ax, r.f_bode_ups, 20*log10(abs(r.Z_cl_ups_nom)), 'Color', pal.blue, 'LineWidth', 1.8)
            semilogx(ax, r.f_bode_ups, 20*log10(abs(r.Z_cl_ups_res)), 'Color', pal.red, 'LineWidth', 1.8)
            xline(ax, r.f_n_ups, ':', sprintf('f_n=%.2f Hz', r.f_n_ups), 'Color', pal.blue)
            xline(ax, r.f_n_ups_res, ':', sprintf('f_n=%.1f Hz', r.f_n_ups_res), 'Color', pal.red)
            xline(ax, r.f_osc, '--', sprintf('f_{osc}=%.2f Hz', r.f_osc), 'Color', pal.grey)
            xlabel('Frequency (Hz)'); ylabel('|Z_{cl,UPS}| (dB)')
            title('UPS DC Bus Impedance: Load \rightarrow Voltage Ripple')
            legend(sprintf('Nominal C=%.2f F (f_n=%.2f Hz)', r.C_ups_nom, r.f_n_ups), ...
                sprintf('Undersized C=%.2f F (f_n=%.1f Hz)', ...
                r.C_ups_res, r.f_n_ups_res), ...
                'Location', 'northeastoutside')
            set(ax, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax, [0.01 100])

            if ~isempty(r.t_un)
                figure('Position', [100 100 900 550])
                tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact')

                ax1 = nexttile;
                StabilityStudy.drawBands(ax1, [1 r.StopTimeRes], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
                hold(ax1, 'on')
                plot(ax1, r.t_un, r.v_ups_nom_t, 'Color', pal.blue, 'LineWidth', 1.8)
                if ~isempty(r.t_ur)
                    plot(ax1, r.t_ur, r.v_ups_res_t, 'Color', pal.red, 'LineWidth', 1.8)
                end
                yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey)
                ylabel('UPS V_{dc} (V)')
                title('UPS 800V DC Bus — Resonance with Undersized Capacitor + Degraded AFE')
                legend(sprintf('Nominal C=%.2f F', r.C_ups_nom), ...
                    sprintf('C=%.2f F, AFE Kp=%.1f Ki=%.0f', r.C_ups_res, r.AFEDegradedRes.Kp, r.AFEDegradedRes.Ki), ...
                    'Location', 'northeastoutside')
                set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([1 r.StopTimeRes2])

                ax2 = nexttile;
                StabilityStudy.drawBands(ax2, [1 r.StopTimeRes], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
                hold(ax2, 'on')
                plot(ax2, r.t_un, r.v_pfc0_nom_t, 'Color', pal.blue, 'LineWidth', 1.8)
                if ~isempty(r.t_ur)
                    plot(ax2, r.t_ur, r.v_pfc0_res_t, 'Color', pal.red, 'LineWidth', 1.8)
                end
                yline(V_op, ':', 'V_{ref}', 'Color', pal.grey)
                ylabel('PFC V_{dc} (V)'); xlabel('Time (s)')
                title('PFC DC Bus — Effect of UPS Resonance on Downstream Loads')
                legend(sprintf('Nominal C=%.2f F', r.C_ups_nom), ...
                    sprintf('C=%.2f F, AFE Kp=%.1f Ki=%.0f', r.C_ups_res, r.AFEDegradedRes.Kp, r.AFEDegradedRes.Ki), ...
                    'Location', 'northeastoutside')
                set(gca, 'XGrid', 'on', 'YGrid', 'on'); xlim([1 r.StopTimeRes2])
            end
        end
        function plotAFEDegradation(obj)
            %PLOTAFEDEGRADATION AFE loop gain, sensitivity, and ripple bar charts.
            r = obj.AFEDegradation;
            pal = obj.Pal;
            AFE_cases = r.AFE_cases;
            n_cases = numel(AFE_cases);
            colors_G = r.colors_G;
            V_ups = r.V_ups;
            V_op = r.V_op;
            sp = r.sp;
            pfc0_path = r.pfc0_path;

            figure('Position', [100 100 1200 450])
            tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            bandsLoop = struct('lo',{0,-40},'hi',{120,0},'color',{pal.green,pal.red},'alpha',{0.06,0.06});
            StabilityStudy.drawBands(ax1, [0.01 100], bandsLoop)
            hold(ax1, 'on')
            for k = 1:n_cases
                semilogx(ax1, r.f_analysis, 20*log10(abs(r.L_all{k})), 'Color', colors_G{k}, 'LineWidth', 1.8)
            end
            xline(ax1, r.f_osc, '--', sprintf('f_{bug}=%.1f Hz', r.f_osc), 'Color', pal.grey, 'LineWidth', 1.0)
            yline(ax1, 0, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            xlabel('Frequency (Hz)'); ylabel('|L(f)| (dB)')
            title('AFE Loop Gain — Degradation Reduces Rejection')
            legend(ax1, {AFE_cases.label}, 'Location', 'southwest')
            set(ax1, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax1, [0.01 100])

            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [0.01 100], StabilityStudy.getBands("sensitivity", pal))
            hold(ax2, 'on')
            for k = 1:n_cases
                semilogx(ax2, r.f_analysis, 20*log10(abs(r.S_all{k})), 'Color', colors_G{k}, 'LineWidth', 1.8)
            end
            xline(ax2, r.f_osc, '--', sprintf('f_{bug}=%.1f Hz', r.f_osc), 'Color', pal.grey, 'LineWidth', 1.0)
            yline(ax2, 0, ':', '0 dB (no rejection)', 'Color', pal.grey, 'LineWidth', 0.8)
            xlabel('Frequency (Hz)'); ylabel('|S(f)| (dB)')
            title('Sensitivity — Oscillation Reaching DC Bus')
            legend(ax2, {AFE_cases.label}, 'Location', 'southeast')
            set(ax2, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax2, [0.01 100]); ylim(ax2, [-100 10])

            figure('Position', [100 100 1000 600])
            tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax1 = nexttile;
            StabilityStudy.drawBands(ax1, [1 r.StopTime], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
            hold(ax1, 'on')
            for k = 1:n_cases
                [t_k, v_k] = StabilityStudy.extractSimlog(r.out_G{k}.simlog, sp.ups_vdc, 'V');
                plot(ax1, t_k, v_k, 'Color', colors_G{k}, 'LineWidth', 1.8)
            end
            yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('UPS V_{dc} (V)')
            title('UPS DC Bus — AFE Degradation Exposes PFC Oscillation')
            legend(ax1, {AFE_cases.label}, 'Location', 'northeastoutside')
            set(ax1, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax1, [r.AnalysisStart r.StopTime])

            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [r.AnalysisStart r.StopTime], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax2, 'on')
            for k = 1:n_cases
                [t_k, v_k] = StabilityStudy.extractSimlog(r.out_G{k}.simlog, pfc0_path, 'V');
                plot(ax2, t_k, v_k, 'Color', colors_G{k}, 'LineWidth', 1.8)
            end
            yline(V_op, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('PFC V_{dc} (V)'); xlabel('Time (s)')
            title('PFC DC Bus — Oscillation Invariant to UPS Controller State')
            legend(ax2, {AFE_cases.label}, 'Location', 'northeastoutside')
            set(ax2, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax2, [r.AnalysisStart r.StopTime])

            figure('Position', [100 100 800 350])
            yyaxis left
            bar(categorical({AFE_cases.label}), r.ups_ripple, 'FaceColor', pal.blue)
            ylabel('UPS DC Bus Ripple (V pk-pk)')
            yyaxis right
            plot(1:n_cases, r.pfc_ripple, '-o', 'Color', pal.red, 'LineWidth', 1.8, 'MarkerFaceColor', pal.red)
            ylabel('PFC Ripple (V pk-pk)')
            title('UPS vs PFC Ripple — AFE Degradation Only Affects UPS Bus')
            set(gca, 'XGrid', 'on', 'YGrid', 'on')

            if isfield(r, 'rip_nom_scr3') && ~isnan(r.rip_nom_scr3)
                figure('Position', [100 100 1100 400])
                tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

                ax1 = nexttile;
                StabilityStudy.drawBands(ax1, [r.AnalysisStart r.StopTime], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
                hold(ax1, 'on')
                plot(ax1, r.t_nom3, r.v_ups_nom3, 'Color', pal.blue, 'LineWidth', 1.8)
                plot(ax1, r.t_deg3, r.v_ups_deg3, 'Color', pal.red, 'LineWidth', 1.8)
                yline(V_ups, ':', 'Color', pal.grey, 'LineWidth', 0.8)
                ylabel('UPS V_{dc} (V)'); xlabel('Time (s)')
                title(sprintf('UPS DC Bus — Nominal vs Degraded AFE (SCR=%d)', r.SCR_grid_test))
                legend('Nominal AFE', 'Severe degradation', 'Location', 'northeastoutside')
                set(ax1, 'XGrid', 'on', 'YGrid', 'on'); xlim(ax1, [r.AnalysisStart r.StopTime])

                ax2 = nexttile;
                bar(ax2, categorical({'Nominal AFE','Degraded AFE'}), [r.rip_nom_scr3, r.rip_deg_scr3], ...
                    'FaceColor', 'flat', 'CData', [pal.blue; pal.red])
                ylabel('UPS DC Bus Ripple (V pk-pk)')
                title(sprintf('Ripple Comparison at SCR=%d', r.SCR_grid_test))
                set(ax2, 'XGrid', 'on', 'YGrid', 'on')
            end
        end
        function plotStabilityMap(obj)
            %PLOTSTABILITYMAP Damping ratio vs Kp with nominal and buggy operating points.
            r = obj.StabilityMap;
            pal = obj.Pal;

            figure('Position', [100 100 550 400]);

            plot(r.Kp_sweep, r.zeta_sweep, 'Color', pal.blue, 'LineWidth', 2, ...
                'DisplayName', sprintf('\\zeta(K_p),  K_i = %d', r.Ki)); hold on;
            yline(0, 'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'HandleVisibility', 'off');
            xline(r.Kp_crit, '--', 'Color', pal.grey, 'LineWidth', 1.2, 'HandleVisibility', 'off');
            fill([r.KpRange(1) r.Kp_crit r.Kp_crit r.KpRange(1)], [-0.5 -0.5 0 0], ...
                pal.red, 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(r.KpNominal, r.zeta_nominal, 'o', 'Color', pal.blue, ...
                'MarkerFaceColor', pal.blue, 'MarkerSize', 10, ...
                'DisplayName', sprintf('Nominal: K_p=%d, \\zeta=%.2f', r.KpNominal, r.zeta_nominal));
            plot(r.KpBuggy, r.zeta_buggy, 'o', 'Color', pal.red, ...
                'MarkerFaceColor', pal.red, 'MarkerSize', 10, ...
                'DisplayName', sprintf('Buggy: K_p=%d, \\zeta=%.2f', r.KpBuggy, r.zeta_buggy));
            text(r.Kp_crit, -0.25, sprintf('  K_{p,crit} = %d', r.Kp_crit), ...
                'FontSize', 9, 'Color', pal.grey);
            text(5, 0.03, 'UNSTABLE (\zeta < 0)', 'FontSize', 9, 'Color', pal.red);
            xlabel('K_p (W/V)'); ylabel('\zeta');
            title('Stability Map — Damping Ratio vs Proportional Gain');
            legend('Location', 'northwest'); grid on;
            ylim([-0.3 1.5]); xlim(r.KpRange);
        end
        function plotImpedanceScan(obj)
            %PLOTIMPEDANCESCAN Penetration curve, Bode, and Nyquist plots.
            r = obj.ImpedanceScan;
            f = r.FreqHz;
            w_vec = r.w_vec;
            scenarios = r.scenarios;

            figure('Position', [100 100 800 400]);
            yyaxis left
            plot(r.fractions*100, r.min_dist, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
            ylabel('Min Distance to -1');
            yline(r.MarginThreshold, 'b--', sprintf('Margin threshold = %.1f', r.MarginThreshold), ...
                'LineWidth', 1, 'HandleVisibility', 'off', 'LabelHorizontalAlignment', 'left');
            yline(0, 'r--', 'LineWidth', 1, 'HandleVisibility', 'off');
            yyaxis right
            plot(r.fractions*100, r.encirclements, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 4);
            ylabel('Encirclements of -1');
            if ~isnan(r.frac_marginal)
                xline(r.frac_marginal*100, 'b:', sprintf('Marginal %.0f%%', r.frac_marginal*100), ...
                    'LineWidth', 1.2, 'HandleVisibility', 'off');
            end
            if ~isnan(r.frac_critical)
                xline(r.frac_critical*100, 'r:', sprintf('Unstable %.0f%%', r.frac_critical*100), ...
                    'LineWidth', 1.2, 'HandleVisibility', 'off');
            end
            xlabel('PFC Units with Degraded Firmware (%)');
            title('DC Bus Stability vs. Firmware Degradation Penetration');
            subtitle(sprintf('Kp_{nominal}=%d, Kp_{degraded}=%d, P_{total}=%.0f MW, V_{dc}=%d V', ...
                r.Kp_h, r.Kp_b, r.P_total/1e6, r.V));
            grid on; xlim([0 100]);

            figure('Position', [100 100 1000 550]);
            tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

            ax1 = nexttile; hold(ax1, 'on');
            ax2 = nexttile; hold(ax2, 'on');
            for i = 1:numel(scenarios)
                [mag_i, ph_i] = bode(r.L_systems{i}, w_vec);
                mag_i = squeeze(mag_i); ph_i = squeeze(ph_i);
                semilogx(ax1, f, 20*log10(mag_i), 'Color', scenarios(i).color, ...
                    'LineWidth', 1.5, 'DisplayName', scenarios(i).label);
                semilogx(ax2, f, ph_i, 'Color', scenarios(i).color, 'LineWidth', 1.5);
            end
            yline(ax1, 0, 'k--', 'LineWidth', 1);
            ylabel(ax1, '|L| (dB)'); title(ax1, 'Return Ratio L(s) = Z_{source} \cdot P_{load}/V^2');
            legend(ax1, 'Location', 'northeast'); grid(ax1, 'on'); xlim(ax1, [0.01 50]);
            yline(ax2, -180, 'k--', 'LineWidth', 1);
            ylabel(ax2, 'Phase (deg)'); xlabel(ax2, 'Frequency (Hz)');
            grid(ax2, 'on'); xlim(ax2, [0.01 50]);

            figure('Position', [100 100 1000 450]);
            nsc = numel(scenarios);
            tiledlayout(1, nsc, 'TileSpacing', 'compact', 'Padding', 'compact');
            for i = 1:nsc
                nexttile;
                nyquist(r.L_systems{i}, w_vec);
                hold on; plot(-1, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
                [~, idx_match] = min(abs(r.fractions - scenarios(i).frac));
                if r.encirclements(idx_match) ~= 0
                    status_str = sprintf('Unstable (N=%d)', r.encirclements(idx_match));
                elseif r.min_dist(idx_match) < r.MarginThreshold
                    status_str = sprintf('Marginal (d=%.2f)', r.min_dist(idx_match));
                else
                    status_str = sprintf('Stable (d=%.2f)', r.min_dist(idx_match));
                end
                title(sprintf('%s\n%s', scenarios(i).label, status_str), 'FontSize', 9);
            end
        end

        function plotUPSBypassDemo(obj)
            %PLOTUPSBYPASSDEMO Dashboard for four-case stability study.
            r = obj.UPSBypassDemo;
            pal = r.pal;
            V_op = r.V_op;
            V_nom = r.V_nom;
            V_ups = r.V_ups;
            ts = r.AnalysisStart;
            te = r.StopTime;
            bi = r.BuggyIndex;
            pfcL = 'ABC';
            pfcColors = {pal.red, pal.blue, pal.green};

            % ===== Figure 1: Case 1 — Firmware Bug (8-panel) =====
            figure('Position', [50 50 1200 900])
            sgtitle(sprintf('Case 1: Firmware Bug (Kp=%d) — Forced Resonance Under Workload Fluctuation', ...
                r.BuggyGains.Kp), 'FontWeight', 'bold')
            tiledlayout(4,2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax = nexttile;
            StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax, 'on')
            for k = 1:numel(r.firmware.t)
                plot(ax, r.firmware.t{k}, r.firmware.v{k}, 'Color', pfcColors{k}, 'LineWidth', 1.2, ...
                    'DisplayName', sprintf('PFC %c', pfcL(k)))
            end
            yline(V_op, ':', 'V_{ref}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            ylabel('V_{dc} (V)'); title('PFC DC Bus Voltage')
            legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            mask_f = r.firmware.f_fft < 20;
            hold(ax, 'on')
            stem(ax, r.firmware.f_fft(mask_f), r.firmware.P_fft(mask_f), 'filled', ...
                'MarkerSize', 3, 'LineWidth', 1.2, 'Color', pal.red)
            xline(r.firmware.f_osc, '--', sprintf('f_{osc}=%.2f Hz', r.firmware.f_osc), 'Color', pal.red)
            if ~isempty(fieldnames(obj.Setup))
                xline(obj.Setup.f_n_buggy, ':', sprintf('f_{n,pred}=%.2f Hz', obj.Setup.f_n_buggy), 'Color', pal.blue)
            end
            xlabel('Frequency (Hz)'); ylabel('Amplitude (V)')
            title(sprintf('DC Bus Spectrum (PFC %c)', pfcL(bi))); xlim([0 20])
            set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            plot(ax, r.firmware.t_rms{1}, r.firmware.I_rms{1}, 'Color', pfcColors{1}, 'LineWidth', 1.2)
            ylabel('I_{rms} (A)'); title(sprintf('PFC %c AC Current (RMS)', pfcL(1)))
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            plot(ax, r.firmware.t_rms{2}, r.firmware.I_rms{2}, 'Color', pfcColors{2}, 'LineWidth', 1.2)
            ylabel('I_{rms} (A)'); title(sprintf('PFC %c AC Current (RMS)', pfcL(2)))
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            plot(ax, r.firmware.t_rms{3}, r.firmware.I_rms{3}, 'Color', pfcColors{3}, 'LineWidth', 1.2)
            ylabel('I_{rms} (A)'); xlabel('Time (s)')
            title(sprintf('PFC %c AC Current (RMS)', pfcL(3)))
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            hold(ax, 'on')
            plot(ax, r.firmware.t{bi}, r.firmware.v{bi} - V_op, 'Color', pal.grey, 'LineWidth', 0.8)
            yline(0, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('\DeltaV (V)'); xlabel('Time (s)')
            title(sprintf('PFC %c Voltage Error', pfcL(bi)))
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
            hold(ax, 'on')
            plot(ax, r.firmware.t_ups, r.firmware.v_ups, 'Color', pal.purple, 'LineWidth', 1.2)
            yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('V_{dc} (V)'); title('UPS DC Bus (Nominal AFE)')
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            hold(ax, 'on')
            histogram(ax, r.firmware.v{bi}(r.firmware.t{bi} > ts), 50, ...
                'FaceColor', pal.red, 'FaceAlpha', 0.6, 'EdgeColor', 'none')
            xline(V_op, 'r--', 'V_{ref}', 'LineWidth', 1.2)
            xline(V_op*0.95, ':', '-5%', 'Color', pal.grey)
            xline(V_op*1.05, ':', '+5%', 'Color', pal.grey)
            xlabel('V_{dc} (V)'); ylabel('Count')
            title(sprintf('PFC %c Voltage Distribution', pfcL(bi)))

            % ===== Figure 2: Case 2 — Bypass + Weak Grid (8-panel) =====
            figure('Position', [80 80 1200 900])
            sgtitle(sprintf('Case 2: UPS Bypassed + Weak Grid (SCR=%g) — Grid Noise Reaches PFCs', ...
                r.bypass.SCR), 'FontWeight', 'bold')
            tiledlayout(4,2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax = nexttile;
            StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax, 'on')
            for k = 1:numel(r.bypass.t)
                plot(ax, r.bypass.t{k}, r.bypass.v{k}, 'Color', pfcColors{k}, 'LineWidth', 1.2, ...
                    'DisplayName', sprintf('PFC %c', pfcL(k)))
            end
            yline(V_op, ':', 'V_{ref}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            ylabel('V_{dc} (V)'); title('PFC DC Bus Voltage')
            legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            v_all_bp = [r.bypass.v{1}, r.bypass.v{2}, r.bypass.v{3}];
            v_spread_bp = max(v_all_bp, [], 2) - min(v_all_bp, [], 2);
            plot(ax, r.bypass.t{1}, v_spread_bp, 'Color', pal.orange, 'LineWidth', 1.2)
            ylabel('\DeltaV_{spread} (V)'); title('Voltage Spread Across PFCs')
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            for k = 1:3
                ax = nexttile;
                plot(ax, r.bypass.t_rms{k}, r.bypass.I_rms{k}, 'Color', pfcColors{k}, 'LineWidth', 1.2)
                ylabel('I_{rms} (A)'); title(sprintf('PFC %c AC Current (RMS)', pfcL(k)))
                if k == 3, xlabel('Time (s)'); end
                xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')
            end

            ax = nexttile;
            hold(ax, 'on')
            plot(ax, r.bypass.t{1}, r.bypass.v{1} - V_op, 'Color', pal.grey, 'LineWidth', 0.8)
            yline(0, ':', 'Color', pal.grey, 'LineWidth', 0.8)
            ylabel('\DeltaV (V)'); xlabel('Time (s)')
            title('PFC A Voltage Error')
            xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            X = categorical({'PFC A', 'PFC B', 'PFC C'});
            X = reordercats(X, {'PFC A', 'PFC B', 'PFC C'});
            bh = bar(ax, X, [r.firmware.ripple(:), r.bypass.ripple(:)]);
            bh(1).FaceColor = pal.red; bh(2).FaceColor = pal.orange;
            ylabel('Ripple V_{pp} (V)'); title('Ripple: Bug vs Bypass+WeakGrid')
            legend('Case 1: FW Bug', 'Case 2: Bypass+WG', 'Location', 'northeast')
            set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            hold(ax, 'on')
            histogram(ax, r.bypass.v{1}(r.bypass.t{1} > ts), 50, ...
                'FaceColor', pal.orange, 'FaceAlpha', 0.6, 'EdgeColor', 'none')
            xline(V_op, '--', 'V_{ref}', 'Color', pal.red, 'LineWidth', 1.2)
            xline(V_op*0.95, ':', '-5%', 'Color', pal.grey)
            xline(V_op*1.05, ':', '+5%', 'Color', pal.grey)
            xlabel('V_{dc} (V)'); ylabel('Count')
            title('PFC A Voltage Distribution (Bypass)')

            % ===== Figure 3: Case 3 — SCR Sweep (3x2 dashboard) =====
            if ~all(r.scr_sweep.diverged)
                figure('Position', [110 110 1200 900])
                sgtitle('Case 3: SCR Sweep — Impact on PFC, PCC, and UPS DC Bus', 'FontWeight', 'bold')
                tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact')
                colors_scr = {pal.blue, pal.green, pal.red};
                valid_k = find(~r.scr_sweep.diverged);
                [~, sortIdx] = sort(r.scr_sweep.SCR(valid_k), 'ascend');
                valid_k = valid_k(sortIdx);
                scr_labels = arrayfun(@(x) sprintf('SCR=%g',x), r.scr_sweep.SCR(valid_k), 'UniformOutput', false);

                ax = nexttile;
                StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
                hold(ax, 'on')
                for k = valid_k
                    cidx = min(k, numel(colors_scr));
                    plot(ax, r.scr_sweep.pfc{k}.t{1}, r.scr_sweep.pfc{k}.v{1}, ...
                        'Color', colors_scr{cidx}, 'LineWidth', 1.2, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                end
                yline(V_op, ':', 'V_{ref}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                ylabel('V_{dc} (V)'); title('PFC A DC Bus Voltage')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
                hold(ax, 'on')
                for k = valid_k
                    cidx = min(k, numel(colors_scr));
                    plot(ax, r.scr_sweep.pfc{k}.t{2}, r.scr_sweep.pfc{k}.v{2}, ...
                        'Color', colors_scr{cidx}, 'LineWidth', 1.2, 'HandleVisibility', 'off')
                    plot(ax, r.scr_sweep.pfc{k}.t{3}, r.scr_sweep.pfc{k}.v{3}, ...
                        'Color', colors_scr{cidx}, 'LineWidth', 0.8, 'LineStyle', '--', 'HandleVisibility', 'off')
                end
                yline(V_op, ':', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                ylabel('V_{dc} (V)'); title('PFC B (solid) + C (dashed) DC Bus')
                xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pcc", pal, V_nom=V_nom))
                hold(ax, 'on')
                yline(V_nom, ':', 'V_{nom}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                for k = valid_k
                    cidx = min(k, numel(colors_scr));
                    plot(ax, r.scr_sweep.t_pcc{k}, r.scr_sweep.V_pcc_rms{k}, ...
                        'Color', colors_scr{cidx}, 'LineWidth', 1.5, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                end
                ylabel('PCC V_{rms} (V)'); title('PCC Voltage (Phase A)')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
                hold(ax, 'on')
                yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                for k = valid_k
                    cidx = min(k, numel(colors_scr));
                    plot(ax, r.scr_sweep.pfc{k}.t_ups, r.scr_sweep.pfc{k}.v_ups, ...
                        'Color', colors_scr{cidx}, 'LineWidth', 1.2, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                end
                ylabel('V_{dc} (V)'); title('UPS DC Bus Voltage')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                ripple_mat = zeros(numel(valid_k), 3);
                for j = 1:numel(valid_k)
                    ripple_mat(j,:) = r.scr_sweep.pfc{valid_k(j)}.ripple;
                end
                scr_cats = reordercats(categorical(scr_labels), scr_labels);
                bh = bar(ax, scr_cats, ripple_mat);
                bh(1).FaceColor = pfcColors{1}; bh(2).FaceColor = pfcColors{2}; bh(3).FaceColor = pfcColors{3};
                ylabel('Ripple V_{pp} (V)'); title('PFC DC Bus Ripple per SCR')
                legend('PFC A', 'PFC B', 'PFC C', 'Location', 'northeast')
                set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                t_ss_start = max(ts, te - 2);
                pfc_rip_valid = zeros(1, numel(valid_k));
                ups_rip_valid = zeros(1, numel(valid_k));
                flk_valid = zeros(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    kk = valid_k(j);
                    idx_pfc_ss = r.scr_sweep.pfc{kk}.t{1} > t_ss_start;
                    pfc_rip_valid(j) = max(r.scr_sweep.pfc{kk}.v{1}(idx_pfc_ss)) - min(r.scr_sweep.pfc{kk}.v{1}(idx_pfc_ss));
                    idx_ups_ss = r.scr_sweep.pfc{kk}.t_ups > t_ss_start;
                    ups_rip_valid(j) = max(r.scr_sweep.pfc{kk}.v_ups(idx_ups_ss)) - min(r.scr_sweep.pfc{kk}.v_ups(idx_ups_ss));
                    flk_valid(j) = r.T_scr.("PCC Flicker (%)")(kk);
                end
                yyaxis(ax, 'left')
                bar_h = bar(ax, scr_cats, [pfc_rip_valid; ups_rip_valid]');
                bar_h(1).FaceColor = pal.blue; bar_h(1).FaceAlpha = 0.7;
                bar_h(2).FaceColor = pal.purple; bar_h(2).FaceAlpha = 0.7;
                ylabel('Ripple V_{pp} (V)')
                yyaxis(ax, 'right')
                plot(ax, scr_cats, flk_valid, 'o-', 'Color', pal.orange, ...
                    'LineWidth', 1.8, 'MarkerFaceColor', pal.orange, 'MarkerSize', 8)
                ylabel('PCC Flicker (%)')
                legend('PFC A Ripple', 'UPS Ripple', 'PCC Flicker', 'Location', 'northeast')
                title('PFC / UPS Ripple & PCC Flicker per SCR')
                set(gca, 'XGrid', 'on', 'YGrid', 'on')

                % ===== SCR Impact on All Buses (Healthy PFC) =====
                figBuses = figure('Position', [160 160 1400 700]);
                sgtitle('SCR Impact on All Buses — Healthy PFC (No Firmware Bug)', 'FontWeight', 'bold')
                tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact')
                zoomXlim = [te - 1.5, te - 0.5];
                clrs_z = cell(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    clrs_z{j} = colors_scr{min(j,numel(colors_scr))};
                end

                axPCC = nexttile;
                StabilityStudy.drawBands(axPCC, [ts te], StabilityStudy.getBands("pcc", pal))
                hold(axPCC, 'on')
                tZ_pcc = cell(1, numel(valid_k)); vZ_pcc = cell(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    k = valid_k(j);
                    plot(axPCC, r.scr_sweep.t_pcc{k}, r.scr_sweep.V_pcc_rms{k}, ...
                        'Color', colors_scr{min(j,numel(colors_scr))}, 'LineWidth', 1.5, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                    tZ_pcc{j} = r.scr_sweep.t_pcc{k};
                    vZ_pcc{j} = r.scr_sweep.V_pcc_rms{k};
                end
                ylabel('PCC V_{rms} (V)'); title('PCC Voltage (Phase A)')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                axPFC = nexttile;
                StabilityStudy.drawBands(axPFC, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
                hold(axPFC, 'on')
                tZ_pfc = cell(1, numel(valid_k)); vZ_pfc = cell(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    k = valid_k(j);
                    plot(axPFC, r.scr_sweep.pfc{k}.t{1}, r.scr_sweep.pfc{k}.v{1}, ...
                        'Color', colors_scr{min(j,numel(colors_scr))}, 'LineWidth', 1.5, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                    tZ_pfc{j} = r.scr_sweep.pfc{k}.t{1};
                    vZ_pfc{j} = r.scr_sweep.pfc{k}.v{1};
                end
                yline(V_op, ':', 'V_{op}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                ylabel('V_{dc} (V)'); title('PFC A DC Bus Voltage')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                axUPS = nexttile;
                StabilityStudy.drawBands(axUPS, [ts te], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
                hold(axUPS, 'on')
                tZ_ups = cell(1, numel(valid_k)); vZ_ups = cell(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    k = valid_k(j);
                    plot(axUPS, r.scr_sweep.pfc{k}.t_ups, r.scr_sweep.pfc{k}.v_ups, ...
                        'Color', colors_scr{min(j,numel(colors_scr))}, 'LineWidth', 1.5, ...
                        'DisplayName', sprintf('SCR = %g', r.scr_sweep.SCR(k)))
                    tZ_ups{j} = r.scr_sweep.pfc{k}.t_ups;
                    vZ_ups{j} = r.scr_sweep.pfc{k}.v_ups;
                end
                yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
                ylabel('V_{dc} (V)'); title('UPS DC Bus Voltage')
                legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

                ax = nexttile;
                pcc_dV = zeros(1, numel(valid_k));
                pfc_dV = zeros(1, numel(valid_k));
                ups_dV = zeros(1, numel(valid_k));
                for j = 1:numel(valid_k)
                    kk = valid_k(j);
                    idx_pcc_ss = r.scr_sweep.t_pcc{kk} > t_ss_start;
                    v_pcc_ss = r.scr_sweep.V_pcc_rms{kk}(idx_pcc_ss);
                    pcc_dV(j) = max(v_pcc_ss) - min(v_pcc_ss);
                    idx_pfc_ss2 = r.scr_sweep.pfc{kk}.t{1} > t_ss_start;
                    pfc_dV(j) = max(r.scr_sweep.pfc{kk}.v{1}(idx_pfc_ss2)) - min(r.scr_sweep.pfc{kk}.v{1}(idx_pfc_ss2));
                    idx_ups_ss2 = r.scr_sweep.pfc{kk}.t_ups > t_ss_start;
                    ups_dV(j) = max(r.scr_sweep.pfc{kk}.v_ups(idx_ups_ss2)) - min(r.scr_sweep.pfc{kk}.v_ups(idx_ups_ss2));
                end
                bar_data = [pcc_dV; pfc_dV; ups_dV]';
                bh = bar(ax, scr_cats, bar_data);
                bh(1).FaceColor = pal.orange; bh(1).FaceAlpha = 0.8;
                bh(2).FaceColor = pal.blue;   bh(2).FaceAlpha = 0.8;
                bh(3).FaceColor = pal.purple;  bh(3).FaceAlpha = 0.8;
                ylabel('Voltage Swing V_{pp} (V)')
                legend('PCC \DeltaV', 'PFC A Ripple', 'UPS Ripple', 'Location', 'northeast')
                title('Voltage Swing at Each Bus vs SCR')
                set(gca, 'XGrid', 'on', 'YGrid', 'on')

                drawnow;
                StabilityStudy.addZoomInset(axPCC, tZ_pcc, vZ_pcc, clrs_z, zoomXlim, 'br');
                StabilityStudy.addZoomInset(axPFC, tZ_pfc, vZ_pfc, clrs_z, zoomXlim, 'bl');
                StabilityStudy.addZoomInset(axUPS, tZ_ups, vZ_ups, clrs_z, zoomXlim, 'tr');
            end

            % ===== Figure 4: Case 4 — Degraded AFE (2x2 with FFT) =====
            figure('Position', [140 140 1200 700])
            sgtitle(sprintf('Case 4: Degraded AFE (Kp=%g, Ki=%g) — Load Fluctuations Amplified on UPS DC Bus', ...
                r.AFE_degraded.Kp, r.AFE_degraded.Ki), 'FontWeight', 'bold')
            tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact')

            ax = nexttile;
            StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("ups", pal, V_ups=V_ups))
            hold(ax, 'on')
            plot(ax, r.afe_nominal.t_ups, r.afe_nominal.v_ups, 'Color', pal.blue, 'LineWidth', 1.2, ...
                'DisplayName', 'Nominal AFE')
            plot(ax, r.afe_degraded.t_ups, r.afe_degraded.v_ups, 'Color', pal.red, 'LineWidth', 1.2, ...
                'DisplayName', 'Degraded AFE')
            yline(V_ups, ':', 'V_{ref,UPS}', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            ylabel('V_{dc} (V)'); title('UPS DC Bus — AFE Degradation Amplifies Ripple')
            legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            StabilityStudy.drawBands(ax, [ts te], StabilityStudy.getBands("pfc", pal, V_dc=V_op))
            hold(ax, 'on')
            plot(ax, r.afe_nominal.t{bi}, r.afe_nominal.v{bi}, 'Color', pal.blue, 'LineWidth', 1.0, ...
                'DisplayName', 'Nominal AFE')
            plot(ax, r.afe_degraded.t{bi}, r.afe_degraded.v{bi}, 'Color', pal.red, 'LineWidth', 1.0, ...
                'DisplayName', 'Degraded AFE')
            yline(V_op, ':', 'Color', pal.grey, 'LineWidth', 0.8, 'HandleVisibility', 'off')
            ylabel('V_{dc} (V)'); title(sprintf('PFC %c DC Bus — Nominal vs Degraded AFE', pfcL(bi)))
            legend('Location', 'northeast'); xlim([ts te]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            t_ss_fft = max(ts, r.StopTime - 2);
            idx_an = r.afe_nominal.t_ups > t_ss_fft;
            idx_af = r.afe_degraded.t_ups > t_ss_fft;
            dt_ups_nom = mean(diff(r.afe_nominal.t_ups(idx_an)));
            dt_ups_deg = mean(diff(r.afe_degraded.t_ups(idx_af)));
            [f_ups_nom, P_ups_nom] = StabilityUtils.computeFFT( ...
                r.afe_nominal.v_ups(idx_an) - mean(r.afe_nominal.v_ups(idx_an)), dt_ups_nom);
            [f_ups_deg, P_ups_deg] = StabilityUtils.computeFFT( ...
                r.afe_degraded.v_ups(idx_af) - mean(r.afe_degraded.v_ups(idx_af)), dt_ups_deg);
            mask_fn = f_ups_nom < 20; mask_fd = f_ups_deg < 20;
            hold(ax, 'on')
            stem(ax, f_ups_nom(mask_fn), P_ups_nom(mask_fn), 'filled', 'MarkerSize', 3, ...
                'LineWidth', 1.0, 'Color', pal.blue, 'DisplayName', 'Nominal AFE')
            stem(ax, f_ups_deg(mask_fd), P_ups_deg(mask_fd), 'filled', 'MarkerSize', 3, ...
                'LineWidth', 1.0, 'Color', pal.red, 'DisplayName', 'Degraded AFE')
            xlabel('Frequency (Hz)'); ylabel('Amplitude (V)')
            title('UPS DC Bus Spectrum — Degraded AFE Amplifies Load Noise')
            legend('Location', 'northeast'); xlim([0 10]); set(gca, 'XGrid', 'on', 'YGrid', 'on')

            ax = nexttile;
            t_ss_bar = max(ts, r.StopTime - 2);
            idx_an_ss = r.afe_nominal.t_ups > t_ss_bar;
            idx_af_ss = r.afe_degraded.t_ups > t_ss_bar;
            rip_nom = max(r.afe_nominal.v_ups(idx_an_ss)) - min(r.afe_nominal.v_ups(idx_an_ss));
            rip_deg = max(r.afe_degraded.v_ups(idx_af_ss)) - min(r.afe_degraded.v_ups(idx_af_ss));
            cats = categorical({'Nominal AFE', 'Degraded AFE'});
            cats = reordercats(cats, {'Nominal AFE', 'Degraded AFE'});
            bh = bar(ax, cats, [rip_nom; rip_deg]);
            bh.FaceColor = 'flat';
            bh.CData = [pal.blue; pal.red];
            ylabel('Ripple V_{pp} (V)'); title('UPS DC Bus Ripple — Nominal vs Degraded AFE')
            set(gca, 'XGrid', 'on', 'YGrid', 'on')
        end

    end

    %% ===================== PRIVATE HELPERS =====================
    methods (Access = private)

        function initOperatingPoint(obj)
            %INITOPERATINGPOINT Load saved Simscape OP, or run warmup to capture one.
            cfg = obj.Cfg;
            mdl = char(cfg.ModelName);

            opFile = fullfile(fileparts(which(mdl)), [mdl '_SteadyStateOP.mat']);
            if isfile(opFile)
                tmp = load(opFile, 'op');
                assignin('base', 'ssOP__', tmp.op);
                set_param(mdl, 'SimscapeUseOperatingPoints', 'on');
                set_param(mdl, 'SimscapeOperatingPoint', 'ssOP__');
                return
            end

            capBlk = [mdl '/UPS/DC-Link/C1'];
            origVcPriority  = get_param(capBlk, 'vc_priority');
            origRLC_R       = get_param(cfg.RLCBlock, 'R');
            origRLC_L       = get_param(cfg.RLCBlock, 'L');
            origStopTime    = get_param(mdl, 'StopTime');
            origLogType     = get_param(mdl, 'SimscapeLogType');
            origLogDecim    = get_param(mdl, 'SimscapeLogDecimation');

            set_param(capBlk, 'vc_priority', 'High');
            set_param(cfg.RLCBlock, 'R', '1e-4', 'L', '1e-7');
            set_param(mdl, 'StopTime', '3');
            set_param(mdl, 'SimscapeLogType', 'all');
            set_param(mdl, 'SimscapeLogDecimation', 50);
            set_param(mdl, 'SimscapeLogLimitData', 'off');
            set_param(mdl, 'ReturnWorkspaceOutputs', 'on');
            set_param(mdl, 'LoadInitialState', 'off');
            set_param(mdl, 'SimscapeUseOperatingPoints', 'off');

            out_warmup = sim(mdl);
            op = simscape.op.create(out_warmup.simlog, 3.0);
            assignin('base', 'ssOP__', op);
            save(opFile, 'op');
            set_param(mdl, 'SimscapeUseOperatingPoints', 'on');
            set_param(mdl, 'SimscapeOperatingPoint', 'ssOP__');

            set_param(capBlk, 'vc_priority', origVcPriority);
            set_param(cfg.RLCBlock, 'R', origRLC_R, 'L', origRLC_L);
            set_param(mdl, 'StopTime', origStopTime);
            set_param(mdl, 'SimscapeLogType', origLogType);
            set_param(mdl, 'SimscapeLogDecimation', origLogDecim);
        end

        function s = extractPFCSignals(obj, out, sp, n_pfc, t_start)
            %EXTRACTPFCSIGNALS Extract voltages, currents, and RMS envelopes for all PFCs.
            [t_v, v] = deal(cell(1, n_pfc));
            [t_i, i_ac] = deal(cell(1, n_pfc));
            ripple = zeros(1, n_pfc);
            std_v = zeros(1, n_pfc);
            mean_irms = zeros(1, n_pfc);
            t_rms_all = cell(1, n_pfc);
            I_rms_all = cell(1, n_pfc);
            for k = 1:n_pfc
                [t_v_raw, v_raw] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_vdc{k}, 'V');
                [t_i_raw, i_ac_raw] = StabilityStudy.extractSimlog(out.simlog, sp.pfc_iac{k}, 'A');
                idx = t_v_raw > t_start;
                t_v{k} = t_v_raw(idx);
                v{k} = v_raw(idx);
                ripple(k) = max(v{k}) - min(v{k});
                std_v(k) = std(v{k});
                idx_i = t_i_raw > t_start;
                t_i{k} = t_i_raw(idx_i);
                i_ac{k} = i_ac_raw(idx_i);
                dt_k = mean(diff(t_i{k}));
                win = max(round(1/(2*60*dt_k)), 50);
                n_wins = floor(numel(i_ac{k})/win);
                t_rms_k = zeros(n_wins, 1);
                I_rms_k = zeros(n_wins, 1);
                for jj = 1:n_wins
                    rng = (jj-1)*win+1 : jj*win;
                    t_rms_k(jj) = mean(t_i{k}(rng));
                    I_rms_k(jj) = sqrt(mean(i_ac{k}(rng).^2));
                end
                t_rms_all{k} = t_rms_k;
                I_rms_all{k} = I_rms_k;
                idx_rms = t_rms_k > t_start;
                mean_irms(k) = mean(I_rms_k(idx_rms));
            end
            s.t = t_v;
            s.v = v;
            s.t_i = t_i;
            s.i_ac = i_ac;
            s.t_rms = t_rms_all;
            s.I_rms = I_rms_all;
            s.ripple = ripple;
            s.std_v = std_v;
            s.mean_irms = mean_irms;
        end

    end

    %% ===================== STATIC METHODS =====================
    methods (Static)

        function pal = setupGroot()
            %SETUPGROOT Configure figure defaults and return color palette struct.
            set(groot, ...
                'DefaultAxesFontSize', 11, ...
                'DefaultAxesFontName', 'Segoe UI', ...
                'DefaultAxesLabelFontSizeMultiplier', 1.1, ...
                'DefaultAxesTitleFontSizeMultiplier', 1.15, ...
                'DefaultAxesTitleFontWeight', 'bold', ...
                'DefaultAxesLineWidth', 0.8, ...
                'DefaultAxesGridAlpha', 0.15, ...
                'DefaultAxesGridLineStyle', '-', ...
                'DefaultAxesBox', 'off', ...
                'DefaultLineLineWidth', 1.5, ...
                'DefaultFigureColor', 'w', ...
                'DefaultFigureRenderer', 'painters', ...
                'DefaultLegendLocation', 'northeastoutside', ...
                'DefaultLegendFontSize', 9);

            pal.blue    = [0.00 0.45 0.74];
            pal.red     = [0.80 0.20 0.15];
            pal.green   = [0.20 0.62 0.17];
            pal.orange  = [0.90 0.55 0.10];
            pal.purple  = [0.55 0.25 0.68];
            pal.grey    = [0.50 0.50 0.50];
            pal.ltblue  = [0.30 0.68 0.92];
        end

        function [t, vals] = extractSimlog(simlog, path, unit)
            %EXTRACTSIMLOG Extract time and values from Simscape simulation log.
            parts = strsplit(path, '.');
            node = simlog;
            for k = 1:numel(parts)
                node = node.(parts{k});
            end
            t = node.series.time;
            vals = node.series.values(unit);
        end

        function drawBands(ax, xlims, bands)
            %DRAWBANDS Fill colored bands on axes for threshold visualization.
            hold(ax, 'on')
            for k = 1:numel(bands)
                fill(ax, [xlims(1) xlims(2) xlims(2) xlims(1)], ...
                    [bands(k).lo bands(k).lo bands(k).hi bands(k).hi], ...
                    bands(k).color, 'FaceAlpha', bands(k).alpha, 'EdgeColor', 'none', ...
                    'HandleVisibility', 'off')
            end
        end

        function bands = getBands(type, pal, options)
            %GETBANDS Return threshold band definitions for a given plot type.
            arguments
                type    (1,1) string {mustBeMember(type, ...
                    ["pfc","ups","gain","pcc","amplification","sensitivity","loopgain"])}
                pal     (1,1) struct
                options.V_dc  (1,1) double = 400
                options.V_ups (1,1) double = 800
                options.V_nom (1,1) double = 277
            end

            switch type
                case "pfc"
                    c = options.V_dc;
                    tol = 0.03 * c;
                    bands = struct( ...
                        'lo',    {c-tol, c-3*tol, c+tol, c-5*tol, c+3*tol}, ...
                        'hi',    {c+tol, c-tol, c+3*tol, c-3*tol, c+5*tol}, ...
                        'color', {pal.green, pal.orange, pal.orange, pal.red, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06, 0.06, 0.06});
                case "ups"
                    c = options.V_ups;
                    bands = struct( ...
                        'lo',    {c-10, c-50, c-200}, ...
                        'hi',    {c+10, c-10, c-150}, ...
                        'color', {pal.green, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06});
                case "gain"
                    bands = struct( ...
                        'lo',    {-80, 0, 10}, ...
                        'hi',    {0, 10, 30}, ...
                        'color', {pal.green, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06});
                case "pcc"
                    v = options.V_nom;
                    bands = struct( ...
                        'lo',    {v*0.95, v*0.90, v*1.05, v*0.72}, ...
                        'hi',    {v*1.05, v*0.95, v*1.10, v*0.90}, ...
                        'color', {pal.green, pal.orange, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06, 0.06});
                case "amplification"
                    bands = struct( ...
                        'lo',    {0, 1, 3}, ...
                        'hi',    {1, 3, 10}, ...
                        'color', {pal.green, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06});
                case "sensitivity"
                    bands = struct( ...
                        'lo',    {-100, -40, -6}, ...
                        'hi',    {-40, -6, 10}, ...
                        'color', {pal.green, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06});
                case "loopgain"
                    bands = struct( ...
                        'lo',    {-80, 0, 6}, ...
                        'hi',    {0, 6, 30}, ...
                        'color', {pal.green, pal.orange, pal.red}, ...
                        'alpha', {0.08, 0.06, 0.06});
            end
        end

    end

    %% ===================== PRIVATE STATIC =====================
    methods (Static, Access = private)

        function bw = afeBandwidth(Kp, Ki, C_ups)
            f = logspace(-2, 3, 5000);
            s_vec = 1j * 2 * pi * f;
            T = (Kp + Ki ./ s_vec) ./ (C_ups .* s_vec);
            S = abs(1 ./ (1 + T));
            idx = find(S >= 1/sqrt(2), 1, 'first');
            if isempty(idx), bw = f(end); else, bw = f(idx); end
        end

        function addZoomInset(parentAx, tData, vData, colors, zoomXlim, insetPos)
            fig = ancestor(parentAx, 'figure');
            axPos = getpixelposition(parentAx, true);
            figPos = getpixelposition(fig);
            normAx = axPos ./ [figPos(3) figPos(4) figPos(3) figPos(4)];
            insetW = normAx(3) * 0.42;
            insetH = normAx(4) * 0.42;
            switch insetPos
                case 'br'
                    ix = normAx(1) + normAx(3) - insetW - 0.01;
                    iy = normAx(2) + 0.03;
                case 'bl'
                    ix = normAx(1) + 0.03;
                    iy = normAx(2) + 0.03;
                case 'tr'
                    ix = normAx(1) + normAx(3) - insetW - 0.01;
                    iy = normAx(2) + normAx(4) - insetH - 0.02;
                otherwise
                    ix = normAx(1) + 0.03;
                    iy = normAx(2) + normAx(4) - insetH - 0.02;
            end
            inAx = axes(fig, 'Position', [ix iy insetW insetH]);
            hold(inAx, 'on'); box(inAx, 'on');
            yMin = Inf; yMax = -Inf;
            for j = 1:numel(tData)
                mask = tData{j} >= zoomXlim(1) & tData{j} <= zoomXlim(2);
                plot(inAx, tData{j}(mask), vData{j}(mask), ...
                    'Color', colors{j}, 'LineWidth', 1.2);
                yMin = min(yMin, min(vData{j}(mask)));
                yMax = max(yMax, max(vData{j}(mask)));
            end
            yPad = max((yMax - yMin) * 0.15, 0.1);
            xlim(inAx, zoomXlim);
            ylim(inAx, [yMin - yPad, yMax + yPad]);
            set(inAx, 'FontSize', 7, 'XGrid', 'on', 'YGrid', 'on', ...
                'XColor', [0.3 0.3 0.3], 'YColor', [0.3 0.3 0.3], ...
                'LineWidth', 0.8);
            rectangle(parentAx, 'Position', ...
                [zoomXlim(1), yMin - yPad, diff(zoomXlim), yMax - yMin + 2*yPad], ...
                'EdgeColor', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.8);
        end

        function restoreUPSDemo(cfg, gains_healthy, nomNoiseAmp, afeCtrl, nomAFEKpExpr, nomAFEKiExpr)
            mdl = char(cfg.ModelName);
            bp = cfg.BlockParams;
            N_pfc = cfg.Topology.N_pfc;
            for k = 1:numel(gains_healthy)
                if k > cfg.n_pfc, break; end
                StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.Kp, num2str(N_pfc(k) * gains_healthy(k).Kp));
                StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.Ki, num2str(N_pfc(k) * gains_healthy(k).Ki));
                StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.C_dc, num2str(N_pfc(k) * cfg.Controller.C));
                StabilityStudy.setSSCParam(cfg.PFCBlocks(k), bp.G_damp, num2str(N_pfc(k) * cfg.Controller.G_damp));
            end
            set_param(cfg.CableBlock, bp.R, '0.001'); set_param(cfg.CableBlock, bp.L, '0.001');
            set_param(cfg.RLCBlock, 'R', '0.0001'); set_param(cfg.RLCBlock, 'L', '1e-07');
            set_param(mdl, 'MaxStep', '0.001');
            set_param([mdl '/Step1'], 'Before', '0', 'After', '0');
            set_param([mdl '/Step3'], 'Before', '1', 'After', '1');
            set_param([mdl '/Step4'], 'Before', '0', 'After', '0');
            set_param([mdl '/ComputeProfile'], 'noiseAmplitude', num2str(nomNoiseAmp));
            set_param(afeCtrl, 'KpVoltage', nomAFEKpExpr, 'KiVoltage', nomAFEKiExpr);
        end

        function setSSCParam(blk, paramName, paramValue)
            %SETSSCPARAM Set Simscape Component parameter via set_param or InstanceData.
            blk = char(blk);
            try
                set_param(blk, paramName, paramValue);
            catch
                instData = get_param(blk, 'InstanceData');
                idx = find(strcmp({instData.Name}, paramName), 1);
                if ~isempty(idx)
                    instData(idx).Value = paramValue;
                    set_param(blk, 'InstanceData', instData);
                else
                    error('StabilityStudy:paramNotFound', ...
                        'Parameter ''%s'' not found on %s', paramName, blk);
                end
            end
        end

    end

end