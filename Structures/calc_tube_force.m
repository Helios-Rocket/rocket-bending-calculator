function f = calc_tube_force(M, D, d)
    Z = pi / (32 * D) * (D^4 - d^4);

    f = M/Z;
end