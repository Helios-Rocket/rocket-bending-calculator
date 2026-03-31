clear; clc;

M0 = 340.3; % Mach at sea level [m/s]
rho = 1.225; % [kg m^-3]

alpha = deg2rad(10);
v = 100;

stages = [1, 2];

filename = "HeliosRocketV3.ork";
% filename = "Voyager rough canards v2 (1).ork";
% filename = "V9 (2-Stage 6in) Test Rocket.ork";
% filename   = "V4 (30k) RAS Test Rocket.ork";
ork = load_ork(filename);
sections = load_sections(ork);

R_ref = get_R_ref(sections);
M = v / M0;

data = run_calc(ork, M, alpha, v, rho, stages, R_ref);
plot_bending(ork, M, alpha, stages, data, filename);


%{
num_v = 100;
max_v = 800;
plot_sweep(num_v, max_v, alpha, M0, rho, R_ref, ork, stages, filename)
%}