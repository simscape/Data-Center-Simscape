classdef (Sealed) StabilityPlots
%STABILITYPLOTS Static plotting methods for datacenter stability analysis figures.

    methods (Static)

        function setupImpedance(r, pal)
        %SETUPIMPEDANCE Plot closed-loop impedance magnitude and phase.
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            nexttile
            semilogx(r.f_bode, 20*log10(abs(r.Z_cl)), 'Color',pal.blue, 'LineWidth',1.8); hold on
            xline(r.f_res, '--', sprintf('f_{res}=%.2f Hz',r.f_res), 'Color',pal.red, 'LineWidth',1.2)
            xlabel('Frequency (Hz)'); ylabel('|Z_{cl}| (dB)'); title('Closed-Loop Impedance: Load \rightarrow V_{dc}')
            grid on; xlim(r.FreqRange)
            nexttile
            semilogx(r.f_bode, rad2deg(angle(r.Z_cl)), 'Color',pal.blue, 'LineWidth',1.8); hold on
            xline(r.f_res, '--', 'Color',pal.red, 'LineWidth',1.2)
            yline(0, ':', 'Color',pal.grey, 'LineWidth',0.8)
            xlabel('Frequency (Hz)'); ylabel('Phase (deg)'); title('Phase of Z_{cl}')
            grid on; xlim(r.FreqRange)
        end

        function baselineOverview(r, pal)
        %BASELINEOVERVIEW Eight-panel baseline PFC and UPS voltage overview.
            t = r.t; v_pfc = r.v_pfc; t_ups = r.t_ups; v_ups = r.v_ups;
            V_op = r.V_op; V_ups_ref = r.V_ups; t_ss = r.t_ss; ss = r.ss; dt = r.dt;
            ds = max(1, floor(numel(t)/15000)); idx = 1:ds:numel(t);
            ds_u = max(1, floor(numel(t_ups)/15000)); idx_u = 1:ds_u:numel(t_ups);

            tiledlayout(4, 2, 'TileSpacing','compact','Padding','compact')
            set(gcf, 'Position', [100 50 1100 900])

            nexttile
            StabilityStudy.drawBands(gca, [t_ss t(end)], StabilityStudy.getBands("pfc", pal, V_dc=V_op)); hold on
            plot(t(idx), v_pfc(idx,1), 'Color',pal.blue, 'LineWidth',1.2)
            plot(t(idx), v_pfc(idx,2), 'Color',pal.green, 'LineWidth',1.0)
            plot(t(idx), v_pfc(idx,3), 'Color',pal.orange, 'LineWidth',1.0)
            yline(V_op, '--', 'V_{ref}', 'Color',pal.grey, 'LineWidth',0.8, 'LabelHorizontalAlignment','left')
            ylabel('V_{dc} (V)'); title('PFC DC Bus Voltage')
            legend({'PFC A','PFC B','PFC C'}, 'Location','northeastoutside')
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel',[])

            nexttile
            bands = StabilityStudy.getBands("ups", pal, V_ups=V_ups_ref);
            StabilityStudy.drawBands(gca, [t_ss t_ups(end)], bands); hold on
            plot(t_ups(idx_u), v_ups(idx_u), 'Color',pal.purple, 'LineWidth',1.2)
            yline(V_ups_ref, '--', 'V_{ref,UPS}', 'Color',pal.grey, 'LineWidth',0.8, 'LabelHorizontalAlignment','left')
            ylabel('V_{dc} (V)'); title('UPS DC Bus (800V)')
            xlim([t_ss t_ups(end)]); grid on; set(gca, 'XTickLabel',[])

            nexttile
            plot(r.t_rms, r.I_rms0, 'Color',pal.red, 'LineWidth',1.2)
            ylabel('I_{rms} (A)'); title('PFC A AC Current (RMS)')
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel',[])

            nexttile
            plot(r.t_rms, r.I_rms1, 'Color',pal.ltblue, 'LineWidth',1.2)
            ylabel('I_{rms} (A)'); title('PFC B AC Current')
            xlim([t_ss t(end)]); grid on; set(gca, 'XTickLabel',[])

            nexttile
            plot(t(idx), v_pfc(idx,1)-V_op, 'Color',pal.grey, 'LineWidth',0.8)
            yline(0, '-', 'Color','k', 'LineWidth',0.5)
            ylabel('\DeltaV (V)'); title('PFC A Voltage Error'); xlabel('Time (s)')
            xlim([t_ss t(end)]); grid on

            nexttile
            v_spread = max(v_pfc,[],2) - min(v_pfc,[],2);
            plot(t(idx), v_spread(idx), 'Color',pal.orange, 'LineWidth',1.2)
            ylabel('\DeltaV_{spread} (V)'); title('Voltage Spread Across PFCs'); xlabel('Time (s)')
            xlim([t_ss t(end)]); grid on

            nexttile
            v_ss = v_pfc(ss,1) - mean(v_pfc(ss,1));
            N_fft = 2^floor(log2(min(numel(v_ss), 65536)));
            f_spec = (0:N_fft/2-1) / (N_fft * dt);
            Y_fft = abs(fft(v_ss(1:N_fft))) / N_fft * 2; Y_fft = Y_fft(1:N_fft/2);
            stem(f_spec(f_spec < 20), Y_fft(f_spec < 20), 'filled', 'Color',pal.blue, 'MarkerSize',3, 'LineWidth',0.8)
            xlabel('Frequency (Hz)'); ylabel('|V_{dc} ripple| (V)'); title('DC Bus Spectrum (PFC A)')
            grid on; xlim([0 20])

            nexttile
            histogram(v_pfc(ss,1), 60, 'FaceColor',pal.blue, 'EdgeColor','none', 'FaceAlpha',0.6); hold on
            histogram(v_pfc(ss,2), 60, 'FaceColor',pal.green, 'EdgeColor','none', 'FaceAlpha',0.4)
            xline(V_op, '--', 'V_{ref}', 'Color',pal.red, 'LineWidth',1.2)
            xline(V_op*0.95, ':', '-5%', 'Color',pal.grey); xline(V_op*1.05, ':', '+5%', 'Color',pal.grey)
            xlabel('V_{dc} (V)'); ylabel('Count'); title('Voltage Distribution'); grid on
            legend({'PFC A','PFC B'}, 'Location','northeastoutside')
        end

        function firmwareBugVoltage(r, pal, V0)
        %FIRMWAREBUGVOLTAGE Buggy PFC voltage waveform and error plots.
            tiledlayout(2,1, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands = StabilityStudy.getBands("pfc", pal, V_dc=V0);
            StabilityStudy.drawBands(ax1, [r.AnalysisStart r.StopTime], bands); hold(ax1, 'on')
            plot(ax1, r.t, r.v0, 'Color',pal.red, ...
                'LineWidth',1.2, 'DisplayName','Buggy PFC')
            for kk = 1:numel(r.v_others)
                plot(ax1, r.t, r.v_others{kk}, 'Color',pal.blue, ...
                    'LineWidth',1.0, 'DisplayName',sprintf('PFC %c', char('A'+kk)))
            end
            yline(V0, ':', 'Color',pal.grey, 'LineWidth',0.8, 'HandleVisibility','off')
            ylabel('V_{dc} (V)'); title('DC Bus Voltage — Firmware Bug')
            xlim(ax1, [r.AnalysisStart r.StopTime]); legend('Location','northeast'); grid on
            ax2 = nexttile; hold(ax2, 'on')
            plot(ax2, r.t, r.v0 - V0, 'Color',pal.red, 'LineWidth',1.2)
            yline(0, ':', 'Color',pal.grey, 'LineWidth',0.8)
            xlabel('Time (s)'); ylabel('Voltage Error (V)')
            title('Voltage Error — Load Steps Excite Underdamped PFC Resonance')
            xlim(ax2, [r.AnalysisStart r.StopTime]); grid on
        end

        function firmwareBugFFT(r, pal)
        %FIRMWAREBUGFFT FFT spectrum of buggy PFC DC bus voltage.
            tiledlayout(1,1); ax = nexttile; hold(ax, 'on')
            mask = r.f_fft < 20;
            stem(ax, r.f_fft(mask), r.P_fft(mask), 'filled', ...
                'MarkerSize',3, 'LineWidth',1.2, ...
                'Color',pal.blue, 'MarkerFaceColor',pal.blue)
            xline(ax, r.f_osc, '--', sprintf('f_{osc} = %.2f Hz',r.f_osc), 'Color',pal.red, 'LineWidth',1.2)
            xlabel(ax, 'Frequency (Hz)'); ylabel(ax, 'Amplitude (V)'); title(ax, 'FFT of DC Bus Voltage (Buggy PFC)')
            grid(ax, 'on'); xlim(ax, [0 20])
        end

        function firmwareBugImpedance(r, pal)
        %FIRMWAREBUGIMPEDANCE Impedance and predicted ripple at excitation frequencies.
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands = StabilityStudy.getBands("gain", pal);
            StabilityStudy.drawBands(ax1, [0.01 1000], bands); hold(ax1, 'on')
            semilogx(ax1, r.FreqExcite, 20*log10(r.Z_cl_excite), '-o', ...
                'Color',pal.blue, 'LineWidth',1.5, ...
                'MarkerFaceColor',pal.blue, 'MarkerSize',5)
            xline(r.f_res, '--', sprintf('f_{res}=%.2f Hz',r.f_res), 'Color',pal.red, 'LineWidth',1.2)
            xlabel('Frequency (Hz)'); ylabel('|Z_{cl}| (dB)'); title('Closed-Loop Impedance at Excitation Frequencies')
            grid on; xlim([0.01 1000])
            ax2 = nexttile; hold(ax2, 'on')
            semilogx(ax2, r.FreqExcite, r.V_ripple_pred, '-s', ...
                'Color',pal.red, 'LineWidth',1.5, ...
                'MarkerFaceColor',pal.red, 'MarkerSize',5)
            xline(r.f_res, '--', sprintf('f_{res}=%.2f Hz',r.f_res), 'Color',pal.red, 'LineWidth',1.2)
            xlabel('Frequency (Hz)'); ylabel('Predicted V_{ripple} (V)')
            title(sprintf('Voltage Ripple from %g W Power Virus', r.VirusPower))
            grid on; xlim([0.01 1000])
        end

        function weakGridAdmittance(r, pal)
        %WEAKGRIDADMITTANCE PFC input admittance magnitude and phase vs frequency.
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile; hold(ax1, 'on')
            fill(ax1, [0.01 r.f_tau r.f_tau 0.01], [-30 -30 10 10], ...
                pal.red, 'FaceAlpha',0.04, ...
                'EdgeColor','none', 'HandleVisibility','off')
            fill(ax1, [r.f_tau 1000 1000 r.f_tau], [-30 -30 10 10], ...
                pal.green, 'FaceAlpha',0.04, ...
                'EdgeColor','none', 'HandleVisibility','off')
            semilogx(ax1, r.f_grid, 20*log10(abs(r.Y_pfc_dyn)), 'Color',pal.blue, 'LineWidth',1.8)
            xline(ax1, r.f_tau, '--', sprintf('f_{\\tau}=%.1f Hz',r.f_tau), 'Color',pal.red, 'LineWidth',1.0)
            xlabel(ax1, 'Frequency (Hz)'); ylabel(ax1, '|Y_{pfc}| (dB S)')
            title(ax1, 'PFC Input Admittance — Magnitude')
            grid(ax1, 'on'); xlim(ax1, [0.01 1000])
            ax2 = nexttile;
            bands = struct('lo',{-90, 90},'hi',{90, 180}, ...
                'color',{pal.green, pal.red},'alpha',{0.06, 0.04});
            StabilityStudy.drawBands(ax2, [0.01 1000], bands)
            semilogx(ax2, r.f_grid, rad2deg(angle(r.Y_pfc_dyn)), 'Color',pal.blue, 'LineWidth',1.8); hold(ax2, 'on')
            xline(ax2, r.f_tau, '--', 'Color',pal.red, 'LineWidth',1.0)
            yline(ax2, 0, ':', 'Color',pal.grey, 'LineWidth',0.8)
            xlabel(ax2, 'Frequency (Hz)'); ylabel(ax2, 'Phase (deg)'); title(ax2, 'PFC Input Admittance — Phase')
            grid(ax2, 'on'); xlim(ax2, [0.01 1000]); ylim(ax2, [-180 180])
        end

        function weakGridLoopGain(r, pal)
        %WEAKGRIDLOOPGAIN Middlebrook loop gain magnitude and phase for SCR sweep.
            colors_scr = {pal.red, pal.orange, [0.75 0.60 0.10], pal.green};
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands = struct('lo',{-80, 0},'hi',{0, 20}, ...
                'color',{pal.green, pal.red},'alpha',{0.08, 0.06});
            StabilityStudy.drawBands(ax1, [0.01 1000], bands)
            hold(ax1, 'on')
            for kk = 1:numel(r.SCR_sweep)
                semilogx(ax1, r.f_grid, 20*log10(abs(r.T_all{kk})), 'Color',colors_scr{kk}, 'LineWidth',1.8)
            end
            yline(ax1, 0, '--', '0 dB', 'Color',pal.grey, 'LineWidth',1.0)
            xlabel(ax1, 'Frequency (Hz)'); ylabel(ax1, '|T| (dB)'); title(ax1, 'Middlebrook Loop Gain — Magnitude')
            scr_labels = arrayfun(@(x) sprintf('SCR=%.1g',x), ...
                r.SCR_sweep, 'UniformOutput',false);
            legend(ax1, scr_labels, 'Location','northeastoutside')
            grid(ax1, 'on'); xlim(ax1, [0.01 1000])
            ax2 = nexttile;
            bands = struct('lo',{-120, -180},'hi',{-180, -270}, ...
                'color',{pal.orange, pal.red},'alpha',{0.06, 0.06});
            StabilityStudy.drawBands(ax2, [0.01 1000], bands)
            hold(ax2, 'on')
            for kk = 1:numel(r.SCR_sweep)
                semilogx(ax2, r.f_grid, rad2deg(angle(r.T_all{kk})), 'Color',colors_scr{kk}, 'LineWidth',1.8)
            end
            yline(ax2, -180, '--', '-180\circ', 'Color',pal.grey, 'LineWidth',1.0)
            xlabel(ax2, 'Frequency (Hz)'); ylabel(ax2, 'Phase (deg)'); title(ax2, 'Middlebrook Loop Gain — Phase')
            grid(ax2, 'on'); xlim(ax2, [0.01 1000])
        end

        function weakGridNyquist(r, pal)
        %WEAKGRIDNYQUIST Nyquist contour of Z_grid * Y_pfc for SCR sweep.
            colors_scr = {pal.red, pal.orange, [0.75 0.60 0.10], pal.green};
            tiledlayout(1,1); ax = nexttile; hold(ax, 'on')
            theta = linspace(0, 2*pi, 200);
            plot(ax, cos(theta), sin(theta), '--', 'Color',pal.grey, 'LineWidth',0.8)
            for kk = 1:numel(r.SCR_sweep)
                plot(ax, real(r.T_all{kk}), imag(r.T_all{kk}), 'Color',colors_scr{kk}, 'LineWidth',1.5)
            end
            plot(ax, -1, 0, 'rx', 'MarkerSize',12, 'LineWidth',2)
            xlabel(ax, 'Real'); ylabel(ax, 'Imaginary'); title(ax, 'Nyquist: Z_{grid} \cdot Y_{pfc}')
            scr_labels = arrayfun(@(x) sprintf('SCR=%.1g',x), ...
                r.SCR_sweep, 'UniformOutput',false);
            legend(ax, [scr_labels, {'Unit circle','Critical (-1,0)'}], ...
                'Location','northeastoutside')
            grid(ax, 'on')
            max_T = max(cellfun(@(t) max(abs(t)), r.T_all)); lim = min(max_T*1.1, 50);
            xlim(ax, [-lim lim]); ylim(ax, [-lim lim]); axis(ax, 'equal')
        end

        function weakGridPCC(r, pal)
        %WEAKGRIDPCC Three-phase PCC voltage and current RMS for SCR sweep.
            colors_scr = {pal.red, pal.orange, [0.75 0.60 0.10], pal.green};
            phase_labels = {'Phase A', 'Phase B', 'Phase C'};
            scr_legend = arrayfun(@(x) sprintf('SCR=%.1g',x), r.SCR_sweep, 'UniformOutput',false);
            tiledlayout(3, 2, 'TileSpacing','compact','Padding','compact')
            for ph = 1:3
                ax = nexttile(ph*2-1);
                bands = StabilityStudy.getBands("pcc", pal, V_nom=r.V_nom);
                StabilityStudy.drawBands(ax, [r.AnalysisStart r.StopTime], bands); hold(ax, 'on')
                for kk = 1:numel(r.SCR_sweep)
                    if ~r.diverged(kk)
                        plot(ax, r.t_pcc{kk}, r.V_pcc_3ph{kk}(:,ph), 'Color',colors_scr{kk}, 'LineWidth',1.8)
                    end
                end
                yline(ax, r.V_nom, ':', sprintf('V_{nom}=%dV',r.V_nom), 'Color',pal.grey, 'LineWidth',0.8)
                ylabel(ax, 'V_{RMS} (V)'); title(ax, [phase_labels{ph} ' — RMS Voltage'])
                grid(ax, 'on'); xlim(ax, [r.AnalysisStart r.StopTime])
                if ph == 1, legend(ax, scr_legend(~r.diverged), 'Location','northeastoutside'); end
                if ph == 3, xlabel(ax, 'Time (s)'); end
                ax = nexttile(ph*2); hold(ax, 'on')
                for kk = 1:numel(r.SCR_sweep)
                    if ~r.diverged(kk)
                        plot(ax, r.t_pcc{kk}, r.I_pcc_3ph{kk}(:,ph), 'Color',colors_scr{kk}, 'LineWidth',1.8)
                    end
                end
                ylabel(ax, 'I_{RMS} (A)'); title(ax, [phase_labels{ph} ' — RMS Current'])
                grid(ax, 'on'); xlim(ax, [r.AnalysisStart r.StopTime])
                if ph == 1, legend(ax, scr_legend(~r.diverged), 'Location','northeastoutside'); end
                if ph == 3, xlabel(ax, 'Time (s)'); end
            end
        end

        function weakGridAmplification(r, pal)
        %WEAKGRIDAMPLIFICATION Grid amplification factor vs SCR and multi-DC scaling.
            colors_n = {pal.blue, pal.green, pal.orange, pal.red};
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands_amp = StabilityStudy.getBands("amplification", pal);
            StabilityStudy.drawBands(ax1, [min(r.SCR_fine) max(r.SCR_fine)], bands_amp); hold(ax1, 'on')
            plot(ax1, r.SCR_fine, r.amplification, 'Color',pal.red, 'LineWidth',1.8)
            yline(ax1, 1, ':', 'No amplification', 'Color',pal.grey, 'LineWidth',0.8)
            yline(ax1, 2, '--', '2\times (6 dB)', 'Color',pal.blue, 'LineWidth',1.0)
            xlabel(ax1, 'SCR'); ylabel(ax1, 'Amplification Factor')
            title(ax1, sprintf('Grid Amplification (f_{osc}=%.1f Hz)',r.f_osc))
            grid(ax1, 'on'); xlim(ax1, [min(r.SCR_fine) max(r.SCR_fine)])
            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [min(r.SCR_fine) max(r.SCR_fine)], bands_amp); hold(ax2, 'on')
            for kk = 1:numel(r.N_dc)
                amp_n = StabilityUtils.computeAmplification( ...
                    r.SCR_fine, r.f_osc, r.V_base_grid, ...
                    r.P_base_grid, r.XR_grid, r.Y_at_fosc, r.N_dc(kk));
                plot(ax2, r.SCR_fine, amp_n, 'Color',colors_n{kk}, 'LineWidth',1.8)
            end
            yline(ax2, 1, ':', 'Color',pal.grey, 'LineWidth',0.8)
            yline(ax2, 5, '--', 'Severe', 'Color',pal.red, 'LineWidth',1.0)
            xlabel(ax2, 'SCR'); ylabel(ax2, 'Amplification Factor'); title(ax2, 'Multiple DCs on Shared Feeder')
            legend(ax2, arrayfun(@(x) sprintf('N=%d',x), r.N_dc, 'UniformOutput',false), 'Location','northeastoutside')
            grid(ax2, 'on'); xlim(ax2, [min(r.SCR_fine) max(r.SCR_fine)]); ylim(ax2, [0 10])
        end

        function upsIsolationGrid(r, pal)
        %UPSISOLATIONGRID PFC and UPS bus comparison at strong vs weak grid.
            tiledlayout(2,1, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands_pfc = StabilityStudy.getBands("pfc", pal, V_dc=r.V_op);
            StabilityStudy.drawBands(ax1, [1 r.StopTime], bands_pfc); hold(ax1, 'on')
            plot(ax1, r.t_strong, r.v_pfc0_strong, 'Color',pal.blue, 'LineWidth',1.8)
            plot(ax1, r.t_weak, r.v_pfc0_weak, '--', 'Color',pal.red, 'LineWidth',1.2)
            yline(r.V_op, ':', 'V_{ref}', 'Color',pal.grey, 'LineWidth',0.8)
            ylabel('PFC V_{dc} (V)'); title('PFC DC Bus — Grid Strength Has NO Effect (UPS Isolated)')
            legend('Strong grid', sprintf('Extreme weak (SCR=%.1f)',r.SCR_extreme), 'Location','northeastoutside')
            grid on; xlim([1 r.StopTime])
            ax2 = nexttile;
            bands_ups = StabilityStudy.getBands("ups", pal, V_ups=r.V_ups);
            StabilityStudy.drawBands(ax2, [1 r.StopTime], bands_ups); hold(ax2, 'on')
            plot(ax2, r.t_strong, r.v_ups_strong, 'Color',pal.blue, 'LineWidth',1.8)
            plot(ax2, r.t_weak, r.v_ups_weak, '--', 'Color',pal.red, 'LineWidth',1.2)
            yline(r.V_ups, ':', 'V_{ref,UPS}', 'Color',pal.grey, 'LineWidth',0.8)
            ylabel('UPS V_{dc} (V)'); xlabel('Time (s)')
            title('UPS DC Bus — Slight Perturbation but Stable')
            legend('Strong grid', sprintf('SCR=%.1f',r.SCR_extreme), 'Location','northeastoutside')
            grid on; xlim([1 r.StopTime])
        end

        function upsIsolationFirmware(r, pal)
        %UPSISOLATIONFIRMWARE Firmware bug waveform comparison across grid strengths.
            tiledlayout(1,1); ax = nexttile; hold(ax, 'on')
            bands = StabilityStudy.getBands("pfc", pal, V_dc=r.V_op);
            StabilityStudy.drawBands(ax, [r.AnalysisStart-1 r.StopTime], bands)
            plot(ax, r.t_fws, r.v_fws, 'Color',pal.blue, 'LineWidth',1.8)
            plot(ax, r.t_fww, r.v_fww, '--', 'Color',pal.red, 'LineWidth',1.2)
            ylabel(ax, 'PFC V_{dc} (V)'); xlabel(ax, 'Time (s)')
            title(ax, 'Firmware Bug: Identical at Extreme SCR vs Strong Grid')
            legend(ax, 'Strong grid', sprintf('SCR=%.1f',r.SCR_extreme), 'Location','northeastoutside')
            grid(ax, 'on'); xlim(ax, [r.AnalysisStart-1 r.StopTime])
        end

        function upsImpedanceBode(r, pal)
        %UPSIMPEDANCEBODE UPS DC bus impedance Bode for nominal and undersized cap.
            tiledlayout(1,1); ax = nexttile; hold(ax, 'on')
            StabilityStudy.drawBands(ax, [0.01 100], StabilityStudy.getBands("gain", pal))
            semilogx(ax, r.f_bode_ups, 20*log10(abs(r.Z_cl_ups_nom)), 'Color',pal.blue, 'LineWidth',1.8)
            semilogx(ax, r.f_bode_ups, 20*log10(abs(r.Z_cl_ups_res)), 'Color',pal.red, 'LineWidth',1.8)
            xline(ax, r.f_n_ups, ':', sprintf('f_n=%.2f Hz',r.f_n_ups), 'Color',pal.blue)
            xline(ax, r.f_n_ups_res, ':', sprintf('f_n=%.1f Hz',r.f_n_ups_res), 'Color',pal.red)
            xline(ax, r.f_osc, '--', sprintf('f_{osc}=%.2f Hz',r.f_osc), 'Color',pal.grey)
            xlabel(ax, 'Frequency (Hz)'); ylabel(ax, '|Z_{cl,UPS}| (dB)')
            title(ax, 'UPS DC Bus Impedance: Load \rightarrow Voltage Ripple')
            legend(ax, sprintf('Nominal C=%.2f F (f_n=%.2f Hz)',r.C_ups_nom, r.f_n_ups), ...
                sprintf('Undersized C=%.2f F (f_n=%.1f Hz)',r.C_ups_res, r.f_n_ups_res), 'Location','northeastoutside')
            grid(ax, 'on'); xlim(ax, [0.01 100])
        end

        function upsResonance(r, pal)
        %UPSRESONANCE UPS and PFC bus voltage under resonance conditions.
            tiledlayout(2,1, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands_ups = StabilityStudy.getBands("ups", pal, V_ups=r.V_ups);
            StabilityStudy.drawBands(ax1, [1 r.StopTimeRes2], bands_ups); hold(ax1, 'on')
            if ~isempty(r.t_un)
                plot(ax1, r.t_un, r.v_ups_nom_t, 'Color',pal.blue, 'LineWidth',1.8)
            end
            if ~isempty(r.t_ur)
                plot(ax1, r.t_ur, r.v_ups_res_t, 'Color',pal.red, 'LineWidth',1.8)
            end
            yline(r.V_ups, ':', 'V_{ref,UPS}', 'Color',pal.grey)
            ylabel('UPS V_{dc} (V)'); title('UPS 800V DC Bus — Resonance with Undersized Capacitor + Degraded AFE')
            legend(sprintf('Nominal C=%.2f F',r.C_ups_nom), ...
                sprintf('C=%.2f F, AFE Kp=%.1f Ki=%.0f',r.C_ups_res, r.AFEDegradedRes.Kp, r.AFEDegradedRes.Ki), ...
                'Location','northeastoutside')
            grid on; xlim([1 r.StopTimeRes2])
            ax2 = nexttile;
            bands_pfc = StabilityStudy.getBands("pfc", pal, V_dc=r.V_op);
            StabilityStudy.drawBands(ax2, [1 r.StopTimeRes2], bands_pfc); hold(ax2, 'on')
            if ~isempty(r.t_un)
                plot(ax2, r.t_un, r.v_pfc0_nom_t, 'Color',pal.blue, 'LineWidth',1.8)
            end
            if ~isempty(r.t_ur)
                plot(ax2, r.t_ur, r.v_pfc0_res_t, 'Color',pal.red, 'LineWidth',1.8)
            end
            yline(r.V_op, ':', 'V_{ref}', 'Color',pal.grey)
            ylabel('PFC V_{dc} (V)'); xlabel('Time (s)')
            title('PFC DC Bus — Effect of UPS Resonance on Downstream Loads')
            legend(sprintf('Nominal C=%.2f F',r.C_ups_nom), ...
                sprintf('C=%.2f F, AFE Kp=%.1f Ki=%.0f',r.C_ups_res, r.AFEDegradedRes.Kp, r.AFEDegradedRes.Ki), ...
                'Location','northeastoutside')
            grid on; xlim([1 r.StopTimeRes2])
        end

        function afeLoopGain(r, pal)
        %AFELOOPGAIN AFE loop gain and sensitivity Bode for degradation sweep.
            colors_G = {pal.blue, pal.green, pal.orange, pal.red};
            afe_labels = {r.AFE_cases.label};
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands = struct('lo',{0,-40},'hi',{120,0}, ...
                'color',{pal.green,pal.red},'alpha',{0.06,0.06});
            StabilityStudy.drawBands(ax1, [0.01 100], bands); hold(ax1, 'on')
            for kk = 1:numel(r.AFE_cases)
                semilogx(ax1, r.f_analysis, 20*log10(abs(r.L_all{kk})), 'Color',colors_G{kk}, 'LineWidth',1.8)
            end
            xline(ax1, r.f_osc, '--', sprintf('f_{bug}=%.1f Hz',r.f_osc), 'Color',pal.grey, 'LineWidth',1.0)
            yline(ax1, 0, ':', 'Color',pal.grey, 'LineWidth',0.8)
            xlabel('Frequency (Hz)'); ylabel('|L(f)| (dB)')
            title('AFE Loop Gain — Degradation Reduces Rejection')
            legend(afe_labels, 'Location','southwest'); grid on; xlim([0.01 100])
            ax2 = nexttile;
            StabilityStudy.drawBands(ax2, [0.01 100], StabilityStudy.getBands("sensitivity", pal)); hold(ax2, 'on')
            for kk = 1:numel(r.AFE_cases)
                semilogx(ax2, r.f_analysis, 20*log10(abs(r.S_all{kk})), 'Color',colors_G{kk}, 'LineWidth',1.8)
            end
            xline(ax2, r.f_osc, '--', sprintf('f_{bug}=%.1f Hz',r.f_osc), 'Color',pal.grey, 'LineWidth',1.0)
            yline(ax2, 0, ':', '0 dB (no rejection)', 'Color',pal.grey, 'LineWidth',0.8)
            xlabel('Frequency (Hz)'); ylabel('|S(f)| (dB)')
            title('Sensitivity — Oscillation Reaching DC Bus')
            legend(afe_labels, 'Location','southeast'); grid on; xlim([0.01 100]); ylim([-100 10])
        end

        function afeTimeDomain(r, pal)
        %AFETIMEDOMAIN UPS and PFC bus voltage time-domain for AFE sweep.
            colors_G = {pal.blue, pal.green, pal.orange, pal.red};
            afe_labels = {r.AFE_cases.label};
            tiledlayout(2,1, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands_ups = StabilityStudy.getBands("ups", pal, V_ups=r.V_ups);
            StabilityStudy.drawBands(ax1, [1 r.StopTime], bands_ups); hold(ax1, 'on')
            for kk = 1:numel(r.AFE_cases)
                [t_k, v_k] = StabilityStudy.extractSimlog(r.out_G{kk}.simlog, r.sp.ups_vdc, 'V');
                plot(ax1, t_k, v_k, 'Color',colors_G{kk}, 'LineWidth',1.8)
            end
            yline(r.V_ups, ':', 'V_{ref,UPS}', 'Color',pal.grey, 'LineWidth',0.8)
            ylabel('UPS V_{dc} (V)'); title('UPS DC Bus — AFE Degradation Exposes PFC Oscillation')
            legend(afe_labels, 'Location','northeastoutside'); grid on; xlim([1 r.StopTime])
            ax2 = nexttile;
            bands_pfc = StabilityStudy.getBands("pfc", pal, V_dc=r.V_op);
            StabilityStudy.drawBands(ax2, [1 r.StopTime], bands_pfc); hold(ax2, 'on')
            for kk = 1:numel(r.AFE_cases)
                [t_k, v_k] = StabilityStudy.extractSimlog(r.out_G{kk}.simlog, r.pfc0_path, 'V');
                plot(ax2, t_k, v_k, 'Color',colors_G{kk}, 'LineWidth',1.8)
            end
            yline(r.V_op, ':', 'Color',pal.grey, 'LineWidth',0.8)
            ylabel('PFC V_{dc} (V)'); xlabel('Time (s)')
            title('PFC DC Bus — Oscillation Invariant to UPS Controller State')
            legend(afe_labels, 'Location','northeastoutside'); grid on; xlim([1 r.StopTime])
        end

        function afeRippleBar(r, pal)
        %AFERIPPLEBAR Bar chart comparing UPS and PFC ripple across AFE cases.
            tiledlayout(1,1); ax = nexttile;
            x_idx = 1:numel(r.AFE_cases);
            yyaxis(ax, 'left')
            b_bar = bar(ax, x_idx, r.ups_ripple, 'FaceColor',pal.blue);
            ylabel(ax, 'UPS DC Bus Ripple (V pk-pk)')
            yyaxis(ax, 'right')
            b_line = plot(ax, x_idx, r.pfc_ripple, '-o', 'Color',pal.red, 'LineWidth',1.8, 'MarkerFaceColor',pal.red);
            ylabel(ax, 'PFC Ripple (V pk-pk)')
            title(ax, 'UPS vs PFC Ripple — AFE Degradation Only Affects UPS Bus')
            set(ax, 'XTick',x_idx, 'XTickLabel',{r.AFE_cases.label})
            grid(ax, 'on')
            legend(ax, [b_bar, b_line], {'UPS Ripple','PFC Ripple'}, 'Location','northwest')
        end

        function afeWeakGrid(r, pal)
        %AFEWEAKGRID UPS bus comparison for nominal vs degraded AFE at given SCR.
            if isnan(r.rip_nom_scr3), return; end
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile;
            bands = StabilityStudy.getBands("ups", pal, V_ups=r.V_ups);
            StabilityStudy.drawBands(ax1, [1 r.StopTime], bands); hold(ax1, 'on')
            plot(ax1, r.t_nom3, r.v_ups_nom3, 'Color',pal.blue, 'LineWidth',1.8)
            plot(ax1, r.t_deg3, r.v_ups_deg3, 'Color',pal.red, 'LineWidth',1.8)
            yline(r.V_ups, ':', 'Color',pal.grey, 'LineWidth',0.8)
            ylabel('UPS V_{dc} (V)'); xlabel('Time (s)')
            title(sprintf('UPS DC Bus — Nominal vs Degraded AFE (SCR=%d)',r.SCR_grid_test))
            legend('Nominal AFE', 'Severe degradation', 'Location','northeastoutside')
            grid on; xlim([1 r.StopTime])
            ax2 = nexttile;
            bar(ax2, [1 2], [r.rip_nom_scr3, r.rip_deg_scr3], 'FaceColor','flat', 'CData',[pal.blue; pal.red])
            set(ax2, 'XTick',[1 2], 'XTickLabel',{'Nominal AFE','Degraded AFE'})
            ylabel('UPS DC Bus Ripple (V pk-pk)')
            title(sprintf('Ripple Comparison at SCR=%d',r.SCR_grid_test))
            grid on
        end

        function stabilityMap(r, pal)
        %STABILITYMAP Damping ratio vs proportional gain for two firmware versions.
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            nexttile
            plot(r.Kp_sweep, r.zeta_sweep, 'Color',pal.blue, 'LineWidth',2); hold on
            yline(0, 'Color',pal.red, 'LineWidth',1.5, 'Label','\zeta=0 (UNSTABLE)')
            xline(r.Kp_crit, '--', sprintf('K_{p,crit}=%.0f',r.Kp_crit), 'Color',pal.red, 'LineWidth',1.2)
            xline(50, ':', 'Degraded (50)', 'Color',pal.orange, 'LineWidth',1.2)
            xline(1000, ':', 'Nominal (1000)', 'Color',pal.green, 'LineWidth',1.2)
            fill([0 r.Kp_crit r.Kp_crit 0], [-0.5 -0.5 0 0], pal.red, 'FaceAlpha',0.08, 'EdgeColor','none')
            xlabel('K_p (W/V)'); ylabel('\zeta'); title('Damping Ratio vs Proportional Gain')
            grid on; ylim([-0.3 1.5]); xlim(r.KpRange)
            nexttile
            plot(r.Kp_buggy_sweep, r.zeta_b, 'Color',pal.red, ...
                'LineWidth',2, ...
                'DisplayName',sprintf('Ki=%d (degraded)',r.KiBuggy)); hold on
            plot(r.Kp_h_sweep, r.zeta_h, 'Color',pal.blue, 'LineWidth',2, 'DisplayName',sprintf('Ki=%d (nominal)',r.Ki))
            yline(0, '-', 'Color',[0.3 0.3 0.3])
            xline(r.Kp_crit, '--', 'K_{p,crit}', 'Color',pal.grey, 'LineWidth',1)
            xlabel('K_p (W/V)'); ylabel('\zeta'); title('Stability Boundary — Two Firmware Versions')
            legend('Location','southeast'); grid on; ylim([-0.3 1.5])
        end

        function impedancePenetration(r)
        %IMPEDANCEPENETRATION Peak loop gain vs firmware bug penetration fraction.
            tiledlayout(1,1); ax = nexttile; hold(ax, 'on')
            plot(ax, r.fractions*100, r.peak_L_dB, 'b-o', 'LineWidth',1.5, 'MarkerSize',4)
            yline(ax, 0, 'r--', 'Instability Threshold', 'LineWidth',1.5, 'LabelHorizontalAlignment','left')
            if ~isnan(r.frac_critical)
                xline(ax, r.frac_critical*100, 'r:', sprintf('%.0f%%',r.frac_critical*100), 'LineWidth',1.2)
            end
            xlabel(ax, 'PFC Units with Buggy Firmware (%)'); ylabel(ax, 'Peak |L(j\omega)| (dB)')
            title(ax, 'DC Bus Stability Margin vs. Firmware Bug Penetration')
            subtitle(ax, sprintf('Kp_{nominal}=%d, Kp_{degraded}=%d, P_{total}=%.0f MW, V_{dc}=%d V', ...
                r.Kp_h, r.Kp_b, r.P_total/1e6, r.V))
            grid(ax, 'on'); xlim(ax, [0 100])
        end

        function impedanceBode(r)
        %IMPEDANCEBODE Bode plot of return ratio for key penetration scenarios.
            tiledlayout(2,1, 'TileSpacing','compact','Padding','compact')
            ax1 = nexttile; hold(ax1, 'on')
            ax2 = nexttile; hold(ax2, 'on')
            for kk = 1:numel(r.scenarios)
                [mag_i, ph_i] = bode(r.L_systems{kk}, r.w_vec);
                mag_i = squeeze(mag_i); ph_i = squeeze(ph_i);
                semilogx(ax1, r.FreqHz, 20*log10(mag_i), ...
                    'Color',r.scenarios(kk).color, 'LineWidth',1.5, ...
                    'DisplayName',r.scenarios(kk).label)
                semilogx(ax2, r.FreqHz, ph_i, 'Color',r.scenarios(kk).color, 'LineWidth',1.5)
            end
            yline(ax1, 0, 'k--', 'LineWidth',1)
            ylabel(ax1, '|L| (dB)'); title(ax1, 'Return Ratio L(s) = Z_{source} \cdot P_{load}/V^2')
            grid(ax1, 'on'); xlim(ax1, [0.01 50])
            legend(ax1, {r.scenarios.label}, 'Location','northeast')
            yline(ax2, -180, 'k--', 'LineWidth',1)
            ylabel(ax2, 'Phase (deg)'); xlabel(ax2, 'Frequency (Hz)')
            grid(ax2, 'on'); xlim(ax2, [0.01 50])
        end

        function impedanceNyquist(r)
        %IMPEDANCENYQUIST Nyquist comparison for stable vs unstable penetration.
            tiledlayout(1,2, 'TileSpacing','compact','Padding','compact')
            nexttile
            nyquist(r.L_systems{2}, r.w_vec)
            hold on; plot(-1, 0, 'rx', 'MarkerSize',12, 'LineWidth',2)
            title(sprintf('Nyquist: %s (Stable)',r.scenarios(2).label))
            nexttile
            nyquist(r.L_systems{4}, r.w_vec)
            hold on; plot(-1, 0, 'rx', 'MarkerSize',12, 'LineWidth',2)
            title(sprintf('Nyquist: %s (Unstable)',r.scenarios(4).label))
        end

        function odeWaveform(ode, pal)
        %ODEWAVEFORM ODE voltage deviation waveform with analytical envelope.
            tiledlayout(1,1)
            ax = nexttile; hold(ax, 'on')
            t_env = linspace(0, ode.t_ode(ode.idx_lin), 200);
            plot(ax, ode.t_ode(1:ode.idx_lin), ode.dv_ode(1:ode.idx_lin), 'Color', pal.blue, 'LineWidth', 0.8)
            plot(ax, t_env, exp(ode.sigma_ode_pred(1)*t_env), 'r--', 'LineWidth', 2)
            plot(ax, t_env, -exp(ode.sigma_ode_pred(1)*t_env), 'r--', 'LineWidth', 2, 'HandleVisibility', 'off')
            if ~isempty(ode.t_pks)
                plot(ax, ode.t_pks, ode.pks, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', pal.green)
            end
            xlabel(ax, 'Time (s)'); ylabel(ax, 'Voltage deviation (V)')
            title(ax, sprintf('ODE (ideal source): f = %.2f Hz, \\sigma = %.3f 1/s', ode.f_ode, ode.sigma_ode))
            legend(ax, 'ODE', ...
                sprintf('Analytical \\pm e^{%.3f t}', ode.sigma_ode_pred(1)), ...
                'Peaks', 'Location', 'northwest')
            grid(ax, 'on'); xlim(ax, [0 ode.t_ode(ode.idx_lin)])
        end

        function collapseWaveforms(simOut_s, simOut_c, sp, V0, Kp_s, Kp_c, sigma_first, pal)
        %COLLAPSEWAVEFORMS Side-by-side stable vs collapse PFC voltage waveforms.
            [t_s, v_s] = StabilityStudy.extractSimlog(simOut_s.simlog, sp.pfc_vdc{1}, 'V');
            [t_c, v_c] = StabilityStudy.extractSimlog(simOut_c.simlog, sp.pfc_vdc{1}, 'V');
            tiledlayout(1,2, 'TileSpacing', 'compact', 'Padding', 'compact')
            nexttile
            plot(t_s, v_s, 'Color', pal.blue, 'LineWidth', 0.8); hold on
            yline(V0, 'k--', 'LineWidth', 0.5); hold off
            xlabel('Time (s)'); ylabel('V_{dc} (V)')
            title(sprintf('K_p = %d (stable): \\sigma = %.2f 1/s', Kp_s, sigma_first))
            grid on; xlim([0 5]); ylim([300 500])
            nexttile
            plot(t_c, v_c, 'Color', pal.red, 'LineWidth', 0.8); hold on
            yline(V0, 'k--', 'LineWidth', 0.5); hold off
            xlabel('Time (s)'); ylabel('V_{dc} (V)')
            title(sprintf('K_p = %d: nonlinear collapse', Kp_c))
            grid on; xlim([0 3]); ylim([-50 500])
        end

        function sigmaVsKp(P, V0, C, sigma_ode_pred, Kp_vals, sigma_offset, b_ups, Kp_sweep, sigma_sweep, Kp_crit, ~)
        %SIGMAVSICKP Growth rate vs Kp: three analytical models and Simscape data.
            Kp_range = linspace(0, 60, 200);
            sigma_ideal = -(Kp_range/V0 - P/V0^2) ./ (2*C);
            sigma_nominal = sigma_ideal + sigma_offset;
            sigma_simplified = -Kp_range ./ (2*C*V0);
            tiledlayout(1,1)
            ax = nexttile; hold(ax, 'on')
            plot(ax, Kp_range, sigma_ideal, 'r-', 'LineWidth', 2, 'DisplayName', 'ODE (ideal source)')
            plot(ax, Kp_range, sigma_nominal, 'b-', 'LineWidth', 2, 'DisplayName', ...
                sprintf('Extended ODE (b_{ups}=%.3f)', b_ups))
            plot(ax, Kp_range, sigma_simplified, 'g--', 'LineWidth', 2, 'DisplayName', ...
                'Simplified: -K_p/(2CV_0)')
            plot(ax, Kp_vals, sigma_ode_pred, 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
                'HandleVisibility', 'off')
            plot(ax, Kp_sweep, sigma_sweep, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', ...
                'HandleVisibility', 'off')
            yline(ax, 0, 'k:', 'LineWidth', 1)
            xline(ax, Kp_crit, 'k--', sprintf('K_{p,crit} = %.0f', Kp_crit), 'LineWidth', 1.5)
            xlabel(ax, 'K_p (W/V)'); ylabel(ax, '\sigma (1/s)')
            title(ax, '\sigma vs K_p: Three Models + Simscape Sweep')
            legend(ax, 'Location', 'northwest'); grid(ax, 'on')
        end

    end
end
