function R = calc_R_all(aero_sections, S, V, rho, alpha, I, cg)

q = 0.5*rho*V^2;

num_sections = numel(aero_sections);
R = 0;

for n = 1:num_sections
    section = aero_sections{n};
    N = calc_N(q, S, alpha, section.CNa);

    L = cg - section.Cp;

    R = R + L * N;
end

R = R / I;
end