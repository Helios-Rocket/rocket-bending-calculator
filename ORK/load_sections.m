function [sections, rocket_subcomp] = load_sections(ork)
rocket_subcomp = ork.subcomponents;

stages = rocket_subcomp.stage;
num_stages = numel(stages);

sections = {};
section_idx = 1;

x_pos = 0;

for stage_num = 1:num_stages
    stage = stages(stage_num);
    stage_subcomp = stage.subcomponents;

    subcomps = fieldnames(stage_subcomp);

    for i = 1:length(subcomps)

        name = subcomps{i};

        if strcmp(name, 'nosecone')
            nose_length = stage_subcomp.nosecone.length;
            nose_aft_rad = remove_auto(stage_subcomp.nosecone.aftradius);

            material = stage_subcomp.nosecone.material.Text;

            sections{section_idx} = struct( ...
                'x', x_pos, ...
                'length', nose_length, ...
                'forerad', 0, ...
                'aftrad', nose_aft_rad, ...
                'material', material, ...
                'name', stage_subcomp.nosecone.name, ...
                'stage', num_stages - stage_num + 1, ...
                'id', stage_subcomp.nosecone.id);
            section_idx = section_idx + 1;

            x_pos = x_pos + nose_length;
        end

        if strcmp(name, 'transition')
            forerad = remove_auto(stage_subcomp.transition.foreradius);

            aftrad = remove_auto(stage_subcomp.transition.aftradius);

            trans_length = stage_subcomp.transition.length;

            material = stage_subcomp.transition.material.Text;

            if isfield(stage_subcomp.transition, 'subcomponents')
                tr_sub = stage_subcomp.transition.subcomponents;
            else
                tr_sub = 'missing';
            end

            sections{section_idx} = struct( ...
                'x', x_pos, ...
                'length', trans_length, ...
                'forerad', forerad, ...
                'aftrad', aftrad, ...
                'material', material, ...
                'name', stage_subcomp.transition.name, ...
                'stage', num_stages - stage_num + 1, ...
                'id', stage_subcomp.transition.id, ...
                'outer_radius', min(forerad, aftrad) + stage_subcomp.transition.thickness, ...
                'subcomponents', tr_sub);
            x_pos = x_pos + trans_length;
            section_idx = section_idx + 1;
        end

        if strcmp(name, 'bodytube')
            bodytubes = stage_subcomp.bodytube;
            num_bodytubes = numel(bodytubes);

            for bodytube_num = 1:num_bodytubes
                bodytube = stage_subcomp.bodytube(bodytube_num);
                tube_length = bodytube.length;
                width = remove_auto(bodytube.radius);

                material = bodytube.material.Text;

                sections{section_idx} = struct( ...
                    'x', x_pos, ...
                    'length', tube_length, ...
                    'forerad', width, ...
                    'aftrad', width, ...
                    'material', material, ...
                    'name', bodytube.name, ...
                    'stage', num_stages - stage_num + 1, ...
                    'subcomponents', bodytube.subcomponents, ...
                    'id', bodytube.id, ...
                    'outer_radius', width + bodytube.thickness);
                section_idx = section_idx + 1;

                x_pos = x_pos + tube_length;
            end
        end
    end
end
end