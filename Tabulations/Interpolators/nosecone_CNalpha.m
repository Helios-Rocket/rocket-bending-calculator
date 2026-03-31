function CNalpha = nosecone_CNalpha(Mach_query, LN_over_d_query, csv_data)
% Load CNalpha table from CSV and interpolate in Mach and L_N/d

if nargin < 3
    csv_file = 'cnalpha_ogive_data.csv';
    csv_data = readtable(csv_file);
end

mach_grid = csv_data.Mach(:);
ratio_grid = [1.5, 3, 5, 7];
CN_grid = csv_data{:, 2:end};

[Mach_mesh, Ratio_mesh] = ndgrid(mach_grid, ratio_grid);

CNalpha = interp2( ...
    Ratio_mesh, Mach_mesh, CN_grid, ...
    LN_over_d_query, Mach_query, ...
    'makima');

end
