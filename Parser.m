classdef Parser
    %PARSER Parse .qa files containing LOCI code.
    %   This class reads the specified LOCI code and parses it. Parsing
    %   includes scanning and syntax checking.
    %   The parsed code only contains necessary information and lines.
    %   Symbols such as comments are removed.
    
    properties(Access = public)
        % File to parse
        filename;
        
        % Parsed code
        gCode;
    end
    
    properties(Access = private)
        % Available and allowed (logical) parts.
        gParts = {'directional_coupler', 'waveguide_crossing', 'phase'};
        
         % gParts = {'directional_standard', 'directional_heated', ...
         %     'hresonator', 'hdirectional', 'waveguide_sspd', 'ring', ...
         %     'waveguide_crossing', 'grating_coupler'};
    end
    
    methods(Access = public)
        function [Parse, gCode, gDescription] = Parser(filename)
            %PARSER Parse LOCI code in filename.
            
            Parse.filename = filename;
            % Parse file
            [Parse, gCode, gDescription] = Parse.parse();
            Parse.gCode = gCode;
        end
    end
    
    methods(Access = private)
        function [Parse, gCode, gDescription] = parse(Parse)
            %PARSE Parse LOCI code in specified file.
            %   Parse the specified file. Operations include extraction of
            %   (graphical) circuit representation, as well as the parts
            %   and their properties.
            
            % Perform scanning
            % Get the code
            [Parse, gCode] = Parse.get_code();
            % Aliases
            [Parse, gCode] = Parse.get_alias(gCode);
            % Description
            [Parse, gDescription] = Parse.get_description(gCode);
            % Remove comments
            [Parse, gCode] = Parse.remove_comments(gCode);
            
            % Translate everything to tokens
            [Parse, gCode] = Parse.get_tokens(gCode);
            
            % Check if code is well defined
            % Check if all label are unique
            Parse = Parse.check_labels(gCode);
            % Check if identifier are well defined
            Parse = Parse.check_identifiers(gCode);
            % Check if properties are well defined
            Parse = Parse.check_constants(gCode);
            % Check if properties are well defined
            Parse = Parse.check_properties(gCode);
        end
        
        function [Parse, gContent] = get_code(Parse)
            %GET_CODE Read the code from the specified file
            %   Read everything from the file specified in filename. The
            %   file contains the programmcode of the circuit to build.
            %   More specifically, all used parts and their relationship
            %   are present.
            
            gContent = {};
            
            fid = fopen(Parse.filename);
            
            line = fgetl(fid);
            gContent{end+1} = line;
            
            while ischar(line)
                line = fgetl(fid);
                gContent{end+1} = line;
            end
            
            gContent{end} = '';
            fclose(fid);
            
            % Remove leading empty spaces
            for j = 1:size(gContent, 2)
                gContent{j} = strtrim(gContent{j});
            end
            
            % Remove empty cells
            gContent = gContent(~cellfun('isempty', gContent));
        end
        
        function [Parse, gContent] = get_alias(Parse, gContent)
            %GET_ALIAS Evaluate aliases.
            %    Replace all aliases with their corresponding code.
            
            warning('Parser: Aliases not supported!');
        end
        
        function [Parse, gDescription] = get_description(Parse, gContent)
            %GET_DESCRIPTION Get the circuit description.
            %   Returns the circuit model later used as description (on
            %   chip) by the builder.
            %   The description is enclosed by:
            %       - DESCRIPTION_BEGIN: Beginning of the description
            %       - DESCRIPTION_END:   End of the description
            
            idx_start = 0;
            idx_end = 0;
            for j = 1:size(gContent, 2)
                if startsWith(strtrim(gContent{j}), '# DESCRIPTION_BEGIN')
                    idx_start = j;
                elseif startsWith(strtrim(gContent{j}), '# DESCRIPTION_END')
                    idx_end = j;
                end
            end
            
            if idx_start ~= idx_end
                gDescription = gContent(idx_start+1:idx_end-1);
            else
                gDescription = {};
            end
        end
        
        function [Parse, gContent] = remove_comments(Parse, gContent)
            %REMOVE_COMMENTS Remove all comments.
            %   All lines containing a comments are removed.
            %   Comment syntax: # <Comment>
            
            for j = 1:size(gContent, 2)
                if startsWith(strtrim(gContent{j}), '#')
                    gContent{j} = '';
                end
            end
            
            % Remove empty cells
            gContent = gContent(~cellfun('isempty', gContent));
        end
        
        function [Parse, gContent] = get_tokens(Parse, gContent)
            %GET_TOKENS Generate tokens based on code.
            %   Each line of code is translated into tokens consisting of
            %   e.g names, properties for parts.
            
            for j = 1:size(gContent, 2)
                obj = split(gContent{j});
                
                % Tokenize all parts
                if contains(obj{1}, Parse.gParts)
                    newPart = containers.Map({'part', 'input', 'output', 'properties'}, ...
                        {obj{1}, obj{2}, obj{3}, obj(4:end)});
                    
                    gContent{j} = newPart;
                end
                
            end
        end
        
        function Parse = check_properties(Parse, gContent)
            %CHECK_PROPERTIES Check if properties make sense.
            %   Check for each part if the present properties do make sense
            %   and it is possible to place and generate the part this way.
            
            % Check if input and output are set
            for j = 1:size(gContent, 2)
                if isa(gContent{j}, 'containers.Map')
                    in = gContent{j}('input');
                    out = gContent{j}('output');
                    
                    if isempty(regexp(in, regexptranslate('wildcard', '(*)'))) || ...
                            isempty(regexp(out, regexptranslate('wildcard', '(*)')))
                        error('Parser: Ports are not set!');
                    end
                end
            end
        end
        
        function Parse = check_constants(Parse, gContent)
            %CHECK_CONSTANTS Check if constants are well defined.
            %   Check for each identifier if present constants, in this
            %   case also strings, are well defined and conform to proper
            %   convention.
            %   Convention: default, property_name:<Value>, <Value>
            
            for j = 1:size(gContent, 2)
                if Parse.isa_part(gContent{j})
                    props = gContent{j}('properties');
                    
                    for p = 1:size(props, 1)
                        % Check if property conforms to convent
                        if ~isempty(regexp(props{p}, regexptranslate('wildcard', '*:*'))) || ...
                                ~isnan(str2double(props{p})) || ...
                                strcmp(props{p}, 'default') ~= 0 || ...
                                ~isempty(str2num(props{p}))
                            break;
                        else
                            error(strcat('Parser: Property ', props{p}, ' does not conform to the convention!'));
                        end
                    end
                end
            end
        end
        
        function Parse = check_identifiers(Parse, gContent)
            %CHECK_IDENTIFIERS Check if all identifiers exist.
            %    Check if all tokens are well defined and can be used.
            %    Check if all calls to labels do exist.
            
            warning('Parser: Identifiers and tokens are not checked!');
        end
        
        function Parse = check_labels(Parse, gContent)
            %CHECK_LABELS Check labels.
            %    Check if all labels present in the code are unique. This is
            %    necessary due to the possibility of referencing to labels
            %    instead of repeating code.
            
            for j = 1:size(gContent, 2)
                % Format of labels: _<Name>:
                if Parse.isa_sym_label(gContent{j})
                    for k = j+1:size(gContent, 2)
                        % Check if label is unique
                        if strcmp(gContent{j}, gContent{k})
                            error(strcat('Parser: Label ', gContent{j}, ' is not unique!'));
                            break
                        end
                    end
                end
            end
        end
        
        function ret = isa_return(Parse, line)
            %ISA_RETURN Check if line represents return statement.
            %   Check if the current instruction is the return statement.
            %   The return statement declares the end of the program.
            ret = strcmp(line, 'ret');
        end
        
        function ret = isa_part(Parse, line)
            %ISA_PART Check if line defines a part.
            %   All parts are represented by a map structure, and can thus
            %   be identified by it.
            
            if isa(line, 'containers.Map')
                ret = true;
            else
                ret = false;
            end
        end
        
        function ret = isa_label(Parse, line)
            %ISA_NUM_LABEL Check if line jumps to a label.
            %   Check if the passed line defines a call to a certain label.
            %   Such a call consists of the name of the label to jump to:
            %   _<Name>
            
            if ~isa(line, 'containers.Map') && ...
                    strcmp(line(1), '_') && ~strcmp(line(end), ':')
                ret = true;
            else
                ret = false;
            end
        end
        
        function ret = isa_sym_label(Parse, line)
            %ISA_SYM_LABEL Check if line is symbolic label.
            %   Check if the passed line defines a symbolic label. A
            %   symbolic label consists of a identifier followed by a
            %   colon: _<Name>:
            
            if ~isa(line, 'containers.Map') && ...
                    strcmp(line(1), '_') && strcmp(line(end), ':')
                ret = true;
            else
                ret = false;
            end
        end
    end
    
end

