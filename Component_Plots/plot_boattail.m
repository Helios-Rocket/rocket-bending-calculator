clear; clc; close all;

r_upper = 8;
r_lower = 5;
l       = 10;
r_ref = r_upper;

num_M = 1000;
M_all = linspace(0, 3, num_M);
cp_all = zeros(num_M, 1);
cna_all = zeros(num_M, 1);

alpha = 0;

for n = 1:num_M
    M = M_all(n);
    cp_all(n) = calc_CP_boattail(r_lower, r_upper, l);

    CNa = calc_CNa_boattail(r_lower, r_upper, l, r_ref, M);
    cna_all(n) = CNa;
end

figure(1)
clf
plot(M_all, cp_all);
xlabel("Mach Number")
ylabel("Boattail Cp (cm)")
title("Boattail Center of Pressure vs Mach Number")

figure(2)
clf
plot(M_all, cna_all);
xlabel("Mach Number")
ylabel("CN\alpha")
title("Boattail CN\alpha vs Mach Number")