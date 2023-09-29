classdef Configuration
    %CONFIGURATION Configuration of circuit.
    %   Class for specifying configurations for a circuit. Config includes
    %   e. g. specification of type of input.
    %
    %   It is also possible to read and write to file containing the
    %   configuration.
    
    properties(Access = public)
        % Way of coupling light on the chip. Each entry corresponds to a
        % waveguide:
        %   - GC: grating coupler
        %   - CTL: cantilever
        %
        % If in_GC_only is selected, this property will be ignored.
        gIn;
        
        % Couple light on the chip using only GCs. If set to true, gIn is
        % ignored.
        in_GC_only = true;
        
        % Way of coupling light from the chip, or detecting it on chip.
        % Each entry corresponds to a waveguide:
        %   - GC: grating coupler
        %   - SNSPD: Superconducting nanowire single-photon detector
        %
        % If out_GC_only is selected, this property will be ignored
        gOut;
        
        % Couple light from the chip using only GCs. If set to true, gOut
        % is ignored.
        out_GC_only = true;
        
        % Type of phase shifters:
        %   - static: phase shift using movable structures (default)
        %   - Heater: phase shift using heating of waveguides
        %   - Ignore: replace phase shifters with straight waveguides
        phase_shift;
        
        % Alignment of the circuit
        %   - Vertical: Circuit flowing from bottom to top. In- and output 
        %               horizontally aligned to each other and placed above and
        %               below the circuit.
        %   - Horizontal: Circuit flowing from left to right. In- and output
        %                 horizontally aligned to each other and placed above
        %                 and below the circuit.
        %   - Bottom: Circuit flowing form left to right. In- and output
        %             placed horizontally below the circuit.
        alignment;
        
        % Distance between opposing GCs
        oppo_distance;
        % Horizontal offset between opposing GCs
        oppo_offset = 0;
        
        % LOCI file specifying the circuit to be build
        loci;
    end
    
    methods
        function config = Configuration(gIn, in_GC_only, gOut, out_GC_only, ...
                phase_shift, alignment, oppo_distance, oppo_offset, loci)
            %CONFIGURATION Configuration of a quantum circuit.
            %   The configuration allows for the configuration of different
            %   properties of the quantum circuit.
            %   Configuration objects are used by the Circuit and Builder
            %   class.
            
            if nargin > 0; config.gIn = gIn; end
            if nargin > 1; config.in_GC_only = in_GC_only; end
            if nargin > 2; config.gOut = gOut; end
            if nargin > 3; config.out_GC_only = out_GC_only; end
            if nargin > 4; config.phase_shift = phase_shift; end
            if nargin > 5; config.alignment = alignment; end
            if nargin > 6; config.oppo_distance = oppo_distance; end
            if nargin > 7; config.oppo_offset = oppo_offset; end
            if nargin > 8; config.loci = loci; end
            
            % Validate properties
            config = config.validate_properties();
        end
        
        function config = config_read(config)
            %CONFIG_READ Read configuration file.
        end
        
        function config = config_write(config)
            %CONFIG_WRITE Write configuration file.
        end
    end
    
    methods(Access = private)
        function config = validate_properties(config)
            %VALIDATE_PROPERTIES Check properties for correctness.
            %   Validate the configuration itself. In general, all
            %   available properties should be set.
            %   
            %   Depending on configuration, properties will be overwritten.
            
            geom = get_default_geometry();
            
            if config.in_GC_only
                config.gIn = {};
            end
            
            if config.out_GC_only
                config.gOut = {};
            end
            
            if isempty(config.phase_shift)
                config.phase_shift = 'static';
            end
            
            if isempty(config.oppo_distance)
                config.oppo_distance = geom.oppo_distance;
            end
            
            if isempty(config.loci)
               error('Configuration: No LOCI file specified!'); 
            end
        end
    end
end

