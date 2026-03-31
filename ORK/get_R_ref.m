function R_ref = get_R_ref(sections)
R_ref = -inf;
for n = 1:length(sections)
    R_ref = max(R_ref, sections{n}.aftrad);
end
end