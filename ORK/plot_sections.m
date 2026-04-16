function plot_sections(sections, yscale)

num_sections = numel(sections);

for idx = 1:num_sections
    section = sections{idx};

    x_points = [section.x, section.x, section.x + section.length, section.x + section.length];
    y_points = [-section.forerad, section.forerad, section.aftrad+eps, -section.aftrad-eps] / yscale;

    if y_points(1) == y_points(2)
        y_points = y_points(2:end);
        x_points = x_points(2:end);
    end

    if section.material == "Fiberglass"
        color = [0.7, 0.1, 0.1];
    elseif section.material == "Cardboard"
        color = [0.6, 0.4, 0.15];
    else
        color = [0.4, 0.4, 0.4];
    end

    plot(polyshape(x_points, y_points), 'FaceColor', color, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on

    if isfield(section, 'subcomponents')
        subcomponents = section.subcomponents;
        if isfield(subcomponents, 'trapezoidfinset')
            finset = section.subcomponents.trapezoidfinset;

            cr = finset.rootchord;
            ct = finset.tipchord;
            xr = finset.sweeplength;
            s  = finset.height;

            x0 = section.x + finset.axialoffset.Text;

            if strcmp(finset.axialoffset.method, 'bottom')
                x0 = x0 + section.length - cr;
            end
            
            x_points = [x0, x0 + xr, x0 + xr + ct, x0 + cr];
            y_points = [0, s, s, 0] / yscale;

            y_top = section.forerad/yscale + y_points;
            y_bottom = -y_top;

            plot(polyshape(x_points, y_top), 'FaceColor', color/2, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on
            plot(polyshape(x_points, y_bottom), 'FaceColor', color/2, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on
        elseif isfield(subcomponents, 'freeformfinset')
            finset = section.subcomponents.freeformfinset;
            points = [finset.finpoints.point{:}];
            x0 = section.x + section.length + finset.axialoffset.Text - tail([points.x]',1);
            x_points = [points.x] + x0;
            y_points = ([points.y] + section.forerad) / yscale;

            plot(polyshape(x_points, y_points), 'FaceColor', color/2, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on
            plot(polyshape(x_points, -y_points), 'FaceColor', color/2, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on
        end
    end

end
end