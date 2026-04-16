function plot_ork(ork, stages, yscale)

if nargin < 2
    stages = 1:10;
end

sections = load_sections(ork);
plot_sections(sections, stages, yscale);
end