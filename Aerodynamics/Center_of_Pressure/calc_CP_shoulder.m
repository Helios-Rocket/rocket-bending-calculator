function CP = calc_CP_shoulder(D1, D2, LT, x0, alpha)
    K = 1;

    CP0 = LT/2;

    Ap = 1/2 * (D1 + D2) * LT;
    XB     = 1/3 * LT * (D1 + 2*D2) / (D1 + D2);

    CNa2 = calc_CNa2(K, Ap, D2, alpha);

    CP = x0 + (CP0 + CNa2*XB) / (1 + CNa2);
end
