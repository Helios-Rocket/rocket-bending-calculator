function l = get_component_length(component)
if isfield(component, 'length')
    l = component.length;
else
    l = 0;
end

if isfield(component, 'subcomponents')
    components = component.subcomponents;

    if isfield(components, 'nosecone')
        l = l + get_component_length(components.nosecone);
    end
    if isfield(components, 'bodytube')
        for n = 1:numel(components.bodytube)
            l = l + get_component_length(components.bodytube(n));
        end
    end
    if isfield(components, 'transition')
        l = l + get_component_length(components.transition);
    end
end
end