function plot_rocket(filename, stages, yscale, ork, cp_tot, cg)
plot_ork(ork, stages, yscale);

num_stages = numel(stages);
num_stages_real = numel(ork);
colors = turbo(num_stages + 1);
lw = 3;

plot(cp_tot, 0, '.r', 'MarkerSize', 30, 'DisplayName', 'Center of Pressure')
plot(cp_tot, 0, 'or', 'MarkerSize', 14, 'LineWidth', 1, 'HandleVisibility', 'off')
plot(cg, 0, '.b', 'MarkerSize', 40, 'DisplayName', 'Center of Gravity')

% if draw_cps
% 
%     for n = 1:num_stages
%         stage_idx = num_stages_real - stages(n) + 1;
%         xline(stage_cp_tot(n), 'Color', colors(1+n, :), 'LineWidth', lw, 'DisplayName', sprintf("CP; Stage %d", stage_idx));
%     end
% end

end