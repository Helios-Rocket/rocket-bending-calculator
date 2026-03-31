function CP = calc_CP_bodytube(l, r, x0, alpha)
    CP0 = l/2;
    K = 0;

    Ap = l * 2 * r;
    XB = x0 + 1/2 * l;

    CNa2 = calc_CNa2(K, Ap, r*2, alpha);

    CP = (CP0 + CNa2*XB) / (1 + CNa2);
end