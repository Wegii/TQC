classdef Graph
    %GRAPH Interface class representing graphs
    %   This interface serves as a basis for generating the dependency graphs.
    %   The graph consists of edges between part vertices:
    %       - Vertices are represented by a llist object.
    %       - Edges are represented by properties in each llist object.
    
    properties(Access = public)
        graph;
    end
    
    properties(Access = private)
        id = 0; 
    end
    
    methods(Access = public)
        function Graph = Graph(~)
            Graph.graph = llist();
            Graph.graph.id = -1;
        end
        
        function [Graph, vertice_out] = create_edge(Graph, vertice_out, vertice_in, out, in)
            %CREATE_EDGE Create edge between two vertices.
            
            vertice_out.insert(vertice_in, in, out);
        end
        
        function [Graph, vertice] = create_vertice(Graph, name, properties)
            %CREATE_VERTICE Create new vertice.
            %   Create new vertice containing different information and
            %   properties. 
            
            % TODO: Deal with properties
            vertice = llist(containers.Map({'part', 'properties'}, ...
                {name, properties}), Graph.id);
            
            Graph.id = Graph.id + 1;
        end
    end
    
    methods(Access = private)
       
    end
end

