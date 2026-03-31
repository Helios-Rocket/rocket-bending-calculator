function plot_nosecone_CNalpha()
% --- Load raw data ---
T = readtable('cnalpha_ogive_data.csv');

mach_grid = T.Mach(:);
ratio_grid = [1.5, 3, 5, 7];
CN_grid = T{:, 2:end};

% --- Create fine grid ---
mach_plot  = linspace(min(mach_grid), max(mach_grid), 150);
ratio_plot = linspace(min(ratio_grid), max(ratio_grid), 150);

[Mach_mesh, Ratio_mesh] = ndgrid(mach_plot, ratio_plot);

% --- Evaluate interpolation USING YOUR FUNCTION ---

CN_interp = nosecone_CNalpha(Mach_mesh, Ratio_mesh);

% --- Plot surface ---
surf(Mach_mesh, Ratio_mesh, CN_interp, 'LineStyle', 'none')
hold on

% --- Plot raw data ---
[Mach_data, Ratio_data] = ndgrid(mach_grid, ratio_grid);

scatter3( ...
    Mach_data(:), ...
    Ratio_data(:), ...
    CN_grid(:), ...
    100, 'filled')

xlabel('Mach')
ylabel('L_N/d')
zlabel('C_{N\alpha}')
title('C_{N\alpha} Interpolation vs Raw Data')

grid on
view(135, 30)
end