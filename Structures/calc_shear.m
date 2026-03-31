function [V, trans_term, rot_term, lift_term] = calc_shear(xk, parts, F_all, R, m, x_cg, F_list, aero_sections)

num_aero_sections = numel(aero_sections);

lift_term = 0;

for n = 1:num_aero_sections
    cp = aero_sections{n}.Cp;

    if xk <= cp
        continue
    end

    L = F_list(n);
    lift_term = lift_term + L;
end

a = F_all / m;

parts_new = parts(parts(:,1) <= xk, :);

xm = parts_new(:,1);
m_part = parts_new(:,2);

trans_term = a * sum(m_part);

arm_cg = x_cg - xm;
rot_term = R * sum(m_part .* arm_cg);

V = lift_term - trans_term - rot_term;
end