function out = remove_auto(in)
    if ~isnumeric(in)
        out = str2double(erase(in, "auto "));
    else
        out = in;
    end
end