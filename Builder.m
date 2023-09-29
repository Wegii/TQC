classdef Builder < device_optical & device_electrical
    %BUILDER Build photonic quantum circuit.
    %   Build the photonic quantum circuit and GDSII object given a
    %   dependency graph, containing all parts and their dependency to each
    %   other.
    %   The layout, inputs, outputs, etc. are specified by the
    %   configuration file.
    
    properties(Access = public)
        % Graph containing the circuit to be build
        graph;
        % Physical layout of the circuit
        gdsLayout;
        
        % Configuration class
        config;
        
        % Moments
        ggMoments;
        
        % Annotator
        anno;
    end
    
    properties(Access = private)
        % Default geometry properties
        geom;
    end
    
    methods(Access = public)
        function Layout = Builder(XX, YY, geom, label, devtype, config, annotate)
            %BUILDER Constructor of this class.
            %   Generate the GDS Layout given a dependency graph.
            
            supervarargs = {0, 0, geom, label, devtype};
            Layout@device_optical(supervarargs{:})
            Layout@device_electrical(supervarargs{:})
            
            if nargin >= 3
%                 Layout = copyfields(geom, Layout, 'cut', 'elec_width');
            end
            
            % Generate graph representation from LOCI code
            [Gen, Layout.graph] = Generator(config.loci);
            
            Layout.anno = annotate;
            
            Layout.config = config;
            Layout.geom = geom;
            Layout.XX = XX;
            Layout.YY = YY;
        end
        
        function [Layout, sDev, ssAll, csList, gsList] = build_device(Layout, varargin)
            %BUILD_DEVICE Build the circuit.
            %   Perform a multiple of steps for constructing the GDS layout
            %   given the dependency graph containing all parts and their
            %   dependency to each other.
            %   In order to generate the Layout, multiple steps are
            %   performed:
            %   - Translate the dependency into a moments. Each moment
            %     encapsulates the dependencies of parts. Each moment
            %     contains part that do not share any dependency with each
            %     other. Furthermore, parts in each moment are sorted
            %     according to the waveguides used.
            %   - Calculate height, length, etc. of each moment and its
            %     parts. These values are used in the placement of the
            %     parts.
            %   - Placement and connection of the parts.
            %   - Generation of in- and outputs
            %   - Generation of contact_pads and placement of wires.
            
            [dev, ssAll, csList, gsList, makeStructure, sDev] = build_device_parameter_check(varargin{:});
            
            % Calculate moments
            Layout.ggMoments = Layout.calc_moments();
            % Sort parts in each moment
            Layout.ggMoments = Layout.sort_moments(Layout.ggMoments);
            
            % Generate all parts according to their moment
            [Layout, Layout.ggMoments] = Layout.generate_parts(Layout.ggMoments);
            
            % Remove all empty parts
            Layout.ggMoments = Layout.remove_empty(Layout.ggMoments);
            
            % Calculate the length and height of each part in each moment
            Layout.ggMoments = Layout.calc_moment_length(Layout.ggMoments);
            Layout.ggMoments = Layout.calc_moment_height(Layout.ggMoments);
            
            
            % Place all parts on their correct position
            [Layout, ggParts, Layout.ggMoments] = Layout.place_parts(Layout.ggMoments);
            
            % TODO: Simulator kicks in at this point. Generate the GDSII
            %       file, do the simulation, and create a improved version
            %       of the circuit.
            

            
            % Place all wires
            [Layout, ggWires, Layout.ggMoments] = Layout.generate_wires(Layout.ggMoments);
            
            % TODO Check if annotations are needed 
            annotation_required = false;
            if annotation_required
                % Generate annotations for Swap
                [Layout.anno, ggDescr] = Layout.anno.generate_swap_description(Layout.geom, ...
                    Layout.ggMoments);
                
                Layout.ggUnstructured = [Layout.ggUnstructured ggDescr];
            end
            
            [Layout, width] = Layout.calc_circuit_width(Layout.ggMoments);
            
            % Generate in- and output
            displacement = [-width/2, 0];
            Iface = Interface(Layout.config, Layout.geom);
            ggInput = {};
            ggOutput = {};
            [Layout, ggInput, Iface] = Layout.generate_input(Layout.ggMoments, Iface, displacement);
            [Layout, ggOutput, Iface] = Layout.generate_output(Layout.ggMoments, Iface, displacement);
            
            % TODO Refine gc_description
            Layout.gc_descr = repelem({'gc'}, size(Layout.gc_positions, 1));
            
            % Add all entities to be build
             Layout.ggUnstructured = [Layout.ggUnstructured ggParts ggInput ...
                ggOutput ggWires];
            
            % Center circuit at (0, 0)
            Layout.ggUnstructured = displaceGG(Layout.ggUnstructured, -width/2, 0);
     
            if strcmpi(Layout.config.alignment, 'vertical')
                Layout.ggUnstructured = rotateGG(Layout.ggUnstructured, pi/2);
            end
            
            [Layout, sDev, ssAll, csList, gsList] = build_device@device_optical(Layout, {}, gsList, {}, false);
            [Layout, sDev, ssAll, csList, gsList] = Layout.unfinished_business(sDev, ssAll, csList, gsList, true);
        end
        
        function Layout = initialize_components(Layout, varargin)
            %INITIALIZE_COMPONENTS Call initialize_components of parents.
            
            [Layout, geom] = initialize_components@device_optical(Layout, varargin{:});
            Layout = initialize_components@device_electrical(Layout, varargin{:});
        end
        
        function Layout = calc_parameters(Layout)
            %CALC_PARAMETERS Call calc_parameters of parents.
            
            Layout = calc_parameters@device_optical(Layout);
            Layout = calc_parameters@device_electrical(Layout);
            Layout.valid_parameters = true;
        end
        
        function [Layout, ggText] = generate_descr(Layout, layer, xdescr, ydescr)
            %GENERATE_DESCR Generate the description for this device.
            %   The description consists of logos, specified circuit name,
            %   visual circuit description, as well as specified
            %   properties.
            %   Description is structured as follows:
            %       EQT - NAME - TUM
            %           CIRCUIT
            %     Important Properties
            
            y_bottom = 0;
            
            if Layout.config.in_GC_only
                % Position description below lower GCs
                y_bottom = Layout.gc_positions(1, 2);
            end
            
            Layout.TUMlogo = true;
            Layout.EQTlogo = true;
            Layout.TUMpos = [200, y_bottom - 100];
            Layout.EQTpos = [-200, y_bottom - 100];
            Layout.xlabel = 0;
            Layout.ylabel = y_bottom - 120;

            % Generate visual description of circuit
            [Layout, ggText] = generate_descr@device_optical(Layout);
            [Layout, ggT] = Layout.generate_circuit_descr(y_bottom - 150);
            ggText = [ggText ggT];
        end
    end
    
    methods(Access = private)
        function [Layout, ggText] = generate_circuit_descr(Layout, y_start)
            %GENERATE_CIRCUIT_DESCR Generate visual description of circuit.
            %   Generate the description of the circuit. The description
            %   consists of a visualization of the logical circuit.
            
            layer = Layout.layers.devlabel;
            
            xdescr = -85;
            ydescr = y_start;
            
            ggText = {};
            
            % TODO Get circuit description from Generator
            warning('Builder: Hardcoded description used!');
            
            [gText, Layout.wlabel] = gdsii_boundarytext('0: ---H---X---X-----------X---H---', [xdescr, ydescr], Layout.hdescr, 0, layer, [], true);
            ggText{end+1} = gText;
            ydescr = ydescr - Layout.hdescr*1.5;
            
            [gText, Layout.wlabel] = gdsii_boundarytext('                |               |', [xdescr, ydescr], Layout.hdescr, 0, layer, [], true);
            ggText{end+1} = gText;
            ydescr = ydescr - Layout.hdescr;
            
            [gText, Layout.wlabel] = gdsii_boundarytext('1: ---H-------@---@---@---@---H---', [xdescr, ydescr], Layout.hdescr, 0, layer, [], true);
            ggText{end+1} = gText;
            ydescr = ydescr - Layout.hdescr;
            
            [gText, Layout.wlabel] = gdsii_boundarytext('                      |         |', [xdescr, ydescr], Layout.hdescr, 0, layer, [], true);
            ggText{end+1} = gText;
            ydescr = ydescr - Layout.hdescr;
            
            [gText, Layout.wlabel] = gdsii_boundarytext('2: ---H---X-------X---X---X---H---', [xdescr, ydescr], Layout.hdescr, 0, layer, [], true);
            ggText{end+1} = gText;
            ydescr = ydescr - Layout.hdescr;
        end
        
        function [Layout, ggOutput, Iface] = generate_output(Layout, ggMoments, Iface, displacement)
            %GENERATE_OUTPUT Generate the output parts.
            %   The output of the circuit can consist of different parts.
            %   It is possible to detect photons either on- or off-chip.
            
            [Iface, ggOutput, gc_positions, gc_orientations] = Iface.generate_output(ggMoments, displacement);
            Layout.gc_positions = [Layout.gc_positions; gc_positions];
            Layout.gc_orientations = [Layout.gc_orientations gc_orientations];
        end
        
        function [Layout, ggInput, Iface] = generate_input(Layout, ggMoments, Iface, displacement)
            %GENERATE_INPUT Generate the input parts.
            %   The input of the circuit can consist of different parts.
            %   It is possible to generate photons on- or off-chip.
            
            [Iface, ggInput, gc_positions, gc_orientations] = Iface.generate_input(ggMoments, displacement);
            % Set GC positions for the interface object, in order to make
            % those accessible to the output. 
            Iface.gc_positions = gc_positions;
            
            Layout.gc_positions = gc_positions;
            Layout.gc_orientations = gc_orientations;
        end
        
        function [Layout, ggWires, ggMoments] = generate_wires(Layout, ggMoments)
            %GENERATE_WIRES Generate all wires.
            %   Generate and correct placement of needed wires. Wires are
            %   connected to contact pads. Contact pads are placed above
            %   and below the circuit if needed.
            %   There are multiple options how the wires should be placed:
            %       float_1 - Wires can go over waveguide elements, as they
            %                 are placed on a SiO2 cladding ontop of the SiN
            %                 parts.
            %       bridge -  Utilize bridge parts to create bridges where
            %                 the wires would otherwise go over the
            %                 waveguides. The bridges are constructed using
            %                 grayscale lithography.
            %       default - Place wires without touching and crossing
            %                 other elements.
            
            wire_placement = '';
            ggWires = {};
            
            %TODO Check if circuit contains any parts that need wires
            wires_required = false;
            
            if (wires_required)
                % Generate the contact_pads
                % Specify number of pads depending on the amount and type of
                % parts.
                Layout = Layout.set('pad_number', 12);
                % Shift the contact pads to the center of the leftmost and
                % rightmost part.
                Layout = Layout.set('pad_xoffset', 800);
                % Set yoffset of the contact pads depending on the height of
                % the circuit or moment_height_max.
                Layout = Layout.set('pad_distance', 100);
                
                % Initialize the contact_pads
                cPads = contact_pads(Layout.geom, 'pad_number', Layout.pad_number);
                % Generate description for lower contact pads
                cPads.gDescr = repelem({'cc'}, cPads.pad_number);
                cPads.make_pad_labels = true;
                % Generate the contact_pads and description
                [cPads, ggContactPads] = cPads.generate_geometry(Layout.geom.layers.metal, ...
                    Layout.geom.layers.annotation, 2*Layout.hdescr, ...
                    [0, -2*Layout.hdescr]);
                
                % Upper contact pads
                ggCUpper = displaceGG(ggContactPads, Layout.pad_xoffset, Layout.pad_distance);
                % Lower contact pads
                ggCLower = rotateGG(ggContactPads, 0);%pi);
                ggCLower = displaceGG(ggCLower, Layout.pad_xoffset, -Layout.pad_distance);
                % TODO: Update contact pads regarding their location, due to
                %       displacement. This is needed, as the elecports would
                %       otherwise have a wrong location.
                
                ggWires = [ggWires ggCUpper ggCLower];
                
                
                % Set width of wires
                Layout = Layout.set_unspecified('elec_width', Layout.geom.elec_width);
                
                % Place wires and connect parts with contact_pads
                switch wire_placement
                    case 'float_1'
                        warning('Builder: float_1 wiring not implemented');
                    case 'bridge'
                        warning('Builder: bridge wiring not implemented');
                    otherwise
                        warning('Builder: default wiring not implemented');
                        % When connection a part with a contact_pad, add a
                        % description to this pad, regarding its usage
                end
            end
            
        end
        
        function [Layout, ggParts, ggMoments] = place_parts(Layout, ggMoments)
            %PLACE_PARTS Place parts on their correct position.
            %   All generated parts are placed to their correct
            %   positions on the layout. Depending on the in- and outgoing
            %   connections to other parts, waveguides will be generated.
            %   Depending on the specifications, in- and output parts, such
            %   as GCs or photon sources, are generated.
            %   The placement procedure consists of multiple steps:
            %   - Calculation of vertical position. In- and output
            %     waveguides are taken into consideration. Parts should be
            %     placed in such a way, that they do not interfere with
            %     other parts, as well as avoiding overlapping waveguides.
            %   - Calculation of horizontal position. Length of prior parts
            %     taken into consideration, in order to prevent
            %     interference with other parts, as well as overlapping
            %     waveguides.
            %   - Generate connections. Depending on the in- and outputs of
            %     parts, connection between parts have to be generated. All
            %     used ports are connected. Unused ports of parts are
            %     ignored.
            
            ggParts = {};
            
            % Calculate the vertical position of all parts
            [Layout, ggMoments] = Layout.calc_position_vertical(ggMoments);
            % Calculate the horizontal position of all parts
            [Layout, ggMoments] = Layout.calc_position_horizontal(ggMoments);
            
            % Create waveguides which connect parts over multiple moments.
            [Layout, ggConnections] = Layout.generate_connections(ggMoments);
            
            ggParts = [ggParts ggConnections];
            
            % Iterate over all moments
            for j = 1:size(ggMoments, 2)
                % Iterate over all parts of each moment and place them to
                % their corresponding position.
                for k = 1:size(ggMoments{j}, 2)
                    % Place the current part
                    if ggMoments{j}{k}.Data.isKey('pos_y')
                        part = ggMoments{j}{k}.Data('ggPart');
                        
                        % Displace the part according to its position
                        ggPart = displaceGG(part, ggMoments{j}{k}.Data('pos_x'), ...
                            ggMoments{j}{k}.Data('pos_y'));
                        
                        ggParts = [ggParts ggPart];
                    end
                end
            end
            
            % TODO: Bend back when device is wider than the chip.
            % Use chip_width and chip_height properties.
            % Note: Check the location of the parts in order to figure out
            % how far to move upwards to place new parts. The new parts in
            % this upper section also can't shift too far down, as they would
            % otherwise interfere with the parts in the lower section.
            
        end
        
        function [Layout, ggParts, ggMoments] = generate_connections(Layout, ggMoments)
            %GENERATE_CONNECTIONS Generate connections between all parts.
            %   After the x and y positions of the parts are determined,
            %   connections between all parts are constructed.
            
            % Problem: Connecting waveguide could intersect a part, if a
            % connection between moments (moment distance > 1) is created.
            % Thus, it is necessary to adjust the xposition of such parts.
            % use build-waveguide function + update build-waveguide tu use
            % waveguide-sshape when not a pi deg bend is needed.
            
            ggParts = {};
            
            for j = 1:size(ggMoments, 2)
                for k = 1:size(ggMoments{j}, 2)
                    % Calculate locations for the connections for the
                    % current part.
                    [Layout, gPos] = Layout.calc_positions_connection(ggMoments{j}{k});
                   
                    if ~isempty(gPos)
                        for l = 1:size(gPos, 2)
                            if ~(gPos{l}{1} == gPos{l}{3}) || ~(gPos{l}{2} == gPos{l}{4})
                                pCon = waveguide_Sshape('layers', Layout.layers, ...
                                    'xstart', gPos{l}{1}, 'ystart', gPos{l}{2}, ...
                                    'xend', gPos{l}{3}, 'yend', gPos{l}{4}, ...
                                    'orientation', pi, ...
                                    'radius', Layout.bendradius, ...
                                    'wwg', Layout.wwg, 'cut', Layout.cut);
                                [pCon, ggCon] = pCon.generate_geometry();
                                ggParts = [ggParts ggCon];
                            end
                        end
                    end
                end
            end
        end
        
        function [Layout, gPositions] = calc_positions_connection(Layout, part)
            %CALC_POSITIONS_CONNECTION Calculate positions of connections.
            %   Calculate the (x,y) coordinates of prior part, as well as
            %   the (x,y) coordinates of the current part.
            %   The returned positions already take the part geometry into
            %   consideration.
            %   The positions are used to connect the two parts together.
            %
            %   Structure of each cell in gPositions:
            %       (prior_x, prior_y, current_x, current_y)
            
            gPositions = {};
            % Iterate over the inputs of the part
            for j = 1:size(part.In, 2)
                
                % Ignore unused ports
                if ~isempty(part.In{j})
                    % Add output location of prior part
                    pPrior = part.In{j}{2};
                    p_x = [];
                    p_y = [];
                    
                    % Calculate position of prior part
                    for k = 1:size(pPrior.Out, 2)
                        % Ignore unused ports
                        if ~isempty(pPrior.Out{k})
                            if ~isempty(pPrior.Data) && ...
                                    isa(pPrior.Out{k}, 'cell') && isa(part.In{j}, 'cell') ...
                                    && part.In{j}{1} == pPrior.Out{k}{1}
                                p_x = pPrior.Data('pos_x') + pPrior.Data('part_length')/2;
                                
                                switch pPrior.Data('part')
                                    case {directional_standard, waveguide_crossing, ...
                                            Hdirectional, waveguide_double}
                                        if k == 1
                                            p_y = pPrior.Data('pos_y') - pPrior.Data('part_height')/2;
                                        else
                                            p_y = pPrior.Data('pos_y') + pPrior.Data('part_height')/2;
                                        end
                                    otherwise
                                end
                            end
                        end
                    end
                    
                    % Calculate position of current part
                    if ~isempty(p_x) && ~isempty(p_y)
                        % Add input location of current part
                        c_x = part.Data('pos_x') - part.Data('part_length')/2;
                        c_y = [];
                        switch part.Data('part')
                            case {directional_standard, waveguide_crossing, waveguide_double}
                                if j == 1
                                    c_y = part.Data('pos_y') - part.Data('part_height')/2;
                                else
                                    c_y = part.Data('pos_y') + part.Data('part_height')/2;
                                end
                            case Hdirectional
                                if j == 1
                                    c_y = part.Data('pos_y') - 2.5;
                                else
                                    c_y = part.Data('pos_y') + 2.5;
                                end
                            otherwise
                                warning('Builder: No position found');
                        end
                        
                        gPositions{end+1} = {p_x, p_y, c_x, c_y};
                    end
                end
            end
        end
        
        function [Layout, ggMoments] = calc_position_horizontal(Layout, ggMoments)
            %CALC_POSITION_HORIZONTAL Calculate the horizontal position of parts.
            %    Calculate the horizontal position of all parts in each
            %    moment. The individual horizontal position of each part
            %    depends on the position of the part it depends on.
            %    The horizontal placement needs to take the connection of parts
            %    into account. A radius of a connection must not be smaller than
            %    a fixed bendradius.
            
            x_displ = 0;
            
            for j = 1:size(ggMoments, 2)
                % Get maximum moment length
                moment_length_max = Layout.calc_moment_length_full_max(ggMoments{j});
                
                x_add_offset = [0];
                for k = 1:size(ggMoments{j}, 2)
                    % Set preliminary horizontal position
                    pos_x = x_displ + ggMoments{j}{k}.Data('part_length')/2;
                    
                    % Calculate positions of ports of prior part
                    y_offset = [];
                    if iscell(ggMoments{j}{k}.In{1})
                        in = ggMoments{j}{k}.In{1}{2};
                        
                        if in.id ~= -1
                            if iscell(in.Out{1}) && ggMoments{j}{k}.In{1}{1} == in.Out{1}{1}
                                in_port_y = in.Data('pos_y') - in.Data('part_height')/2;
                            elseif iscell(in.Out{2})
                                in_port_y = in.Data('pos_y') + in.Data('part_height')/2;
                            end
                            
                            port_y = ggMoments{j}{k}.Data('pos_y') - ggMoments{j}{k}.Data('part_height')/2;
                            y_offset = [y_offset; abs(in_port_y - port_y)];
                        end
                    end
                    
                    if iscell(ggMoments{j}{k}.In{2})
                        in = ggMoments{j}{k}.In{2}{2};
                        
                        if in.id ~= -1
                            if iscell(in.Out{1}) && ggMoments{j}{k}.In{2}{1} == in.Out{1}{1}
                                in_port_y = in.Data('pos_y') - in.Data('part_height')/2;
                            elseif iscell(in.Out{2})
                                in_port_y = in.Data('pos_y') + in.Data('part_height')/2;
                            end
                            
                            port_y = ggMoments{j}{k}.Data('pos_y') + ggMoments{j}{k}.Data('part_height')/2;
                            y_offset = [y_offset; abs(in_port_y - port_y)];
                        end
                    end
                    
                    % Check if ports do not lineup
                    y_offset_max = max(y_offset);
                    if y_offset_max ~= 0
                        % TODO: calculate offset needed
                        
                        % Offset to add to part
                        x_add = 20;
                        x_add_offset = [x_add_offset; x_add];
                        pos_x = pos_x + x_add;
                    end
                    
                    ggMoments{j}{k}.Data('pos_x') = pos_x;
                end
                
                x_displ = x_displ + moment_length_max + max(x_add_offset);
            end
        end
        
        function [Layout, ggMoments] = calc_position_vertical(Layout, ggMoments)
            %CALC_POSITION_VERTICAL Calculate the vertical position of parts.
            %    Calculate the vertical position of all parts in each
            %    moment.
            
            gWave = containers.Map();
            
            for j = 1:size(ggMoments, 2)
                y_displ = 0;
                
                % Specify position of the parts in the current moment
                for k = 1:size(ggMoments{j}, 2)
                    
                    % Set position of current part according to the
                    % position to which it is connected to.
                    
                    if ~isempty(ggMoments{j}{k}.In{1}) && ~isempty(ggMoments{j}{k}.In{2})
                        if ggMoments{j}{k}.In{1}{2}.id == -1 && ggMoments{j}{k}.In{2}{2}.id ~= -1
                            % Lower input is set
                            y_displ = gWave(num2str(ggMoments{j}{k}.In{2}{1})) - ggMoments{j}{k}.Data('part_height')/2;
                        elseif ggMoments{j}{k}.In{2}{2}.id == -1 && ggMoments{j}{k}.In{1}{2}.id ~= -1
                            % Upper input is set
                            y_displ = gWave(num2str(ggMoments{j}{k}.In{1}{1})) + ggMoments{j}{k}.Data('part_height')/2;
                        elseif gWave.isKey(num2str(ggMoments{j}{k}.In{1}{1})) && gWave.isKey(num2str(ggMoments{j}{k}.In{2}{1}))
                            % Both inputs are set. Place the part between
                            % both inputs.
                            y_displ = 0.5*(gWave(num2str(ggMoments{j}{k}.In{1}{1})) + gWave(num2str(ggMoments{j}{k}.In{2}{1})));
                        end
                    else
                        if ~isempty(ggMoments{j}{k}.In{1})
                            y_displ = ggMoments{j}{k}.In{1}{2}.Data('pos_y') + ggMoments{j}{k}.In{1}{2}.Data('part_height');
                        elseif ~isempty(ggMoments{j}{k}.In{2})
                            y_displ = 30%ggMoments{j}{k}.In{2}{2}.Data('pos_y') - ggMoments{j}{k}.In{2}{2}.Data('part_height');
                        end
                    end
                    
                    % Check if any of the input ports cross with another
                    % part in a prior moment.
                    height = ggMoments{j}{k}.Data('part_height');
                    gPorts_y = {y_displ + height/2, y_displ - height/2};
                    
                    % Find ggMoment index of the connections of
                    % ggMoments{j}{k}. We only consider parts placed after
                    % these indexes as parts with which ggMoments{j}{k}
                    % crosses waveguides.
                    gIndex = Layout.find_moment(ggMoments, ggMoments{j}{k}.In);
                    
                    % Crossing can happen between current position and
                    % position of last connection
                    start = (min(gIndex{1}{1}, gIndex{2}{1}) + 1);
                    if start < 1
                        start = 1;
                    end
                    for l = start:(j-1)
                        for m = 1:size(ggMoments{l}, 2)
                            % Check location of ports of current
                            % part
                            height = ggMoments{l}{m}.Data('part_height');
                            pos_y = ggMoments{l}{m}.Data('pos_y');
                            gPorts_prior_y = {pos_y + height/2, pos_y - height/2};
                            
                            % Check for overlapping waveguides
                            offset = ggMoments{l}{m}.Data('part').wwg;
                            if (gPorts_prior_y{1} + offset > gPorts_y{1} && ...
                                    gPorts_prior_y{2} < gPorts_y{1}) %|| ...
                                %gPorts_prior_y{2}  + offset > gPorts_y{2}
                                
                                p1_delta_y = gPorts_prior_y{1} - gPorts_y{1};
                                p2_delta_y = gPorts_prior_y{1} - gPorts_y{1};
                                
                                % Check if parts are not connected
                                if isempty(ggMoments{l}{m}.Out{2}) || ...
                                        ggMoments{j}{k}.In{2}{2}.id ~= ggMoments{l}{m}.Out{2}{2}.id
                                    y_displ = y_displ + 5;
                                end
                                
                                if p1_delta_y ~= 0
                                    y_displ = y_displ + p1_delta_y + 5;
                                elseif p2_delta_y ~= 0
                                    %y_displ = y_displ - p1_delta_y - 5;
                                end
                            end
                        end
                    end
                    
                    % TODO: Check for parts in a moment overlapping with each
                    % other. This can happen, as some parts are higher
                    % than is visible by their WGPorts. See for example
                    % the Hdirectional.
                    
                    % Set position of current part
                    ggMoments{j}{k}.Data('pos_y') = y_displ;
                    
                    % Calculate the position of the outputs
                    for l = 1:size(ggMoments{j}{k}.Out, 2)
                        if size(ggMoments{j}{k}.Out{l}, 2) == 2
                            if l == 1
                                gWave(num2str(ggMoments{j}{k}.Out{l}{1})) = y_displ - ggMoments{j}{k}.Data('part_height')/2;
                            else
                                gWave(num2str(ggMoments{j}{k}.Out{l}{1})) = y_displ + ggMoments{j}{k}.Data('part_height')/2;
                            end
                        end
                    end
                    
                    % Add vertical displacement of next part in this
                    % moment.
                    if k < size(ggMoments{j}, 2)
                        y_displ = y_displ - ggMoments{j}{k+1}.Data('part_height')/2 - ggMoments{j}{k}.Data('part_height')/2;
                        
                        if (iscell(ggMoments{j}{k}.Out{1}) && iscell(ggMoments{j}{k+1}.Out{2})) && ...
                                (ggMoments{j}{k}.Out{1}{2}.id == ggMoments{j}{k+1}.Out{2}{2}.id)
                            y_displ = y_displ - ggMoments{j}{k}.Out{1}{2}.Data('part_height');
                        else
                            y_displ = y_displ - 7.5;
                        end
                    end
                end
            end
        end
            
        function gIndex = find_moment(Layout, ggMoments, moment)
            %FIND_MOMENT Find the index of the passed moment
            %   Given moment, find the index of it in ggMoments.
            
            gIndex = {};
            for l=1:size(moment, 2)
                set = false;
                
                if ~isempty(moment{l})    
                    for j = 1:size(ggMoments, 2)
                        for k = 1:size(ggMoments{j}, 2)
                            if ggMoments{j}{k}.id == moment{l}{2}.id
                                gIndex{end+1} = {j, k};
                                set = true;
                            end
                        end
                    end
                else
                    % Ignore such ports
                    gIndex{end+1} = {nan, nan};
                    set = true;
                end
                
                if ~set
                    % Connection with input source
                    gIndex{end+1} = {-1, -1};
                end
            end 
        end
        
        function [Layout, ggMoments] = generate_parts(Layout, ggMoments)
            %GENERATE_PARTS Generate all parts.
            %    Generate all entities of each moment and replace the data
            %    property of each llist with the part. The data entry then
            %    contains both the object of the part itself, as well as a
            %    array containing the structure.
            %    Generation does not involve any placement. All parts are
            %    located at their origin.
            
            % Iterate over all moments
            for j = 1:size(ggMoments, 2)
                % Iterate over all parts of each moment
                for k = 1:size(ggMoments{j}, 2)
                    [pPart, ggPart] = Layout.generate_part(ggMoments{j}{k});
                    ggMoments{j}{k}.Data = containers.Map({'part', 'ggPart'}, {pPart, ggPart});
                end
            end
        end
        
        function [pPart, ggPart] = generate_part(Layout, part)
            %GENERATE_PART Generate a part.
            %   Generate a part given an entitie of a moment. The generated
            %   parts do not have their correct position. Parts requiring
            %   start and end positions, start from the origin at (0,0).
            %   In order to query information about a part, it is necessary
            %   to call this function, in order to receive the object and
            %   gds structure of the part.
            %   All logical parts will receive the default physical part,
            %   i. e. a directional_coupler will generate the
            %   directional_standard.
            %   The final (physical) part will be chosen while placing the
            %   part.
            
            ggPart = {};
            pPart = [];
            
            switch lower(part.Data('part'))
                case 'directional_coupler'
                    [pPart, ggPart] = Part.directional_standard.build(Layout.geom, part.Data);
                case 'phase'
                    % Phase is applied to the |1> rail
                    %[pPart, ggPart] = Part.hdirectional.build(Layout.geom, part.Data);
                    [pPart, ggPart] = Part.waveguide_double.build(Layout.geom, part.Data);
                case 'waveguide_crossing'
                    [pPart, ggPart] = Part.waveguide_crossing.build(Layout.geom, part.Data);
                otherwise
                    warning('Part not supported!');
            end
        end
        
        function [Layout, width] = calc_circuit_width(Layout, ggMoments)
            %CALC_CIRCUIT_LENGTH Calculate width of circuit.
            %   Calculate the width (horizontal) of the circuit.
            
            width = 0;
            % Circuit start at x=0. For the end of the circuit, the part
            % with the biggest pos_x has to be found.
            % Note: the last moment does not necessarily contain the part
            % with the biggest pos_x!
            for j = 1:size(ggMoments, 2)
                for k = 1:size(ggMoments{j}, 2)
                    if ggMoments{j}{k}.Data('pos_x') + ...
                            ggMoments{j}{k}.Data('part_length')/2 > width
                        width = ggMoments{j}{k}.Data('pos_x') + ggMoments{j}{k}.Data('part_length')/2;
                    end
                end
            end
        end
        
        function [Layout, height] = calc_circuit_height(Layout, ggMoments)
           %CALC_CIRCUIT_HEIGHT Calculate height of circuit.
           %    Calculate the height (vertical) of the circuit.
           
           height = 0;
           %Layout.height = height;
        end
        
        function ggMoments = calc_moment_length(Layout, ggMoments)
            %CALC_MOMENT_LENGTH Calculate the physical length of a moment.
            %    Calculate the physical length of each entity in a moment
            %    given in ggMoments. The moment_length is used when placing
            %    the parts on the layout.
            %    A small moment_length keeps layouts small and allows for
            %    the placement of more parts when creating the physical
            %    circuit.
            
            % Iterate over each moment
            for j = 1:size(ggMoments, 2)
                gLength = {};
                
                % Iterate over each element
                for k = 1:size(ggMoments{j}, 2)
                    if isempty(ggMoments{j}{k}.Data('part'))
                        ggMoments{j}{k}.Data('part_length') = [];
                    else
                        % Figure out the correct physical part
                        part = ggMoments{j}{k}.Data('part');
                        ggMoments{j}{k}.Data('part_length') = part.WGports(2).x - part.WGports(1).x;
                    end
                end
            end
        end
        
        function length = calc_moment_length_full_max(Layout, gMoment)
            %CALC_MOMENT_LENGTH_FULL_MAX Calc max length of this moment
            %   Calculate the length of the passed moment, thus returning
            %   the length of the longest part.
            
            gLength = [];
            for j = 1:size(gMoment, 2)
                gLength = [gLength gMoment{j}.Data('part_length')];
            end
            
            length = max(gLength);
        end
        
        function ggMoments = calc_moment_height(Layout, ggMoments)
            %CALC_MOMENT_HEIGHT Calculate the physical height of a moment.
            %   Calculate the physical length of each entity in a moment
            %   given in ggMoments. The moment_height is used when placing
            %   the parts on the layout.
            %   A small moment_height keeps layouts small and allows parts
            %   to be placed closer together, resulting in the possible
            %   placement of more parts when creating the physical circuit.
            
            ggMoments_height = {};
            % Iterate over each moment
            for j = 1:size(ggMoments, 2)
                gHeight = {};
                
                % Iterate over each element
                for k = 1:size(ggMoments{j}, 2)
                    part = ggMoments{j}{k}.Data('part');
                    
                    % Figure out the correct physical part
                    switch lower(part)
                        case Hdirectional
                            warning('Generator: Hdirectional hardcoded height!');
                            ggMoments{j}{k}.Data('part_height') = 5;
                        otherwise
                            % TODO: deal with parts without WGports!
                            ggMoments{j}{k}.Data('part_height') = part.WGports(1).y - part.WGports(4).y;
                    end
                    
                end
                
                ggMoments_height{end + 1} = gHeight;
            end
        end
        
        function height = calc_moment_height_full(Layout, gMoment)
            %CALC_MOMENT_HEIGHT_FULL Calculate height of a moment.
            %   Calculate the height of the passed moment. The height of
            %   the moment is calculated using the heights of all parts in
            %   this moment.
            height = 0;
            
            for k = 1:size(gMoment, 2)
                height = height + gMoment{k}.Data('part_height');
            end
        end
        
        function ggMoments_sorted = sort_moments(Layout, ggMoments)
            %SORT_MOMENTS Sort parts in each moment.
            %   Sort all parts in each moment depending on their input
            %   waveguide. This is necessary as to avoid waveguides
            %   overlapping each other.
            %   Parts are sorted in ascending order of their input
            %   waveguides.
            
            ggMoments_sorted = {};
            
            for j = 1:size(ggMoments, 2)
                gNew = {};
                
                for k = 1:size(ggMoments{j}, 2)
                    part = ggMoments{j}{k};
                    
                    if isempty(gNew)
                        gNew{end + 1} = part;
                    else
                        in = part.get_in_min();
                        
                        % Ignore parts without input
                        if in ~= -1
                            inserted = false;
                            for l = 1:size(gNew, 2)
                                if gNew{l}.get_in_min() > in
                                    gOld = gNew(l:end);
                                    gNew = gNew(1:l-1);
                                    gNew{end + 1} = part;
                                    gNew = [gNew gOld];
                                    
                                    inserted = true;
                                    break;
                                end
                            end
                            if ~inserted
                                gNew{end + 1} = part;
                            end
                        end
                    end
                end
                ggMoments_sorted{end + 1} = gNew;
            end
        end
        
        function ggMoments = calc_moments(Layout)
            %CALC_MOMENTS Create a array of moments.
            %   The array contains all moments. Each moment contains all
            %   entities/parts that do not depend on each other. The
            %   layout of the moments influenz the physical layout of the
            %   circuit.
            
            ggMoments = {};
            moment = 0;
            
            % Add first elements (grating couplers)
            gNext = Layout.graph.get_out_all();
            newMoment = Layout.remove_duplicates(gNext);
            
            while(true)
                % Remove element from a prior moment if it appears in the
                % current moment.
                ggMoments = Layout.check_moments(ggMoments, newMoment);
                
                % Add this moment
                ggMoments{end + 1} = newMoment;
                
                % Add next entities to their correct moment
                gNext = {};
                for j = 1:size(newMoment, 2)
                    gNext = [gNext newMoment{j}.get_out_all()];
                end
                
                if isempty(gNext)
                    break;
                end
                % Remove empty cells
                gNext = gNext(~cellfun('isempty', gNext));
                
                % Remove duplicates, as multiple entities can point to the
                % same device
                gNext = Layout.remove_duplicates(gNext);
                newMoment = gNext;
                
                % Next moment
                moment = moment + 1;
            end
            
            % Remove empty moment
            ggMoments = ggMoments(~cellfun('isempty', ggMoments));
        end
        
        function ggMoments = check_moments(~, ggMoments, newMoment)
            %CHECK_MOMENTS Check consistency of all moments.
            %   Check if all prior moments in ggMoments do not contain a
            %   entitie/part, which is part of newMoment. If a entitie
            %   appears in ggMoments and newMoment, remove if from the
            %   moment in ggMoments.
            
            for j = 1:size(newMoment, 2)
                % Get id of entitie to check
                nId = newMoment{j}.id;
                
                % Iterate over all moments
                for k = 1:size(ggMoments, 2)
                    gMoment = ggMoments{k};
                    gMomentNew = {};
                    
                    % Remove entities from old moment
                    for moment = 1:size(gMoment, 2)
                        if gMoment{moment}.id ~= nId
                            gMomentNew{end + 1} = gMoment{moment};
                        end
                    end
                    
                    ggMoments{k} = gMomentNew;
                end
            end
        end
        
        function gList = remove_duplicates(~, gL)
            %REMOVE_DUPLICATES Removes duplicate elements.
            %   Remove entities in a array with the same id.
            
            gList = {};
            for k = 1:size(gL, 2)
                f = false;
                
                for j = 1:size(gList, 2)
                    if gList{j}.id == gL{k}.id
                        f = true;
                        break;
                    end
                end
                
                if ~f
                    gList{end + 1} = gL{k};
                end
            end
        end
        
        function ggMoments = remove_empty(~, ggMoments)
            %REMOVE_EMPTY Remove empty parts
            %   Remove all entries in ggMoments which do not have any part set
            
            for j = 1:size(ggMoments, 2)
                gMomentNew = {};
                
                % Remove empty parts
                for k = 1:size(ggMoments{j}, 2)
                    if ~isempty(ggMoments{j}{k}.Data('part'))
                        gMomentNew{end + 1} = ggMoments{j}{k};
                    end
                end
                
                ggMoments{j} = gMomentNew;
            end
        end
    end
end

