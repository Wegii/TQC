classdef Generator
    %GENERATOR Generate dependency graph given LOCI code.
    %   The Generator generates a dependency graph given LOCI code. LOCI
    %   code specifies parts, waveguides they act on, as well as other
    %   properties.
    %   The generate dependency graph contains all logical in- and output
    %   dependencies of all parts. The graph can be used to generate the
    %   physical layout.
    
    properties(Access = public)
        graph;
    end
    
    methods(Access = public)
        function [Gen, graph, gDescription] = Generator(filename)
            %Generator Generate intermediate representation.
            %   Generate graph representation of LOCI code located in
            %   filename.
            
            % Parse specified LOCI file
            [Parse, gCode, gDescription] = Parser(filename);
            
            % Generate dependency graph
            Gen = Gen.build(gCode);
            graph = Gen.graph;
        end
        
        function Gen = build(Gen, gCode)
            %BUILD Compile code to a graph representation
            %   This function compiles the code, as given by the parser,
            %   and constructs a graph representation from it.
            
            % Generate jump table
            [Gen, gJTable] = Gen.generate_table(gCode);
            % Generate graph
            Gen = Gen.generate_graph(gCode, gJTable);
            
            % Perform optimizations
            % [optimizer, Gen.graph] = Optimizer(Gen.graph);
        end
        
        function Gen = visualize(Gen, graph)
            %VISUALIZE Visualize the dependency graph.
            %   Visualize dependency graph with all parts and dependencies
            %   to each other.
            
            % TODO: GraphViz visualization of the graph.
        end
    end
    
    methods(Access = private)
        function Gen = generate_graph(Gen, gContent, gJTable)
            %GENERATE_GRAPH Generate the graph from the code.
            %    This function will generate the actual graph, which will
            %    then be passed on.
            
            % Graph for storing the dependencies of all parts
            ng = Graph();
            % List of program counters to work through
            gPc = [4];
            % Current program counter
            pc = -1;
            
            while true
                % Pop the
                pc = gPc(end);
                gPc(end) = [];
                
                if Gen.isa_label(gContent{pc})
                    gPc(end + 1) = gJTable(gContent{pc}) + 1;
                elseif Gen.isa_part(gContent{pc})
                    % Create part vertice
                    [ng, obj] = ng.create_vertice(gContent{pc}('part'), ...
                        gContent{pc}('properties'));
                    
                    in = gContent{pc}('input');
                    gPort = Gen.get_port(in);
                    
                    % Get prior part which utilizes the same waveguide as
                    % output as the current part utilizes as input.
                    for j = 1:size(gPort, 2)
                        waveguide = gPort(j);
                        
                        if isnan(waveguide)
                            obj.In{end+1} = '';
                        else
                            link = Gen.get_prior(waveguide, ng);
                            
                            % Create edge from link to obj with the correct
                            % ports.
                            for k = 1:size(link.Out, 2)
                                % Find correct output of prior part
                                if ~iscell(link.Out{k}) && ~strcmp(link.Out{k}, '') ...
                                        && link.Out{k} == waveguide
                                    % Create edge to the new part
                                    link.Out{k} = {link.Out{k} obj};
                                    % Create edge to the old part
                                    obj.In{end + 1} = {waveguide link};
                                    break;
                                end
                            end
                        end
                    end
                    
                    % Set outputs of the current part
                    out = gContent{pc}('output');
                    gPort = Gen.get_port(out);
                    
                    for j = 1:size(gPort, 2)
                        if isnan(gPort(j))
                            obj.Out{j} = '';
                        else
                            obj.Out{j} = gPort(j);
                        end
                    end
                    
                    % Push next instruction
                    gPc(end + 1) = pc + 1;
                elseif Gen.isa_return(gContent{pc})
                    % Return statement reached
                    break;
                else
                    % TODO: This function should not throw any errors, as
                    % everything should be checked preliminary.
                    error('Generator: Unrecognized instruction!');
                end
                
                if isempty(gPc)
                    break;
                end
            end
           
            Gen.graph = ng.graph;
        end
        
        function link = get_prior(Gen, waveguide, graph)
            %GET_PRIOR Get the last part utilizing the waveguide.
            %    Get the last part that utilizes the passed waveguide. This
            %    part can be found by searching through the dependency graph
            %    and picking the part with the correct waveguide as output
            %    and no output dependencies on this waveguide.
            %    If no prior part is found, the initial graph is returned.
            
            gVertice = [graph.graph];
            
            while true
                current = gVertice(end);
                gVertice(end) = [];
                
                if current.id == -1 && isempty(current.Out)
                    current.Out{end + 1} = waveguide;
                    link = current;
                    break;
                else
                    for j = 1:size(current.Out, 2)
                        if size(current.Out{j}, 2) == 2
                            gVertice(end + 1) = current.Out{j}{2};
                        elseif size(current.Out{j}, 2) == 1 && ...
                                current.Out{j} == waveguide
                            % Correct part found
                            link = current;
                            return;
                        end
                    end
                end
                
                % No part uses this waveguide yet
                if isempty(gVertice)
                    link = graph.graph;
                    link.Out{end + 1} = waveguide;
                    break;
                end
            end
        end
        
        function gPort = get_port(Gen, ports)
            %GET_PORT Return ports as a list.
            %   Parse specified ports in the format (<Port1>, <Port2>) to a
            %   array of ports.
            
            p1 = str2double(ports(2:strfind(ports, ',')));
            p2 = str2double(ports(strfind(ports, ',')+1:end-1));
            
            gPort = [p1 p2];
        end
        
        function [Gen, gJTable] = generate_table(Gen, gContent)
            %GENERATE_TABLE Generate the jump table.
            %   Generate the jump table based on the labels present in the
            %   code. The jump table is used to jump to the correct program
            %   counter if a label is encountered.
            
            gJTable = containers.Map();
            
            for j = 1:size(gContent, 2)
                if Gen.isa_sym_label(gContent{j})
                    gJTable(gContent{j}(1:end-1)) = j;
                end
            end
        end
        
        function ret = isa_return(Gen, line)
            %ISA_RETURN Check if line represents return statement.
            %   Check if the current instruction is the return statement.
            %   The return statement declares the end of the program.
            ret = strcmp(line, 'ret');
        end
        
        function ret = isa_part(Gen, line)
            %ISA_PART Check if line defines a part.
            %   All parts are represented by a map structure, and can thus
            %   be identified by it.
            
            if isa(line, 'containers.Map')
                ret = true;
            else
                ret = false;
            end
        end
        
        function ret = isa_label(Gen, line)
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
        
        function ret = isa_sym_label(Gen, line)
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

