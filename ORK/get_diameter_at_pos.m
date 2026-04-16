function [D, d] = get_diameter_at_pos(sections, x)
    num_sections = length(sections);
    D = 0;
    d = 0;

    for n = 1:num_sections
        section = sections{n};
        section_start = section.x;
        section_end   = section.x + section.length;

        if section.x == 0
            continue
        end

        if section_start < x && x < section_end
            diff = (section.D - section.d);
            if diff > 0.02 
                section.D = inf;
            else

            % while section.length < 0.06
            %     n = n - 1;
            %     section = sections{n};
            %     diff = (section.D - section.d);
            % end
            end

            section = sections{n};
            d = section.d;
            D = section.D;
            return;
        end
    end
end