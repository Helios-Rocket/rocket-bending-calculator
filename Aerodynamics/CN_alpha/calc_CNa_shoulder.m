function CNa = calc_CNa_shoulder(R_lower, R_upper, R_ref)
    S2 = pi*R_upper^2;
    S1 = pi*R_lower^2;
    d = R_upper*2;

    CNa_ = 8 / (pi*d^2) * (S2 - S1);

    CNa = CNa_ * (R_upper / R_ref)^2;
end