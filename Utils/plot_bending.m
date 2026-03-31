function plot_bending(ork, Mach, alpha, stages, data, filename, fig_idx)

if nargin < 7
    fig_idx = 1;
end

fig = figure(fig_idx);
clf

ax1 = axes( ...
    'Parent', fig, ...
    'XAxisLocation', 'bottom', ...
    'YAxisLocation', 'right', ...
    'Box', 'off');

hold(ax1, 'on')

axes(ax1)
plot_rocket(filename, stages, 1, ork, data.cp_tot, data.cg, data.stage_cp_tot, false)

ax1.XLim = [0, data.rocket_length];
axis(ax1, 'equal')
ax1.XLim = [0, data.rocket_length];

drawnow

ax1.PlotBoxAspectRatioMode = 'manual';
ax1.PositionConstraint = 'innerposition';

ax2 = axes( ...
    'Parent', fig, ...
    'Position', ax1.Position, ...
    'XAxisLocation', 'bottom', ...
    'YAxisLocation', 'left', ...
    'Color', 'none', ...
    'Box', 'off');

hold(ax2, 'on')

plot(ax2, data.points, data.bending_all(:,1), '-k', ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Bending Moment');

plot(ax2, data.points, data.shear_all(:,1), '--k', ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Shear Force');

ax2.XLim = [0, data.rocket_length];
ax2.YLim = [-1, 1] * max([ ...
    abs(data.bending_all(:,1)); ...
    abs(data.shear_all(:,1)); ...
    1e-6 ]);

ax2.PositionConstraint = 'innerposition';
ax2.PlotBoxAspectRatioMode = 'manual';
ax2.PlotBoxAspectRatio = ax1.PlotBoxAspectRatio;
ax2.Position = ax1.Position;

linkaxes([ax1 ax2], 'x')

set(ax1, 'YColor', 'none')
set(ax1, 'XColor', 'none')

xlabel(ax2, "Position (m)")
ylabel(ax2, "Load")

legend(ax2, [findobj(ax2,'-property','DisplayName'); ...
             findobj(ax1,'-property','DisplayName')])

[~, rocket_name] = fileparts(filename);
title(ax2, sprintf("%s\n%0.2f deg AOA |  Mach %0.2f", ...
    rocket_name, rad2deg(alpha), Mach))

uistack(ax1, 'bottom')

num_sections = numel(data.aero_sections);
variable_names = {'Component', 'Cp (cm)', 'CNa'};
rows = {'ROCKET', data.cp_tot*100, data.cna_tot; 
        '------', '------', '------'};

for n = 1:num_sections
    rows = [rows; {convertStringsToChars(data.aero_sections{n}.name), data.aero_sections{n}.Cp*100, data.aero_sections{n}.CNa}];
end

FormattedTable.Display(variable_names, rows)

end