function [cg, mass, parts, I] = get_rocket_cg(ork, verbose)

if nargin < 2
    verbose = false;
end

cg_num = 0;
cg_den = 0;
parts = {};
X = 0;
for ii = 1:size(ork,2)
    [cg_num_s, cg_den_s, parts_s] = get_component_cg(ork(ii).Data, X, 0, 0);
    X = parts_s{1,3};
    cg_num = cg_num + cg_num_s;
    cg_den = cg_den + cg_den_s;
    parts = [parts; parts_s];
end

cg = cg_num / cg_den;
mass  = cg_den;

I = sum(cell2mat(parts(:, 2)) .* (cell2mat(parts(:, 1)) - cg).^2);

    function [cg_num, cg_den, parts] = get_component_cg(component, x0, parent_length, parent_radius)

        % if isfield(component, 'Components')
        %     cg_num = 0;
        %     cg_den = 0;
        %     x      = 0;
        %     parts = {};
        %     num_stages = numel(component);
        %     for n = 1:num_stages
        %         stage_idx = num_stages + 1 - n;
        %         if length(target_stages) > 1
        %             if ~find(target_stages, stage_idx)
        %                 continue
        %             end
        %         else
        %             if target_stages ~= stage_idx
        %                 continue
        %             end
        %         end
        %         comp_length = get_component_length(component(n));
        % 
        %         [cg_num_s, cg_den_s, stage_parts] = get_component_cg(component(n).Components, x, comp_length);
        % 
        %         for i = 1:length(stage_parts)
        %             stage_parts{i, 6} = n;
        %         end
        % 
        %         x = x + comp_length;
        % 
        %         cg_num = cg_num + cg_num_s;
        %         cg_den = cg_den + cg_den_s;
        % 
        %         parts = [parts; stage_parts];
        %     end
        %     return
        % end

        % comp_length = get_component_length(component);

        % [cg_num, cg_den, parts] = get_component_cg(component, x0, comp_length);

        % for i = 1:length(stage_parts)
        %     stage_parts{i, 6} = n;
        % end

        % x = x + comp_length;

        % cg_num = cg_num + cg_num_s;
        % cg_den = cg_den + cg_den_s;

        % parts = [parts; stage_parts];
        
        % if ~isfield(component,'Data')

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
                if strcmp(component.axialoffset.method, 'bottom')
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
    
            if isfield(component, 'outerradius')
                radius = remove_auto(component.outerradius, parent_radius);
    
            elseif isfield(component, 'radius')
                radius = remove_auto(component.radius, parent_radius);
            end
    
            if isfield(component, 'mass')
                m = component.mass;
            elseif isfield(component, 'overridemass')
                m = component.overridemass;
            elseif isfield(component, 'fincount')
                k = 0.6;
                if(isfield(component, 'finpoints')) % if fins are freeform
                    points = [component.finpoints.point{:}];
                    area = polyarea([points.x],[points.y]);
                    fillet_volume = k * tail([points.x]',1) * component.filletradius^2 * (1 - pi/4);
                else
                    area = 0.5 * (component.rootchord + component.tipchord) * component.height;
                    fillet_volume = k * component.rootchord * component.filletradius^2 * (1 - pi/4);
                end
                volume = area * component.thickness;
    
                m_fin = volume * component.material.density;
                
                m_fillet      = fillet_volume * component.filletmaterial.density;
    
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
    
                    m = volume * component.material.density;
                end
            elseif isfield(component, 'radius')
                area = pi*radius^2;
                volume = area * component.length;
    
                if isfield(component, 'thickness')
                    inner_area = pi*(radius - component.thickness)^2;
                    inner_volume = inner_area * component.length;
    
                    volume = volume - inner_volume;
                end
    
                m = volume * component.material.density;
            elseif isfield(component, 'packedradius')
                
                packedradius = component.packedradius;
    
                if ~isnumeric(packedradius)
                    packedradius = str2double(erase(packedradius, 'auto '));
                end
    
    
                area = pi * packedradius^2;
                volume = area * component.packedlength;
    
                m = volume * component.material.density;
            else
                m = 0;
            end
            
            % if ~iscell(component)
                if verbose
                    fprintf("%s : %0.2f cm\n", component.name, x*100)
                end
            % end
    
            if isfield(component, 'shape')
                if strcmp(component.shape, 'ogive')
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
    
            part = {cg_x, m, x_end, component.id, component.name};
            parts = part;

            if isfield(component,'subcomponents')
                subc_list = component.subcomponents;

                fields = fieldnames(subc_list);
                length_before = 0;
    
                for nf = 1:size(fields,1)
                    name = fields{nf};
                    subc = subc_list.(name);
    
                    for n = 1:numel(subc)
                        len_add = length_before;
                        if strcmp(name, 'tubecoupler') || strcmp(name, 'railbutton') || strcmp(name, 'bulkhead') || strcmp(name, 'innertube')
                            len_add = 0;
                        end
                        
                        if iscell(subc)
                            subcn = subc{n};
                        else
                            subcn = subc(n);
                        end

                        [cg_num_sub, cg_den_sub, sub_parts] = get_component_cg(subcn, x + len_add, comp_length, radius);
                        cg_num = cg_num + cg_num_sub;
                        cg_den = cg_den + cg_den_sub;
    
                        parts = [parts; sub_parts];
                        
                        if ~(strcmp(name, 'tubecoupler') || strcmp(name, 'railbutton') || strcmp(name, 'bulkhead') || strcmp(name, 'innertube'))
                            length_before = length_before + get_component_length(subcn);
                        end
                    end
                end
            end

        % else
        if isfield(component,'Data')
            for i = 1:1:size(component,2)
                [cg_num, cg_den, sub_parts] = get_component_cg(component(i).Data, 0, parent_length, 0);
                parts = [parts; sub_parts];
                % get_component_cg(component, x0, parent_length, parent_radius)
            end
        end
    end
end