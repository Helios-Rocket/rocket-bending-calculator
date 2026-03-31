function data_out = run_calc(ork, Mach, alpha, v, rho, stages, R_ref, S, num_points)

[cp_tot, cna_tot, aero_sections, stage_cp_tot, stage_cna_tot] = get_aerodynamics(ork, Mach, alpha, R_ref, stages);

[cg, mass, parts_all, I] = get_rocket_cg(ork, stages);

parts = cell2mat(parts_all(:, 1:3));

[F, F_list] = calc_F_all(aero_sections, S, v, rho, alpha);
R = calc_R_all(aero_sections, S, v, rho, alpha, I, cg);

rocket_length = max(parts(:, 3));

%{
part_stages = cell2mat(parts_all(:, 6));
num_stages = length(stages);

if num_stages > 1
    rocket_length = 0;
    for n = 1:num_stages
        rocket_length = max(rocket_length, max(parts(part_stages == stages(n), 3)));
    end
else
    rocket_length = max(parts(part_stages == stages, 3));
end
%}

if nargin < 9
    num_points = 1000;
end

points = linspace(0, rocket_length, num_points);

shear_all   = zeros(num_points, 1);
bending_all = zeros(num_points, 4);

for n = 1:num_points
    xk = points(n);
    V = calc_shear(xk, parts, F, R, mass, cg, F_list, aero_sections);
    [M, trans_term, rot_term, lift_term] = calc_bending(xk, parts, F, R, mass, cg, F_list, aero_sections);

    shear_all(n) = V;
    bending_all(n, :) = [M, trans_term, rot_term, lift_term];
end

data_out = struct( ...
    'cp_tot', cp_tot, ...
    'cna_tot', cna_tot, ...
    'F', F, ...
    'cg', cg, ...
    'mass', mass, ...
    'rocket_length', rocket_length ...
    );
data_out.stage_cp_tot  =  stage_cp_tot;
data_out.stage_cna_tot =  stage_cna_tot;
data_out.aero_sections =  aero_sections;
data_out.parts_all     =  parts_all;
data_out.shear_all     =  shear_all;
data_out.bending_all   =  bending_all;
data_out.points        = points;


end