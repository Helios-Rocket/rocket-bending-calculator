function out = remove_auto(in, parent_rad)
    if ~isnumeric(in)
        if strcmp(in, 'auto')
            out = parent_rad;
            return;
        end
        out = str2double(erase(in, "auto "));
    else
        out = in;
    end
end