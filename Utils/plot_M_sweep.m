function fig_idx = plot_M_sweep(num_v, max_v, v0, alpha, M0, rho, R_ref, ork, stages, filename, fig_idx0)

if nargin < 11
    fig_idx0 = 1;
end
fig_idx = fig_idx0;

v_all = linspace(0, max_v, num_v);

data_all = cell(num_v, 1);
cp_all = zeros(num_v, 1);
cna_all = zeros(num_v, 1);

max_M_all = zeros(num_v, 1);

for n = 1:num_v
    v = v_all(n);
    M = v / M0;
    
    data = run_calc(ork, M, alpha, v0, rho, stages, R_ref);
    data_all{n} = data;
    cp_all(n) = data.cp_tot;
    cna_all(n) = data.cna_tot;
    max_M_all(n) = max(data.bending_all(:, 1));
end

%% PLOTTING

plot_bending(ork, M, alpha, stages, data_all{n}, filename, fig_idx0);
fig_idx = fig_idx + 1;

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(v_all / M0, max_M_all, 'LineWidth', 2);
title('Max Bending Moment vs Mach Number')
xlabel('M')
ylabel('Max Bending (Nm)')

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(v_all / M0, cp_all, 'LineWidth', 2);
title("Cp vs Mach Number")
xlabel("M")
ylabel("Cp (m)")

figure(fig_idx)
fig_idx = fig_idx + 1;
clf
plot(v_all / M0, cna_all, 'LineWidth', 2)
title("CN\alpha vs Mach Number")
xlabel("M")
ylabel("CN\alpha")

figure(fig_idx + 1); clf; figure(fig_idx + 2); clf; figure(fig_idx + 3); clf

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

    figure(fig_idx + 1)
    plot(v_all / M0, cp_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp');
    xlabel('Mach Number');
    title('Cp Absolute vs Mach')
    legend

    figure(fig_idx + 2)
    plot(v_all / M0, 100 * (cp_data - start) / the_length, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('Cp (% Component Length)');
    xlabel('Mach Number');
    title('Cp from Component Start vs Mach')
    legend

    figure(fig_idx + 3)
    plot(v_all / M0, cna_data, 'LineWidth', lw, 'DisplayName', name, 'Color', colors(k, :)); hold on
    ylabel('CN_\alpha')
    xlabel('Mach Number');
    title('CN_\alpha vs Mach')
    legend
end
fig_idx = fig_idx + 4;

end