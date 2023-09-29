classdef Circuit < devoppo & device_electrical
    %CIRCUIT Class representing a quantum circuit generated with TQC.
    %   Class which can be used in combination with GREAT PIC entities. It
    %   encapsulated all important properties and the GDSII layout itself,
    %   which allows e. g. the placement of GREAT PIC devices in
    %   combination with TQC circuits on a chip.
    %   This class is equivalent to a GREAT PIC device.
    
    properties
        % Width of the circuit;
        width; 
        % Height of the circuit;
        height;
        
        geom;
        
        % Configuration of the circuit
        config;
        
        % Annotator
        anno;
    end
    
    methods
        function dev = Circuit(XX, YY, geom, label, devtype, config, anno)
            if nargin < 1, supervarargs{1} = 0;  else, supervarargs{1} = XX; end
            if nargin < 2, supervarargs{2} = 0;  else, supervarargs{2} = YY; end
            if nargin < 3, supervarargs{3} = []; else, supervarargs{3} = geom; end
            if nargin < 4, supervarargs{4} = ''; else, supervarargs{4} = label; end
            if nargin < 5, supervarargs{5} = 'TQC Circuit'; else, supervarargs{5} = devtype; end
            
            dev = dev@devoppo(supervarargs{:});
            dev@device_electrical(supervarargs{:})
            dev.geom = geom;
            dev.config = config;
            dev.anno = anno;
        end
        
        function [dev, sDev, ssAll, csList, gsList] = build_device(varargin)
            [dev, ssAll, csList, gsList, makeStructure, sDev] = build_device_parameter_check(varargin{:});
            
            % Call Builder with configuration
            dCircuit = Builder(dev.XX, dev.YY, dev.geom, dev.label, ...
                               dev.devtype, dev.config, dev.anno);
            
            [dCircuit, sDev, ssAll2, csList, gsList] = dCircuit.build_device(dCircuit, ssAll, csList, gsList);
            ssAll = [ssAll2 ssAll];
        end
        
        function [dev, geom] = initialize_components(dev, varargin)
            [dev,geom] = initialize_components@devoppo(dev, varargin{:});
        end
        
        function dev = calc_parameters(dev, varargin)
            if nargin < 2
                geom = get_default_geometry();
                varargin{1} = geom;
            else
                geom = varargin{1};
            end
            
            dev = calc_parameters@devoppo(dev, varargin{:});
        end
        
        function [dev, ggText] = generate_descr(dev, layer, xdescr, ydescr)
            [dev, ggText] = generate_descr@devoppo(dev);        
        end
    end
    
    methods(Static)
        function [gds_properties, dev] = example(num, geom,  ssAll, ssList, sChip, csList, gsList)
            %EXAMPLE Example circuit configuration.
            
            numargin = nargin;
            example_device_parameter_check
            
            [gds_properties, dev] = example_caller('Circuit', num, ...
                geom, ssAll, ssList, sChip, csList, gsList);
        end
        
        function [gds_properties, dev] = example_0(geom, ssAll, ssList, sChip, csList, gsList)
            %EXAMPLE_0 Circuit creating toffoli gate circuit.
            
            % Create configuration
            gIn = {};
            gOut = {};
            phase_shift = 'static';
            alignment = 'Horizontal';
            oppo_distance = 500;%geom.oppo_distance;
            loci = 'circuits/teleportation.qa';
            config = Configuration(gIn, true, gOut, true, phase_shift, ...
                alignment, oppo_distance, 0, loci);
            
            % Specify annotator
            anno = Annotate();
            
            % Create circuit
            dev = Circuit(0, 0, geom, 'Teleportation', '', config, anno);
            % Generate circuit
            [dev, sDev, ssAll, csList, gsList] = dev.build_device(ssAll, csList, gsList);
            
            ssList{end+1} = sDev;
            sChip = add_ref(sChip, sDev);
            gds_properties = {sChip ssList ssAll, gsList};
        end
        
        function [gds_properties, dev] = example_1(geom, ssAll, ssList, sChip, csList, gsList)
            %EXAMPLE_1 Circuit creating toffoli gate circuit.
            
            % Create configuration
            gIn = {};
            gOut = {};
            phase_shift = 'static';
%             alignment = 'Vertical';
            alignment = 'Horizontal';
            oppo_distance = geom.oppo_distance;
            loci = 'circuits/toffoli_gate.qa';
            config = Configuration(gIn, true, gOut, true, phase_shift, ...
                alignment, oppo_distance, 0, loci);
            
            % Specify annotator
            anno = Annotate();
            
            % Create circuit
            dev = Circuit(0, 0, geom, 'Toffoli_1', '', config, anno);
            % Generate circuit
            [dev, sDev, ssAll, csList, gsList] = dev.build_device(ssAll, csList, gsList);
            
            ssList{end+1} = sDev;
            sChip = add_ref(sChip, sDev);
            gds_properties = {sChip ssList ssAll gsList};
        end
    end
end

