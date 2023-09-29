classdef Optimizer
    %OPTIMIZER Perform optimizations.
    %   Class for performing optimizations of the dependency graph. At the
    %   moment the following optimizations are implemented:
    %       - Merging: Merge DCs together.
    %   
    %   Warning: It is not clear, if this class will still be used. Logical
    %   optimizations are to be done on a higher level, and by a separate
    %   project.
    
    properties
    end
    
    methods
        function [optimizer, graph] = Optimizer(graph)
            %OPTIMIZER Optimize passed circuit.
            
            graph = optimizer.optimize(graph);
        end
        
        function graph = optimize(optimizer, graph)
            %OPTIMIZE Optimize graph
            %   Perform a multitute of optimizations on the passed
            %   dependency graph:
            %       - Merge DCs together
            
            graph = optimizer.optimize_swap(graph);
            graph = optimizer.optimize_merge(graph);
        end
    end
    methods(Access = private)
        function graph = optimize_merge(optimizer, graph)
           %OPTIMIZE_MERGE Merge parts together
           %    Merge parts, that can be logically merge, together by
           %    adjusting their properties and removing the parts used
           %    during the merge.
           
           % Merge DCs together. Change properties, based on merge.
        end
        
        function graph = optimize_swap(optimizer, graph)
            %OPTIMIZE_SWAP TODO
            %   TODO
            
            
            % TODO: It is possible that DCs have as waveguides with input (1, 0)
            %       and output (0, 1). This means, that a waveguide
            %       crossing needs to placed, in order to swap the
            %       waveguides. This should be handled in the Generator.
        end
    end
end

