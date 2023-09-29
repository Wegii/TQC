classdef llist < handle
    %LLIST Implementation of a dependency graph vertice.
    %   This class represents both a vertice used in a graph, as well as
    %   the edges between them. A vertice has both in-/ and outgoing edges, 
    %   Vertices are linked together by two properties representing the
    %   in-/ and outgoing edges.

    properties(SetAccess = public)
        % Unique identifier
        id;
        
        % Data of this vertice
        Data;
        
        % Ingoing edges
        In = {};
        % Outgoing edges
        Out = {};
    end
    
    methods
        function node = llist(Data, id)
            %LLIST Construct a llist object.
            %   Set the Data and id of the entitie.
            
            if nargin > 0
                node.Data = Data;
                node.id = id;
            end
        end
        
        function insert(node, newNode, in, out)
            %INSERT Create dependency between two entities.
            %   Create a outgoing dependency from node to newNode. 
            
            node.Out{end + 1} = {out, newNode};
            newNode.In{end + 1} = {in, node};
        end
        
        function gOut = get_out_all(node)
            %GET_OUT_ALL Get all output parts
            %   Return all parts to which this entity has outgoing
            %   dependencies to.
            
            gOut = {};
            for j = 1:size(node.Out, 2)
                if size(node.Out{j}, 2) == 2
                    gOut{end + 1} = node.Out{j}{2};
                end
            end
        end
        
        function wave = get_in_min(node)
            %GET_IN_MIN Get the smallest input waveguide.
            %   Return the input waveguide with the lowest number.
            
            wave = -1;
            
            for j = 1:size(node.In, 2)
                if size(node.In{j}, 2) == 2
                    if wave == -1
                        wave = node.In{j}{1};
                    else
                        if wave > node.In{j}{1}
                            wave = node.In{j}{1};
                        end
                    end
                end
            end
        end
    end
end