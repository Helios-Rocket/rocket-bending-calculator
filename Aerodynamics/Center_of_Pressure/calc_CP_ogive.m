function CP = calc_CP_ogive(L, R_cone, R_ref, alpha, M)

    if nargin < 5
        M = 0;
    end

    l_over_d = L / (2*R_cone);
%{
    if M > 1
        CP0 = 0.466*L;
    else
        CP0 = nosecone_Cp(M, l_over_d);
    end
%}
    CP0 = nosecone_Cp(M, l_over_d) * R_cone * 2;

    Ap = 2/3 * L * R_cone;
    XB = 5/8 * L;

    CNa2 = calc_CNa2(1.1, Ap, R_cone*2, alpha);

    CP = (CP0 + CNa2*XB) / (1 + CNa2);

    CP = CP * (R_cone / R_ref)^2;
end