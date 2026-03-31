function V = calc_nakka_v(N_N, w1, w2, x, x1, L)
    if x <= x1
        V = N_N - (w1*x);
    else
        V1 = calc_nakka_v(N_N, w1, w2, x1, x1, L);
        V  = V1 - w2 * (x - x1);
    end
end