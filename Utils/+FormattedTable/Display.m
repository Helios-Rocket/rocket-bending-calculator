function Display(variable_names, rows)
    T = FormattedTable.Generate(variable_names, rows);
    disp(T);
end
