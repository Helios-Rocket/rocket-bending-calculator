function rocket = load_ork(filename)
zip_out = 'temp';

unzip(filename, zip_out);
ork_name = fullfile(zip_out, 'rocket.ork');

rocket = parseORK(ork_name);

rmdir('temp', 's');
end

function S = parseORK(filename) % thanks ChatGPT :)
%PARSEORK Parse OpenRocket .ork file with multi-stage support
%
% Output:
%   S(stageIdx).Components(compIdx)
%       .Type
%       .Name (if exists)
%       .Data

    doc = xmlread(filename);

    % Navigate to rocket
    rocket = doc.getElementsByTagName('rocket').item(0);
    subcomponents = rocket.getElementsByTagName('subcomponents').item(0);

    % Get ALL stages
    stages = subcomponents.getElementsByTagName('stage');

    S = struct([]);

    for s = 0:stages.getLength-1
        stage = stages.item(s);

        % Get this stage's subcomponents
        stageSubsList = stage.getElementsByTagName('subcomponents');
        if stageSubsList.getLength == 0
            continue;
        end
        stageSubs = stageSubsList.item(0);

        nodes = stageSubs.getChildNodes;

        compIdx = 1;
        Components = struct([]);

        for i = 0:nodes.getLength-1
            node = nodes.item(i);

            if node.getNodeType == node.ELEMENT_NODE
                Components(compIdx).Type = char(node.getNodeName);

                % % Optional name extraction
                % nameNode = node.getElementsByTagName('name');
                % if nameNode.getLength > 0
                %     Components(compIdx).Name = ...
                %         char(nameNode.item(0).getTextContent);
                % end

                Components(compIdx).Data = parseNode(node);

                compIdx = compIdx + 1;
            end
        end

        % Store stage
        S(s+1).Components = Components;
    end
end

function out = parseNode(node)
% Convert XML node into MATLAB struct with correct attribute handling

    out = struct;

    % --- Attributes ---
    if node.hasAttributes
        attrs = node.getAttributes;
        for k = 0:attrs.getLength-1
            attr = attrs.item(k);
            name = matlab.lang.makeValidName(char(attr.getName));
            value = char(attr.getValue);

            out.(name) = tryConvert(value);
        end
    end

    % --- Children ---
    children = node.getChildNodes;

    hasElementChildren = false;

    for i = 0:children.getLength-1
        child = children.item(i);

        if child.getNodeType == child.ELEMENT_NODE
            hasElementChildren = true;

            name = matlab.lang.makeValidName(char(child.getNodeName));
            value = parseNode(child);

            % ✅ FIXED: only unwrap if NO attributes
            if isstruct(value) && isfield(value,'Text') ...
                    && isscalar(fieldnames(value))
                value = value.Text;
            end

            % Handle repeated fields
            if isfield(out, name)
                if ~iscell(out.(name))
                    out.(name) = {out.(name)};
                end
                out.(name){end+1} = value;
            else
                out.(name) = value;
            end
        end
    end

    % --- Text content (ONLY direct text nodes) ---
    textContent = "";
    
    for i = 0:children.getLength-1
        child = children.item(i);
    
        if child.getNodeType == child.TEXT_NODE
            textContent = textContent + string(char(child.getData));
        end
    end
    
    textContent = strtrim(textContent);
    
    if strlength(textContent) > 0
        if isempty(fieldnames(out)) && ~hasElementChildren
            % Pure text node → collapse
            out = tryConvert(textContent);
        elseif ~isempty(fieldnames(out)) && ~hasElementChildren
            % Attributes + text → keep
            out.Text = tryConvert(textContent);
        else
            % ❌ Has element children → IGNORE text (this is your fix)
            % Do nothing
        end
    end
end

function val = tryConvert(str)
% Convert string to numeric/logical if possible

    if strcmpi(str, 'true')
        val = true;
    elseif strcmpi(str, 'false')
        val = false;
    else
        num = str2double(str);
        if ~isnan(num)
            val = num;
        else
            val = string(str);
        end
    end
end