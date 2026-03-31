function fig_idx = plot_AOA_sweep(num_aoa, max_aoa, v, M0, rho, R_ref, ork, stages, filename, fig_idx0)

if nargin < 10
    fig_idx0 = 1;
end
fig_idx = fig_idx0;


aoa_all = linspace(0, max_aoa, num_aoa);

data_all = cell(num_aoa, 1);
cp_all = zeros(num_aoa, 1);
cna_all = zeros(num_aoa, 1);

max_M_all = zeros(num_aoa, 1);

for n = 1:num_aoa
    aoa = aoa_all(n);
    M = v / M0;
    
    data = run_calc(ork, M, deg2rad(aoa), v, rho, stages, R_ref);
    data_all{n} = data;
    cp_all(n) = data.cp_tot;
    cna_all(n) = data.cna_tot;
    max_M_all(n) = max(data.bending_all(:, 1));
end

%% PLOTTING

plot_bending(ork, M, deg2rad(aoa), stages, data_all{n}, filename, fig_idx);
fig_idx = fig_idx + 1;

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(aoa_all, max_M_all, 'LineWidth', 2);
title('Max Bending Moment vs AOA')
xlabel('AOA (deg)')
ylabel('Max Bending (Nm)')

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(aoa_all, cp_all, 'LineWidth', 2);
title("Cp vs AOA")
xlabel("AOA (deg)")
ylabel("Cp (m)")

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(aoa_all, cna_all, 'LineWidth', 2)
title("CN\alpha vs AOA")
xlabel("AOA (deg)")
ylabel("CN\alpha")

figure(fig_idx + 1); clf; figure(fig_idx + 2); clf; figure(fig_idx + 3); clf

num_sections = numel(data.aero_sections);
colors = turbo(num_sections);
lw = 2;
for k = 1:num_sections
    cp_data  = zeros(num_aoa, 1);
    cna_data = zeros(num_aoa, 1);
    for n = 1:num_aoa
        cp_data(n)  = data_all{n}.aero_sections{k}.Cp;
        cna_data(n) = data_all{n}.aero_sections{k}.CNa;
    end

    name = data_all{n}.aero_sections{k}.name;
    start = data_all{n}.aero_sections{k}.x;
    the_length = data_all{n}.aero_sections{k}.length;

    figure(fig_idx + 1)
    plot(aoa_all, cp_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp');
    xlabel('AOA (deg)');
    title('Cp Absolute vs AOA')
    legend

    figure(fig_idx + 2)
    plot(aoa_all, 100 * (cp_data - start) / the_length, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp (% Component Length)');
    xlabel('AOA (deg)');
    title('Cp from Component Start vs AOA')
    legend

    figure(fig_idx + 3)
    plot(aoa_all, cna_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('CN_\alpha')
    xlabel('AOA (deg)');
    title('CN_\alpha vs AOA')
    legend
end

fig_idx = fig_idx + 4;

end