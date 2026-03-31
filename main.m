clear; clc; close all;

M0 = 340.3; % Mach at sea level [m/s]
rho = 1.225; % [kg m^-3]

alpha = deg2rad(3);

stages = [1, 2];

filename = "HeliosRocketV3.ork";
% filename = "Voyager rough canards v2 (1).ork";
% filename = "V9 (2-Stage 6in) Test Rocket.ork";
ork = load_ork(filename);
sections = load_sections(ork);
num_sections = numel(sections);

R_ref = -inf;

for n = 1:num_sections
    R_ref = max(R_ref, sections{n}.aftrad);
end

S = pi*R_ref^2;

num_v = 100;
v_all = linspace(0, 800, num_v);

v = 300; % [m/s]
M     = v / M0;

data_all = cell(num_v, 1);
cp_all = zeros(num_v, 1);
cna_all = zeros(num_v, 1);

for n = 1:num_v
    v = v_all(n);
    M = v / M0;
    
    data = run_calc(ork, M, alpha, v, rho, stages, R_ref, S);
    data_all{n} = data;
    cp_all(n) = data.cp_tot;
    cna_all(n) = data.cna_tot;
end

plot_bending(ork, M, alpha, stages, data_all{n}, filename);

figure(2)
clf
plot(v_all / M0, cp_all, 'LineWidth', 2);
title("Cp vs Mach Number")
xlabel("M")
ylabel("Cp (m)")

figure(3)
clf
plot(v_all / M0, cna_all, 'LineWidth', 2)
title("CN\alpha vs Mach Number")
xlabel("M")
ylabel("CN\alpha")