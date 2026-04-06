clear; clc;

M0 = 340.3; % Mach at sea level [m/s]
rho = 1.225; % [kg m^-3]

alpha = deg2rad(6);
v = M0*0.8;

stages = [1, 2];

filename = "HeliosRocketV3.ork";
% filename = "Voyager rough canards v2 (2).ork";
% filename = "V9 (2-Stage 6in) Test Rocket.ork";
% filename   = "V4 (30k) RAS Test Rocket.ork";
% filename = "Rocket 2024-2025_V17.ork";
ork = load_ork(filename);
sections = load_sections(ork);

R_ref = get_R_ref(sections);
M = v / M0;

fig_idx = 1;
%{
data = run_calc(ork, M, alpha, v, rho, stages, R_ref);
plot_bending(ork, M, alpha, stages, data, filename, fig_idx);
fig_idx = fig_idx + 1;
%}
num = 50;

v_all =         linspace(0.5*M0, 1.5*M0, num);
alpha_all = deg2rad(linspace(0, 6, num));

[X, Y] = meshgrid(v_all, alpha_all);

data_all = cell(num, num);
cp_all = zeros(num, num);
cna_all = zeros(num, num);

v0 = 100;

for n = 1:num
    v = v_all(n);
    M = v / M0;

    for i = 1:num
        alpha = alpha_all(i);

        data = run_calc(ork, M, alpha, v0, rho, stages, R_ref);

        cna_all(i, n) = data.cna_tot * alpha;
    end
end

%% PLOT
figure(1)
clf
surf(X / M0, rad2deg(Y), cna_all, 'LineStyle', 'none');

xlabel('Mach Number')
ylabel('AOA (deg)')
zlabel('CNa')

return

for n = 1:num_v
    v = v_all(n);
    M = v / M0;
    
    data = run_calc(ork, M, alpha, v0, rho, stages, R_ref);
    data_all{n} = data;
    cp_all(n) = data.cp_tot;
    cna_all(n) = data.cna_tot;
    max_M_all(n) = max(data.bending_all(:, 1));
end

return

num_v = 100;
max_v = 1.5*M0;
fig_idx = plot_M_sweep(num_v, max_v, 100, alpha, M0, rho, R_ref, ork, stages, filename, fig_idx);

num_aoa = 100;
max_aoa = 6;
fig_idx = plot_AOA_sweep(num_aoa, max_aoa, 100, M0, rho, R_ref, ork, stages, filename, fig_idx);
