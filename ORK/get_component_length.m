function l = get_component_length(component)
if isfield(component, 'length')
    l = component.length;
else
    l = 0;
end

if isfield(component, 'Components')
    components = component.Components;

    for i=1:1:size(components,2)
        l = l + get_component_length(components(i).Data);
    end
end
end