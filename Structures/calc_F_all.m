function [F, F_list] = calc_F_all(aero_sections, S, V, rho, alpha)

    q = 0.5*rho*V^2;

    num_sections = numel(aero_sections);
    F = 0;

    F_list = zeros(num_sections, 1);
    
    for n = 1:num_sections
        section = aero_sections{n};
        F_list(n) = calc_N(q, S, alpha, section.CNa);
    end
    F = sum(F_list);
end