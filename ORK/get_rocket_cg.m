function [cg, mass, parts, I] = get_rocket_cg(ork, target_stages, verbose)

if nargin < 3
    verbose = false;
end

[cg_num, cg_den, parts] = get_component_cg(ork.subcomponents, 0, 0);

cg = cg_num / cg_den;
mass  = cg_den;

I = sum(cell2mat(parts(:, 2)) .* (cell2mat(parts(:, 1)) - cg).^2);

    function [cg_num, cg_den, parts] = get_component_cg(component, x0, parent_length, parent_radius)

        if isfield(component, 'stage')
            stages = component.stage;
            cg_num = 0;
            cg_den = 0;
            x      = 0;
            parts = {};
            num_stages = numel(stages);
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
                comp_length = get_component_length(stages(n));

                [cg_num_s, cg_den_s, stage_parts] = get_component_cg(stages(n), x, comp_length);

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


        if isfield(component, 'length')
            comp_length = component.length;
        elseif isfield(component, 'packedlength')
            comp_length = component.packedlength;
        else
            comp_length = 0;
        end

        end_length = comp_length;
        cg_loc = comp_length/2;

        x = x0;

        if isfield(component, 'axialoffset')
            x = x + component.axialoffset.Text;
            if strcmp(component.axialoffset.methodAttribute, 'bottom')
                x = x - comp_length + parent_length;
            elseif strcmp(component.axialoffset.methodAttribute, 'middle')
                x = x + parent_length/2;
                cg_loc = 0;
                end_length = comp_length/2;
            elseif strcmp(component.axialoffset.methodAttribute, 'absolute')
                x = x - x0;
            end
        end

        radius = 0;

        if isfield(component, 'outerradius')
            radius = component.outerradius;

            if ~isnumeric(radius)
                if strcmp(radius, 'auto')
                    radius = parent_radius;
                end
            end
        elseif isfield(component, 'radius')
            radius = component.radius;
            if ~isnumeric(radius)
                radius = str2double(erase(radius, 'auto '));
            end
        end

        if isfield(component, 'mass')
            m = component.mass;
        elseif isfield(component, 'overridemass')
            m = component.overridemass;
        elseif isfield(component, 'fincount')
            area = 0.5 * (component.rootchord + component.tipchord) * component.height;
            volume = area * component.thickness;

            m_fin = volume * component.material.densityAttribute;

            k = 0.6;
            fillet_volume = k * component.rootchord * component.filletradius^2 * (1 - pi/4);
            m_fillet      = fillet_volume * component.filletmaterial.densityAttribute;

            m = m_fin + m_fillet*2;

            m = m * component.fincount;
        elseif isfield(component, 'outerradius')
            if ~isnumeric(radius)
                m = 0;
            else
                area = pi*radius^2;
                volume = area * component.length;

                if isfield(component, 'thickness')
                    inner_area = pi*(radius - component.thickness)^2;
                    inner_volume = inner_area * component.length;

                    volume = volume - inner_volume;
                end

                m = volume * component.material.densityAttribute;
            end
        elseif isfield(component, 'radius')
            area = pi*radius^2;
            volume = area * component.length;

            if isfield(component, 'thickness')
                inner_area = pi*(radius - component.thickness)^2;
                inner_volume = inner_area * component.length;

                volume = volume - inner_volume;
            end

            m = volume * component.material.densityAttribute;
        elseif isfield(component, 'packedradius')
            area = pi * component.packedradius^2;
            volume = area * component.packedlength;

            m = volume * component.material.densityAttribute;
        else
            m = 0;
        end

        if verbose
            fprintf("%s : %0.2f cm\n", component.name, x*100)
        end

        if isfield(component, 'shape')
            if strcmp(component.shape, 'ogive')
                cg_loc = comp_length * 2/3;
            end
        end
        x_end = x + end_length;
        
        cg_x = x + cg_loc;

        cg_num = cg_x*m;
        cg_den = m;

        if verbose
            fprintf("\t %0.2f g; %0.2f cm\n\n", m*1000, cg_x*100)
        end

        part = {cg_x, m, x_end, component.id, component.name};
        parts = part;

        if strcmp(component.name, '54mm Adapter Tube')
            disp('!')
        end

        if isfield(component, 'subcomponents')
            subc_list = component.subcomponents;

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