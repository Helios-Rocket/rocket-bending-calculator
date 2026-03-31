function xcp_over_d = nosecone_Cp(Mach_query, LN_over_d_query, csv_data)

if nargin < 3
    csv_file = 'cp_ogive_data.csv';
    csv_data = readtable(csv_file);
end

mach_grid = csv_data.Mach(:);
ratio_grid = [1.5, 2, 3, 4, 5, 6, 7];
xcp_grid = csv_data{:, 2:end};

[Mach_mesh, Ratio_mesh] = ndgrid(mach_grid, ratio_grid);

xcp_over_d = interp2( ...
    Ratio_mesh, Mach_mesh, xcp_grid, ...
    LN_over_d_query, Mach_query, ...
    'makima');

end