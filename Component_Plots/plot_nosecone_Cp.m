function plot_nosecone_Cp()

T = readtable('cp_ogive_data.csv');

mach_grid = T.Mach(:);
ratio_grid = [1.5, 2, 3, 4, 5, 6, 7];
xcp_grid = T{:, 2:end};

mach_plot = linspace(min(mach_grid), max(mach_grid), 150);
ratio_plot = linspace(min(ratio_grid), max(ratio_grid), 150);

[Mach_mesh, Ratio_mesh] = ndgrid(mach_plot, ratio_plot);

xcp_interp = nosecone_Cp(Mach_mesh, Ratio_mesh);

surf(Mach_mesh, Ratio_mesh, xcp_interp, 'LineStyle', 'none')
hold on

[Mach_data, Ratio_data] = ndgrid(mach_grid, ratio_grid);

scatter3( ...
    Mach_data(:), ...
    Ratio_data(:), ...
    xcp_grid(:), ...
    100, 'filled')

xlabel('Mach')
ylabel('L_N/d')
zlabel('x_{cp}/d')
title('x_{cp}/d Interpolation vs Raw Data')

grid on
view(135, 30)
end