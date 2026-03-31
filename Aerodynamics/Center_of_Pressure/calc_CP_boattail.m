function CP = calc_CP_boattail(R_lower, R_upper, L)

dr = R_upper*2;
d  = R_lower*2;

CP = L/3 * (1 + (1 - d/dr) / (1 - d^2/dr^2));

end