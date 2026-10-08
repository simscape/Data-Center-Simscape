function Y = estimateAdmittances(scanner)
% This function performs the estimation of the admittance along the D, Q
% (and optionally DC) axis. Returns 2x2 or 3x3 admittance matrix at the POI.

arguments
    scanner {mustBeA(scanner, 'AdmittanceScanner')}
end

    nAxes = numel(scanner);

    for i = 1:nAxes
        scanner(i) = scanner(i).runACScan();
        scanner(i) = scanner(i).runDCScan();
    end

    if nAxes == 2
        % 2x2 AC-only admittance (D and Q axes)
        Y = [scanner(1).SysD(1), scanner(1).SysD(2);
             scanner(2).SysQ(2), scanner(2).SysQ(1)];
    else
        % 3x3 full admittance (D, Q, DC axes)
        Y = [scanner(1).SysD(1) scanner(1).SysD(2) scanner(1).SysDCD(1);
             scanner(2).SysQ(2) scanner(2).SysQ(1) scanner(2).SysDCQ(1);
             scanner(3).SysDCac(1) scanner(3).SysDCac(2) scanner(3).SysDC(1)];
    end
end