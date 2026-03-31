function CNa = calc_CNa_boattail(R_lower, R_upper, L, R_ref, M)
    CNa = 0;
    
    dr = R_upper*2;
    d  = R_lower*2;

    A = -1.3 * (L/d)^2 + 6.25 * (L/d) - 7.85;

    if M < 1
        CNa0 = -2 * (1 - dr^2/d^2);
    else
        CNa0 = (1 - (dr/d)^2) * (-0.6 - 1.4*exp(A * (M - 1)^0.8));
    end

    CNa = CNa0 * (R_lower / R_ref)^2;
end