function CNa = calc_CNa_bodytube(r, l, R_ref, alpha)
    K = 2.5;
    A_plan = 2 * r * l;
    A_ref  = 2*pi * R_ref^2;

    CNa = (K * A_plan/A_ref * sin(alpha)^2) / alpha;
    if isnan(CNa)
        CNa = 0;
    end
end
