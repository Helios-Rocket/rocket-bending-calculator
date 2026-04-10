function sections = get_sections_at_pos(all_sections, x)
    num_sections = length(all_sections);

    sections = {};
    section_idx = 1;

    for n = 1:num_sections
        section_start = all_sections{n}.x;
        section_end   = all_sections{n}.x + all_sections{n}.length;
        if section_start < x && x < section_end
            section = all_sections{n};
            sections{section_idx} = section;
            section_idx = section_idx + 1;
        end
    end
end