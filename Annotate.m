classdef Annotate < device_optical
    %ANNOTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Access = public)
        function Anno = Annotate()
        end
        
        function [Anno, ggText] = generate_swap_description(Anno, geom, ggMoments)
            %GENERATE_CIRCUIT_DESCR Generate visual description of circuit.
            %   Generate the description of the circuit. The description
            %   consists of a visualization of the logical circuit.
            
            layer = geom.layers.annotation;

            ggText = {};            
            
            [gText, Anno.wlabel] = gdsii_boundarytext('|1>_0', [390, 20], 2, 0, layer, [], true);
            ggText{end+1} = gText;
            
            [gText, Anno.wlabel] = gdsii_boundarytext('|0>_0', [390, 13], 2, 0, layer, [], true);
            ggText{end+1} = gText;
            
            [gText, Anno.wlabel] = gdsii_boundarytext('|1>_1', [390, 7.5], 2, 0, layer, [], true);
            ggText{end+1} = gText;
            
            [gText, Anno.wlabel] = gdsii_boundarytext('|0>_1', [390, 1], 2, 0, layer, [], true);
            ggText{end+1} = gText;
            
            
            for j = 1:size(ggMoments, 2)
                for k = 1:size(ggMoments{j}, 2)
                    
                end
            end
            
        end
    end
end

