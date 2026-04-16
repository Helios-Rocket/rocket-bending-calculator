function [cg, mass, parts, I] = get_rocket_cg(ork, target_stages, verbose)

if nargin < 3
    verbose = false;
end

[cg_num, cg_den, parts] = get_component_cg(ork, 0, 0);

cg = cg_num / cg_den;
mass  = cg_den;

I = sum(cell2mat(parts(:, 2)) .* (cell2mat(parts(:, 1)) - cg).^2);

    function [cg_num, cg_den, parts] = get_component_cg(component, x0, parent_length, parent_radius)

        if isfield(component, 'Components')
            cg_num = 0;
            cg_den = 0;
            x      = 0;
            parts = {};
            num_stages = numel(component);
            for n = 1:num_stages
                stage_idx = num_stages + 1 - n;
                if length(target_stages) > 1
                    if ~find(target_stages, stage_idx)
                        continue
                    end
                else
                    if target_stages ~= stage_idx
                        continue
                    end
                end
                comp_length = get_component_length(component(n));

                [cg_num_s, cg_den_s, stage_parts] = get_component_cg(component(n).Components, x, comp_length);

                for i = 1:length(stage_parts)
                    stage_parts{i, 6} = n;
                end

                x = x + comp_length;

                cg_num = cg_num + cg_num_s;
                cg_den = cg_den + cg_den_s;

                parts = [parts; stage_parts];
            end
            return
        end

        if isfield(component,'Data')
            comp = component.Data;
        else
            comp = component;
        end

        if isfield(comp, 'length')
            comp_length = comp.length;
        elseif isfield(comp, 'packedlength')
            comp_length = comp.packedlength;
        else
            comp_length = 0;
        end

        end_length = comp_length;
        cg_loc = comp_length/2;

        x = x0;

        if isfield(comp, 'axialoffset')
            x = x + comp.axialoffset.Text;
            if strcmp(comp.axialoffset.method, 'bottom')
                x = x - comp_length + parent_length;
            elseif strcmp(component.axialoffset.method, 'middle')
                x = x + parent_length/2;
                cg_loc = 0;
                end_length = comp_length/2;
            elseif strcmp(component.axialoffset.method, 'absolute')
                x = x - x0;
            end
        end

        radius = 0;

        if isfield(comp, 'outerradius')
            radius = remove_auto(comp.outerradius);

        elseif isfield(comp, 'radius')
            radius = remove_auto(comp.radius);
        end

        if isfield(comp, 'mass')
            m = comp.mass;
        elseif isfield(comp, 'overridemass')
            m = comp.overridemass;
        elseif isfield(comp, 'fincount')
            k = 0.6;
            if(isfield(comp, 'finpoints')) % if fins are freeform
                area = polyarea([comp.finpoints.point.x],[comp.finpoints.point.y]);
                fillet_volume = k * tail([comp.finpoints.point.x]',1) * comp.filletradius^2 * (1 - pi/4);
            else
                area = 0.5 * (comp.rootchord + comp.tipchord) * comp.height;
                fillet_volume = k * comp.rootchord * comp.filletradius^2 * (1 - pi/4);
            end
            volume = area * comp.thickness;

            m_fin = volume * comp.material.density;
            
            m_fillet      = fillet_volume * comp.filletmaterial.density;

            m = m_fin + m_fillet*2;

            m = m * comp.fincount;
        elseif isfield(comp, 'outerradius')
            if ~isnumeric(radius)
                m = 0;
            else
                area = pi*radius^2;
                volume = area * comp.length;

                if isfield(comp, 'thickness')
                    inner_area = pi*(radius - comp.thickness)^2;
                    inner_volume = inner_area * comp.length;

                    volume = volume - inner_volume;
                end

                m = volume * comp.material.density;
            end
        elseif isfield(comp, 'radius')
            area = pi*radius^2;
            volume = area * comp.length;

            if isfield(comp, 'thickness')
                inner_area = pi*(radius - comp.thickness)^2;
                inner_volume = inner_area * comp.length;

                volume = volume - inner_volume;
            end

            m = volume * comp.material.density;
        elseif isfield(comp, 'packedradius')
            
            packedradius = comp.packedradius;

            if ~isnumeric(packedradius)
                packedradius = str2double(erase(packedradius, 'auto '));
            end


            area = pi * packedradius^2;
            volume = area * comp.packedlength;

            m = volume * comp.material.density;
        else
            m = 0;
        end

        if verbose
            fprintf("%s : %0.2f cm\n", comp.name, x*100)
        end

        if isfield(comp, 'shape')
            if strcmp(comp.shape, 'ogive')
                cg_loc = comp_length * 2/3;
            end
        end
        x_end = x + end_length;
        
        cg_x = x + cg_loc;

        if isa(m, 'missing')
            m = 0;
        end

        cg_num = cg_x*m;
        cg_den = m;

        if verbose
            fprintf("\t %0.2f g; %0.2f cm\n\n", m*1000, cg_x*100)
        end

        part = {cg_x, m, x_end, comp.id, comp.name};
        parts = part;

        if isfield(comp, 'subcomponents')
            subc_list = comp.subcomponents;

            fields = fieldnames(subc_list);
            length_before = 0;

            for nf = 1:numel(fields)
                name = fields{nf};
                subc = subc_list.(name);

                for n = 1:numel(subc)
                    len_add = length_before;
                    if strcmp(name, 'tubecoupler') || strcmp(name, 'railbutton') || strcmp(name, 'bulkhead') || strcmp(name, 'innertube')
                        len_add = 0;
                    end

                    [cg_num_sub, cg_den_sub, sub_parts] = get_component_cg(subc(n), x + len_add, comp_length, radius);
                    cg_num = cg_num + cg_num_sub;
                    cg_den = cg_den + cg_den_sub;

                    parts = [parts; sub_parts];
                    
                    if ~(strcmp(name, 'tubecoupler') || strcmp(name, 'railbutton') || strcmp(name, 'bulkhead') || strcmp(name, 'innertube'))
                        length_before = length_before + get_component_length(subc(n));
                    end
                end
            end
        end
    end
end