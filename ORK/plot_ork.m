function plot_ork(filename, stages, yscale)
ork = load_ork(filename);

if nargin < 2
    stages = 1:10;
end

sections = load_sections(ork);
plot_sections(sections, stages, yscale);
end