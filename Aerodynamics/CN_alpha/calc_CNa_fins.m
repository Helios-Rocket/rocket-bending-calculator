function [CNa_T, K_T, B] = calc_CNa_fins(fins, M, alpha)
    cr    = fins.cr;
    ct    = fins.ct;
    xr    = fins.xr;
    s     = fins.s;
    R     = fins.R_body;
    R_ref = fins.R_ref;

    n = fins.n_fins;
    g = 1.4;

    Lambda = atan2(xr + 0.5*(ct - cr), s);

    A_fin = 0.5 * (cr + ct) * s;
    A_ref = pi * R_ref^2;

    M_crit = 1 / cos(Lambda);
    dM = 0.5;

    M1 = M_crit - dM;
    M2 = M_crit - 0.5*dM;
    M3 = M_crit;
    M4 = M_crit + 0.5*dM;
    M5 = M_crit + dM;

    if M <= M1
        CNa = CNa_sub(M);
    elseif M >= M5
        CNa = CNa_sup(M);
    else
        C1 = CNa_sub(M1);
        C2 = 1.01 * CNa_sub(M2);
        C3 = 1.15 * max(C1, CNa_sup(M5));
        C4 = 1.08 * CNa_sup(M4);
        C5 = CNa_sup(M5);

CNa = interp1([M1 M2 M3 M4 M5], [C1 C2 C3 C4 C5], M, 'makima');
    end

    K_T = 1 + R / (s + R);
    CNa_T = K_T * CNa;

    B = sqrt(abs(1 - M^2*cos(Lambda)^2));

    function CNa = CNa_sub(Mloc)
        Bsub = sqrt(max(0, 1 - Mloc^2*cos(Lambda)^2));
        CNa = n/2 * (2 * pi * s^2 / A_ref) / ...
            (1 + sqrt(1 + (Bsub*s^2 / (A_fin*cos(Lambda)))^2));
    end

    function CNa = CNa_sup(Mloc)
        Bsup = sqrt(max(0, Mloc^2*cos(Lambda)^2 - 1));

        if Bsup < 1e-6
            Bsup = 1e-6;
        end

        k1 = 2 / Bsup;
        k2 = ((g + 1)*Mloc^4 - 4*Bsup^2) / (4 * Bsup^4);
        k3 = ((g + 1)*Mloc^8 + (2*g^2 - 7*g - 5)*Mloc^6 + ...
              10*(g + 1)*Mloc^4 + 8) / (6 * Bsup^7);

        CNa = A_fin / A_ref * (k1 + k2*alpha + k3*alpha^2);
    end
end