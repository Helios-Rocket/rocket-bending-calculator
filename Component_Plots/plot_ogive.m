clear; clc;
cna_ogive_data = readtable("cnalpha_ogive_data.csv");
cp_ogive_data = readtable("cp_ogive_data.csv");

figure(1)
clf

r = 1;
l = 10;
r_ref = 1;

num_Ms = 1000;

M_all = linspace(0, 3, num_Ms);
cna_all = zeros(num_Ms, 1);
cp_all = zeros(num_Ms, 1);

alpha = 0;

for i = 1:num_Ms
    M = M_all(i);
    cna_all(i) = calc_CNa_ogive(r, l, r_ref, alpha, M, cna_ogive_data);
    cp_all(i) = calc_CP_ogive(l, r, r_ref, alpha, M);
end

figure(1)
clf
plot(M_all, cp_all);
xlabel("Mach Number")
ylabel("Ogive Cp (cm)")
title("Ogive Center of Pressure vs Mach Number")

figure(2)
clf
plot(M_all, cna_all);
xlabel("Mach Number")
ylabel("CN\alpha")
title("Ogive CN\alpha vs Mach Number")