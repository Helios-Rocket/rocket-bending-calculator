clear; clc;

M0 = 340.3; % Mach at sea level [m/s]
rho = 1.225; % [kg m^-3]

alpha = deg2rad(0);
num_v = 1;
max_v = 100;

stages = [1, 2];

% filename = "HeliosRocketV3.ork";
% filename = "Voyager rough canards v2 (1).ork";
% filename = "V9 (2-Stage 6in) Test Rocket.ork";
filename   = "V4 (30k) RAS Test Rocket.ork";
ork = load_ork(filename);
sections = load_sections(ork);
num_sections = numel(sections);

R_ref = -inf;

for n = 1:num_sections
    R_ref = max(R_ref, sections{n}.aftrad);
end

A_ref = pi * R_ref^2;

S = pi*R_ref^2;

v_all = linspace(0, max_v, num_v);

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

%% PLOTTING

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

figure(4); clf; figure(5); clf; figure(6); clf

num_sections = numel(data.aero_sections);
colors = turbo(num_sections);
lw = 2;
for k = 1:num_sections
    cp_data  = zeros(num_v, 1);
    cna_data = zeros(num_v, 1);
    for n = 1:num_v
        cp_data(n)  = data_all{n}.aero_sections{k}.Cp;
        cna_data(n) = data_all{n}.aero_sections{k}.CNa;
    end

    name = data_all{n}.aero_sections{k}.name;
    start = data_all{n}.aero_sections{k}.x;
    the_length = data_all{n}.aero_sections{k}.length;

    figure(4)
    plot(v_all / M0, cp_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp');
    xlabel('Mach Number');
    title('Cp Absolute vs Mach')
    legend

    figure(5)
    plot(v_all / M0, 100 * (cp_data - start) / the_length, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp (% Component Length)');
    xlabel('Mach Number');
    title('Cp from Component Start vs Mach')
    legend

    figure(6)
    plot(v_all / M0, cna_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('CN_\alpha')
    xlabel('Mach Number');
    title('CN_\alpha vs Mach')
    legend
end