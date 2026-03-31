clear; clc; close all;

d = 2;
R_body = d / 2;

fins = struct( ...
    'cr', 5, ...
    'ct', 5, ...
    's', 3, ...
    'xr', 2.5, ...
    'R_body', R_body, ...
    'R_ref', R_body);

num_M = 1000;
M_all = linspace(0, 3, num_M);
cp_all = zeros(num_M, 1);
cna_all = zeros(num_M, 1);
B_all   = zeros(num_M, 1);

alpha = 0;

for n = 1:num_M
    M = M_all(n);
    cp_all(n) = calc_CP_fins(fins, M);

    [CNa, KT, B] = calc_CNa_fins(fins, M, alpha);
    cna_all(n) = CNa;
    B_all(n) = B;
end

figure(1)
clf
plot(M_all, cp_all);
xlabel("Mach Number")
ylabel("Fin Cp (cm)")
title("Fin Center of Pressure vs Mach Number")

figure(2)
clf
plot(M_all, cna_all);
xlabel("Mach Number")
ylabel("CN\alpha")
title("Fin CN\alpha vs Mach Number")