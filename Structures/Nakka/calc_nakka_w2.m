function w2 = calc_nakka_w2(x1, x2, N_F, N_N)
    w2 = ( (N_F * (2*x2 + x1) - N_N*x1) / (x2^2 + x1*x2) );
end