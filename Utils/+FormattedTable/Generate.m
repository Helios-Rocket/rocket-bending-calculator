function T = Generate(variable_names, rows)
    T = array2table(rows, 'VariableNames', variable_names);
    for i=1:length(T.Properties.VariableNames)
        variable_name = T.Properties.VariableNames{i};
        % Format value cells
        T.(variable_name) = cellfun(@(x) formatValue(x), T.(variable_name), 'UniformOutput', false);
        T.(variable_name) = categorical(T.(variable_name));
    end
end
function formattedString = formatValue(value)
    if isnumeric(value) && isscalar(value)
        % Apply scientific notation for small or large values
        if (abs(value) >= 1e5 || (abs(value) < 1e-4) && value ~= 0)
            formattedString = sprintf('%0.3e', value);
        else
            formattedString = sprintf('%0.3f', value);
        end
    % Numeric arrays
    elseif isnumeric(value) && ~isscalar(value)
        formattedString = strjoin(arrayfun(@(value) formatValue(value), value, 'UniformOutput', false), ', ');
    % Don't format strings
    else
        formattedString = value;
    end
end