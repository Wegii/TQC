classdef Interface < devoppo
    %INTERFACE Generate inputs and outputs to the circuit.  
    %   Generate both inputs and outputs (GCs, cantilever, SNSPDs, etc.) to
    %   the circuit itself. 
    %   Both the in-/output part, as well as the connection from the
    %   in-/output parts to the circuit are generated.
    
    properties
        config;
        geom;
    end
    
    methods (Access = public)
        function Iface = Interface(config, geom)
            %INTERFACE Generate in-/ and outputs to the circuit.
            
            supervarargs = {0, 0, geom, '', ''};
            Iface@devoppo(supervarargs{:})
           
 \chapter{Layout Generation and Fabrication}
    In the first section, IC layout generation is introduced. This goes trough the different stages, necessary going from a abstract description to a layout ready for nanofabrication. Specific focus on placement and routing. These will again be of importance in Chapter \ref{chapter:tqc}

    In the second section, nanofabrication is introduced. After having generated a layout in the first section, nanofabrication is performed, in order to physically build the circuit. This is important when developing a compiler framework in Chapter \ref{chater:tqc}. 
    % TODO: Better text

\section{IC Layout generation}
    Integrated Circuit (IC) Layout generation concerns itself with the generation of integrated circuits. The generation is often supported by software designed for electronic design automation (EDA). This allows for easier design of ICs. Due to the complexity of the developed circuits, it is necessary to understand many aspect of the design flow, starting from a abstract high-level description down to the fabrication level.
    Given the many topics and tasks fulfilled by IC layout generation, only the most important tasks are described in detail. The focus here lies in the physical design phase, placement phase, and network routing phase.
    
    \subsection{Physical design}
        The physical design phase concerns itself with the physical design of the circuit to be developed. It is possible to break down this phase into multiple distinct stages. These stages are not necessarily the only stages that need to be taken care of, but the most important for the following sections.
        \begin{description}
            \item[Partitioning] Breaks the circuit down into smaller parts, sub-circuits or modules. These smaller parts can then be designed on independently of each other. This way, the circuit is structured into smaller parts.
            \item[Floorplanning] The smaller structures receive a potential shape and are arranged in a way, that the whole circuit can be fabricated given a multitude of physical constraints. Furthermore external blocks and ports (e. g. electrical power routing) are located. 
            \item[Placement] All cells in each structure is placed on the physical layout. The stage is divided into global and detailed placement
            \item[Network routing] During routing, precise paths for all networks on the circuit are determined. Routing resources for connections are allocated and then used in track laying (laying the physical track of a network).
        \end{description}

        The physical design stage receives an abstract description of the circuit to be generated. All components utilized (cells, transistors, gates, etc.) are instantiated/generated and a geometric representation is assigned in order determine the location on the layout (see placement stage). Additionally, routing is completed in order to connect all specified networks. As a result, the physical design stage returns a layout in the form of manufacturing specifications. Afterwards, it is possible to start the fabrication process, but in general, this stage is follow by many other stages. Most prominent is the verification stage, in which the generated layout is verified.
    
        Some of the biggest challenges for IC design is the placement and routing phase, in which all components are placed on chip and routed. These two tasks are described in detail in Section \ref{section:icl-placement} and Section \ref{section:icl-routing}.
        
    \subsection{Placement}\label{section:icl-placement}
        The objective of the placement stage is to place all parts (circuit elements) on a layout, given specified constraints and potentially certain metrics to optimize. Placing a port on the layout includes determining its location and orientation. After placing all parts on a chip, network routing (see Section \ref{section:icl-routing}) is applied. Thus, it is important that placement takes this into considerations, as this will determine the efficiency, quality and routability in the subsequent stage.
        Placement, thus results in a list of locations of all parts to be placed, with all networks of the chip being routable.

        Many modern ICs are very complex and consists of millions of parts and transistors. In order to allow for efficient placement of all parts and structuring of smaller modules (making up the circuit itself), placement is divided into global placement and detailed placement.
            
        \textbf{Global placement}
            The specific shape and size of circuit elements are neglected, and multiple small circuit elements are often viewed as a single one. The goal is not to find a final place for all parts, but rather to find a rough location for macro blocks (representing smaller circuit elements). These locations do not need to align with e. g. the underlying coarse coordinate grid. After all macro blocks are assign a rough location, detailed placement is performed.
    
        \textbf{Detailed placement}
            After rough locations have been determined, detailed placement seeks to align all elements (circuit elements, macro blocks) with the underlying coordinate grid. Furthermore, all parts and their corresponding location is considered in detail. Detailed placement can be applied in a iterative manner in order to improve the location of all elements incrementally. Even though rough locations were determined, it is possible that some elements may be swapped or moved around in order to make room for other elements.
        
    \subsection{Network Routing}\label{section:icl-routing}
        After placement is performed, parts requiring electrical wiring, routing is performed. Similar to the Placement stage, routing is generally divided in two distinct parts: global and detailed routing. During routing, precise signal paths are generated, connecting all specified nets on the received c
        
        The routing process determines the precise signal paths for nets on the chip layout. To handle the high complexity in modern chip design, routing algorithms often adopt a two-stage approach: global routing followed by detailed routing. Global routing first partitions the chip into routing regions and searches for region-to-region paths for all signal nets. 
        On the other hand, detailed routing determines the exact tracks and vias of these nets based on their region assignments
    
        A net is a set of two or more pins that have the same electric potential. During the routing process, the pins must be connected using wire segments. Given a placement and a netlist, determine the necessary wiring, e.g., net topologies and specific routing segments, to connect these cells while respecting constraints, e.g., design rules and routing resource capacities, and optimizing routing objectives, e.g., minimizing total wirelength and maximizing timing slack.
    
        To model the global routing problem, the routing regions are represented using efficient data structures [18]. Typically, the routing context is captured using a graph, where nodes represent routing regions and edges represent adjoining regions.
        
        \subsubsection{Global Routing}
            Single net routing, where networks are routed sequentially. There also exists Full-Netlist routing, in which all networks are considered simultaneously. 
            
            p.149 in Book: 
            Can be decomposed into multiple steps:
            Definition of Routing regions
            Definition of Connectivity Graph
            Construction of Net Order: One of the most important steps in routing, as ordering of nets often determines if all networks can be routed or not. NP complex problem
            Assign Tracks for all Connections
            Perform routing
    
            Rip-up and reroute (RRR): 
            Single-net routing might also require considering multiple nets at one time. First, all nets are routed by allowing temporary violations but then some nets are iteratively removed (ripped up). This is the case for those nets that cause resource contention or overflow for routing edges. These nets are later rerouted with fewer or no violations. Rip-up and reroute iterations continue until all nets are routed without violating capacities of routing-grid edges or until a time-out is exceeded
            
        \subsubsection{Detail Routing}
            The objective of detailed routing is to assign route segments of signal nets to specific routing tracks, vias, and metal layers in a manner consistent with given global routes of those nets. These detailed route assignments must respect all design rules.
    
    
    (978-3-030-96415-3.pdf aufm Laptop)
    

\section{Nanofabrication}
    \begin{figure*}
        \includegraphics[width=15.5cm]{figures/nanofabrication/nanofabrication.png}
        \caption{\label{fig:nanofabrication} Visualization of different steps performed during nanofabrication for fabrication optical quantum circuits. The general steps are as follows: Application of photoresist, lithography and lift-off, followed by etching. An in-depth description can be found in section \ref{sec:nanofabrication}.}
    \end{figure*}
        
        \noindent The last challenge of LOQC in this paper is the fabrication of the photonic quantum circuits and their integration into the SOI platform. This includes not only the fabrication of nanoscale structures, but also the preferably \textit{perfect} and consistent fabrication of large-scale circuits with hundreds of different parts. In order to understand the many challenges to tackle, the fabrication process first needs to be understood.

        Figure \ref{fig:nanofabrication} visualizes different steps needed to fabricate a SOI chip: \textbf{I} The first inset shows the three major layers of a chip. The SiN substrate provides of a unified platform on which further layers are placed. The Si$\text{O}_2$ on top serves as the cladding material for waveguides, but is also used for defining movable mechanical structures. The third layer consists of high-stress S$\text{i}_3\text{N}_4$ from which the waveguides are constructed. \textbf{II} In order to define any structures on the chip, lithography steps have to be performed. Visible in the second inset, photoresist is spincoated. \textbf{III} The actual lithography operation the involves the exposure to a predefined pattern. \textbf{IV} Visible in inset four and five, a metal layer is deposited and removed using the lift-off process. \textbf{V} Inset 6 - 8 show the construction of waveguides. This procedures is again done using further lithography operations (as described in step \textbf{II-III}). Inset 8 shows the removal of Si$\text{O}_2$ and S$\text{i}_3\text{N}_4$ using the reactive-ion etching process. Depending on the etching time, the etching depth can be varying (as visible in inset 9). \textbf{V} Inset 9 shows the chip with waveguides and electrodes (metal layer). In order to create free-hanging and movable structures, wet etching of these mechanical structures is performed. This can be done by using buffered oxide etching (BOE), which is a wet etchant. The wet etchant is thus able to etch the underlying Si$\text{O}_2$ away. This releases the mechanical structure. Afterwards, the chip is dried using critical point drying. This is especially important in order to not expose the structures to high stress during the drying process. 
        % Add HSQ, Pmma, medusa

        It follows, that such chips do not necessarily have to contain only photonic parts, but may also contain mechanical structures. Furthermore, the S$\text{i}_3\text{N}_4$ may also be replaced by AlN. This replacement can be favourable to induce different effects, which are not easily achievable with S$\text{i}_3\text{N}_4$, such as SPDC. A AlN-on-Insulator device, with AlN sputtered onto the oxide, is visible in figure \ref{fig:spdc}. 

        Major issues can occur during the photolithography process. Such issues include stitching errors due to limited size of the main-field size. Typical values are 200-500 $\mu$m, whereas bigger main-field sizes can lead to inaccuracies due to the growing beam-landing angle.

        Future generations of chips will thus be only limited by the nanofabrication process \cite{Poot2014}\cite{Poot2016}\cite{Politi2008}.

        \begin{figure*}
            \includegraphics[width=5cm]{figures/nanofabrication/nanofabrication_stitching_error_new.png}
            \includegraphics[width=5cm, height=3.78cm]{figures/nanofabrication/nanofabrication_alignment_error.png}
            \includegraphics[width=5cm, height=3.78cm]{figures/nanofabrication/nanofabrication_roughness.png}
            \caption{\label{fig:nanofabrication_errors} Micrograph of waveguide with stiching error (Stitching error of waveguides that happened between two fabrication steps. Stitching of waveguides together do have a small offset. Stitching error visible in red guiding lines). SEM image of displacement error during different fabrication steps. Roughnesss of waveguides.}
            % Add image of rough/broken waveguide
        \end{figure*}


\section{Process}
% Overview of the nanofabrication process


\section{Challenges}
    %\begin{comment}
    Stitching errors -> maybe picture with those (sebastian, xiong)
        Can happen:
        -> In one lithography step
        -> Alignment errors of different fabrication steps (human error, different machines (software, etc.))
        What to use to counter this issue:
            -> Markers (crosses) -> Different machines, need possible different machines. Markers can get lost due to evaporation, or etching etc..
            -> Software (precision)
    
    Different materials
        -> More materials, more singular steps needed, thus more error prone
            -> want high yield
    
    Waveguides
        -> Sollten nicht zu rau sein
        -> RIE
            -> anstelle von rechteck, trapez, also keine gerade kanten
    
    Resist
        Resistarten:
            Photresist
                -> Chemische Reaktion bei photonen
            Electroresist (for e-beam)
                -> Chemische Reaktion bei elektronen
        Verwendung:
            Positive
            Negative
        S:
            -> Verschiedene Dicken
            -> Verschiedene Härten
            -> Reaktion bei verschiedenen Wellenlänge
            -> Verhalten: Resist Übrig vs Dosis
            -> Grayscale lithography or not
            -> Depends on material used on which it is applied
            -> Verschiedene Haftung auf material
    %\end{comment}
                
                
    \subsection{Large scale fabrication}
    Some challenges only occur on the level of a research based fabrication process, done in Universities. Some challenges can be resolved when switching to a industrial level of fabrication. No longer any interference of other groups, no contamination due to other persons, no unwanted change of settings of utilized machines.
    
    %\begin{comment}
        Challenges
            -> On a research based level
                etching
                    -> contamination due to other persons. Unwanted change of recipes 
    
            -> On a industrial level
                Alignment can possible be resolved.
                Use big maskes (chromium masks), and no e-beam.
    %\end{comment}
    
    
    \subsection{Wires}
    \subsection{Bridges}            Iface.config = config;
            Iface.geom = geom;
        end
        
        function [Iface, ggInput, gc_positions, gc_orientations] = generate_input(Iface, ggMoments, displacement)
            %GENERATE_INPUT Generate the input parts.
            %   The input of the circuit can consist of different parts.
            %   It is possible to place a off-chip photon source, which
            %   utilizes GCs for coupling light to the chip.
            %   Another option is the generation of photon on-chip.
            %   possible parts for this are a the add drop ring for SPDC,
            %   or the cantilever.
            %   In general, the input structures need to be vertically (or
            %   horizontally) aligned.
            
            % Get locations of input waveguides
            gWG_position = {};
            % Iterate over every moment
            for k = 1:size(ggMoments, 2)
                % Iterate over each part of the respective moment
                for j = 1:size(ggMoments{k}, 2)
                    % Iterate over all inputs of each respective part
                    for l = 1:size(ggMoments{k}{j}.In, 2)
                        % All inputs with a connection to the inital part
                        % with id = -1, will receive an input connection.
                        if ~isempty(ggMoments{k}{j}.In{l}) && ggMoments{k}{j}.In{l}{2}.id == -1
                            switch ggMoments{k}{j}.Data('part')
                                case {directional_standard, waveguide_crossing, ...
                                        Hdirectional, waveguide_double}
                                    x = ggMoments{k}{j}.Data('pos_x') - ggMoments{k}{j}.Data('part_length')/2;
                                    if l == 2
                                        y = ggMoments{k}{j}.Data('pos_y') + ggMoments{k}{j}.Data('part_height')/2;
                                    else
                                        y = ggMoments{k}{j}.Data('pos_y') - ggMoments{k}{j}.Data('part_height')/2;
                                    end
                                    
                                    gWG_position{end+1} = {x, y};
                                    %gWG_position{end+1} = {x, yL};
                                otherwise
                            end
                        end
                    end
                end
            end
            
            % Sort connection locations according to their position
            gWG_position = Iface.sort_position(gWG_position);
            
            ggInput = {};
            gc_positions = {};
            gc_orientations = {};
            if Iface.config.in_GC_only
                [Iface, ggInput, gc_positions, gc_orientations] = Iface.generate_input_GC_only(gWG_position, ggMoments, displacement);
            else
                % TODO: Add option to generate a combination of different
                %       input parts.
            end
        end
        
        function [Iface, ggOutput, gc_positions, gc_orientations] = generate_output(Iface, ggMoments, displacement)
            %GENERATE_OUTPUT Generate the output parts.
            %   The output of the circuit can consist of different parts.
            %   It is possible to detect photons off-chip. For this, GCs
            %   can be utilized.
            %   Another option is on-chip detection using SNSPDs. For this,
            %   the SNSPDs are placed at the end of the waveguides, in
            %   which photons should be detected.
            %   In general, only the GCs need to vertically aligned. The
            %   SNSPDs can differ in the alignment, as such are connected
            %   to contact_pads for readout.
            
            % Get locations of output waveguides. The output waveguide is
            % not necessarily located in the last moment.
            gWG_position = {};
            for j = 1:size(ggMoments, 2)
                for k = 1:size(ggMoments{j}, 2)
                    % Parts whith output waveguides have the #waveguide in
                    % their out parameter instead of pointing to the next
                    % part.
                    % Note: This works only for parts with two output ports
                    for l = 1:size(ggMoments{j}{k}.Out, 2)
                        if isnumeric(ggMoments{j}{k}.Out{l})
                            % Part with output waveguide
                            switch ggMoments{j}{k}.Data('part')
                                case {directional_standard, waveguide_crossing, ...
                                        Hdirectional, waveguide_double}
                                    x = ggMoments{j}{k}.Data('pos_x') + ggMoments{j}{k}.Data('part_length')/2;
                                    if l == 1
                                        y = ggMoments{j}{k}.Data('pos_y') - ggMoments{j}{k}.Data('part_height')/2;
                                    else
                                        y = ggMoments{j}{k}.Data('pos_y') + ggMoments{j}{k}.Data('part_height')/2;
                                    end
                                    
                                    gWG_position{end+1} = {x, y};
                                otherwise
                            end
                        end
                    end
                end
            end
            
            % Sort connection locations according to their position
            gWG_position = Iface.sort_position(gWG_position);
            
            ggOutput = {};
            gc_positions = {};
            gc_orientations = {};
            if Iface.config.out_GC_only
                [Iface, ggOutput, gc_positions, gc_orientations] = ...
                    Iface.generate_output_GC_only(gWG_position, ggMoments, displacement);
            else
                % TODO: Add option to generate a combination of different
                %       output parts.
            end
        end
    end
    
    methods(Access = private)
        function [Iface, ggInput, gc_positions, gc_orientations] = generate_input_GC_only(Iface, gWG_position, ggMoments, displacement)
            %GENERATE_INPUT_GC_ONLY Generate GCs as input only.
            %   Generate only GCs for coupling light on the chip. The GCs
            %   can have different alignment.
            
            ggInput = {};
            
            % Spacing between waveguides going out of the GCs
            waveguide_spacing = 10;
            
            % Number of GCs
            GC_num = size(gWG_position, 2);
            
            switch(lower(Iface.config.alignment))
                case 'vertical'
                    pos_y = -(GC_num-1):2:(GC_num-1);
                    gc_positions = transpose(vertcat(zeros(size(pos_y)), pos_y))*Iface.geom.fiberpitch/2;
                    
                    % Center GCs and calculate x_offset. x_offset specifies
                    % distance between GCs and circuit.
                    x_offset = -((GC_num/2) - 1)*waveguide_spacing - 2*Iface.geom.bendradius;
                    % Adjust for minimum FA distance
                    x_offset = x_offset + 0;
                    
                    gc_positions = gc_positions + ...
                        [x_offset, (gWG_position{end}{2} + gWG_position{1}{2})/2];
                    gc_orientations = zeros(size(pos_y));
                    
                    % Generate connections from GCs to waveguide
                    low = (GC_num)/2 - 1;
                    low_init = low;
                    up = low;
                    up_init = up;
                    for j = 1:size(gc_positions, 1)
                        x = gc_positions(j, 1);
                        y = gc_positions(j, 2);
                        y_end = gWG_position{end - j + 1}{2};
                        x_end = gWG_position{end - j + 1}{1};
                        
                        if gc_positions(j, 2) < 0
                            % Lower GCs
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y; ...
                                x + low*waveguide_spacing + Iface.geom.bendradius, y;
                                %-Iface.geom.bendradius-(low_init - low)*waveguide_spacing, y_end;
                                x_end, y_end;]);
                            
                            low = low-1;
                        else
                            % Upper GCs
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y; ...
                                x + (up_init - up)*waveguide_spacing + Iface.geom.bendradius, y;
                                -Iface.geom.bendradius - up*waveguide_spacing, y_end;
                                x_end, y_end;]);
                            up = up-1;
                        end
                        
                        ggInput = [ggInput ggConnection];
                    end
                    
                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                    
                    % Align GCs horizontally
                    for j=1:size(gc_positions)
                        gc_x = -gc_positions(j, 2);
                        gc_positions(j, 2) = gc_positions(j, 1);
                        gc_positions(j, 1) = gc_x;
                    end
                case 'horizontal'
                     % Center GCs and add y_offset
                    [Iface, width] = Iface.calc_circuit_width(ggMoments);
                    pos_x = (0:2:2*(GC_num-1)) - (GC_num-1);
                    gc_positions = transpose(vertcat(pos_x, zeros(size(pos_x))))*Iface.geom.fiberpitch/2;
                    % Rightmost input GC starts fiberpitch/2 left of the
                    % center. All other input GCs are to the left.
                    gc_positions = gc_positions + [width/2, 0];
                    
                    % Number of GCs that need vertical waveguide_spacing
                    num_offset = size(gc_positions(~cellfun(@(e)e <= -Iface.geom.bendradius, ...
                        num2cell(gc_positions(:, 1))), :), 1) - 1;
                    
                    % Minimum possible distance between GCs and circuit.
                    % Connection consists of a minimum of three waveguide bends
                    circuit_connection_distance = -3*Iface.geom.bendradius - num_offset*waveguide_spacing + ...
                        gWG_position{end}{2};
                    % FAs (in this case opposite GC arrays) can have a minimum
                    % distance of oppo_distance, as defined in the config
                    % file.
                    % Select either -oppo_distance/2 or minimum required
                    % distance.
                    y_offset = min(circuit_connection_distance, -Iface.config.oppo_distance/2);
                    gc_positions = gc_positions + [0, y_offset];
                    
                    gc_orientations = zeros(size(pos_x));
                    
                    % Connection between GCs and circuit
                    [Iface, ggInput] = Iface.generate_input_connection(gWG_position, ...
                                       gc_positions, waveguide_spacing, num_offset);
                    
                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                case 'bottom'
                    % Center GCs and add y_offset
                    [Iface, width] = Iface.calc_circuit_width(ggMoments);
                    pos_x = -2*(GC_num - 0.5):2:-1;
                    gc_positions = transpose(vertcat(pos_x, zeros(size(pos_x))))*Iface.geom.fiberpitch/2;
                    % Rightmost input GC starts fiberpitch/2 left of the
                    % center. All other input GCs are to the left.
                    gc_positions = gc_positions + [width/2, 0];
                    
                    % Number of GCs that need vertical waveguide_spacing
                    num_offset = size(gc_positions(~cellfun(@(e)e <= -Iface.geom.bendradius, ...
                        num2cell(gc_positions(:, 1))), :), 1) - 1;
                    
                    % Distance between GCs and circuit
                    y_offset = -3*Iface.geom.bendradius - num_offset*waveguide_spacing + ...
                        gWG_position{end}{2};
                    gc_positions = gc_positions + [0, y_offset];
                    
                    gc_orientations = zeros(size(pos_x));
                    
                    % Connection between GCs and circuit
                    [Iface, ggInput] = Iface.generate_input_connection(gWG_position, ...
                                       gc_positions, waveguide_spacing, num_offset);
                                   
                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                otherwise
                    warning('Builder: Input alignment not supported!');
            end
            
            % TODO: Add description to GCs: e. g. In <WaveguideNumber> 1550
        end
        
        function [Iface, ggInput] = generate_input_connection(Iface, gWG_position, gc_positions, ...
                                    waveguide_spacing, num_offset)
            %GENERATE_INPUT_CONNECTION Generate connection between circuit and input source.
            %   Generate waveguides connecting the input photon sources to
            %   the input waveguides of the circuit.
            
            ggInput = {};
            
            switch(lower(Iface.config.alignment))
                case 'vertical'
                case {'horizontal', 'bottom'}
                    num_offset_init = num_offset;
                    
                    for j = 1:size(gc_positions, 1)
                        x = gc_positions(j, 1);
                        y = gc_positions(j, 2);
                        y_end = gWG_position{j}{2};
                        x_end = gWG_position{j}{1};
                        
                        if gc_positions(j, 1) <= -Iface.geom.bendradius
                            % Only one bend to the right needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y_end;
                                x_end, y_end;]);
                        else
                            % Bend to left and right needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y + Iface.geom.bendradius + (num_offset_init - num_offset)*waveguide_spacing;
                                -num_offset*waveguide_spacing - Iface.geom.bendradius, ...
                                y + Iface.geom.bendradius + (num_offset_init - num_offset)*waveguide_spacing;
                                -num_offset*waveguide_spacing - Iface.geom.bendradius, y_end;
                                x_end, y_end;
                                ]);
                            
                            num_offset = num_offset - 1;
                        end
                        
                        ggInput = [ggInput ggConnection];
                    end
            end
        end
        
        function [Iface, ggOutput, gc_positions, gc_orientations] = generate_output_GC_only(Iface, gWG_position, ggMoments, displacement)
            %GENERATE_OUTPUT_GC_ONLY Generate GCs as output only.
            %   Generate only GCs for coupling light off the chip. The GCs
            %   can have different alignment.
            
            ggOutput = {};
            
            % Spacing between waveguides going into the GCs
            waveguide_spacing = 10;
            
            % Number of GCs
            GC_num = size(gWG_position, 2);
            
            switch(lower(Iface.config.alignment))
                case 'vertical'
                    pos_y = -(GC_num-1):2:(GC_num-1);
                    gc_positions = transpose(vertcat(zeros(size(pos_y)), pos_y))*Iface.geom.fiberpitch/2;
                    
                    % Center GCs and add x_offset
                    [Iface, width] = Iface.calc_circuit_width(ggMoments);
                    x_offset = ((GC_num/2) - 1)*waveguide_spacing + 2*Iface.geom.bendradius;
                    x_offset = x_offset + width;
                    gc_positions = gc_positions + ...
                        [x_offset, (gWG_position{end}{2} + gWG_position{1}{2})/2];
                    gc_orientations = pi + zeros(size(pos_y));
                    
                    % Generate connections from GCs to waveguide
                    low = (GC_num)/2 - 1;
                    low_init = low;
                    up = low;
                    up_init = up;
                    for j = 1:size(gc_positions, 1)
                        x = gc_positions(j, 1);
                        y = gc_positions(j, 2);
                        y_end = gWG_position{end - j + 1}{2};
                        x_end = gWG_position{end - j + 1}{1};
                        
                        if gc_positions(j, 2) < 0
                            % Lower GCs
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y; ...
                                x - low*waveguide_spacing - Iface.geom.bendradius, y;
                                width + Iface.geom.bendradius+(low_init - low)*waveguide_spacing, y_end;
                                x_end, y_end;]);
                            
                            low = low-1;
                        else
                            % Upper GCs
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y; ...
                                x - (up_init - up)*waveguide_spacing - Iface.geom.bendradius, y;
                                width + Iface.geom.bendradius + up*waveguide_spacing, y_end;
                                x_end, y_end;]);
                            
                            up = up-1;
                        end
                        
                        ggOutput = [ggOutput ggConnection];
                    end
                    
                    % Align input and output GCs vertically.
                    % Calculate the smallest vertical offset between
                    % input and output GCs
                    offset = -1;
                    if ~isempty(Iface.gc_positions)
                        % Iterate over output
                        for j = 1:size(gc_positions, 1)
                            % Iterate over input
                            for k = 1:size(Iface.gc_positions, 1)
                                c_offset = gc_positions(j, 2) - Iface.gc_positions(k, 2);
                                
                                if (abs(c_offset) < abs(offset)) || offset == -1
                                    offset = c_offset;
                                end
                            end
                        end
                    end
                
                    % Add offset to all output GC positions
%                     for j = 1:size(gc_positions, 1)
%                        gc_positions(j, 2) = gc_positions(j, 2) - offset;  
%                     end
                    
                    warning('Output - GC - Vertical - Alignment not tested!')
                    
                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                    
                    % Align GCs horizontally
                    for j=1:size(gc_positions)
                        gc_x = -gc_positions(j, 2);
                        gc_positions(j, 2) = gc_positions(j, 1);
                        gc_positions(j, 1) = gc_x;
                    end
                case 'horizontal'
                    % Center GCs and add y_offset
                    [Iface, width] = Iface.calc_circuit_width(ggMoments);
                    %pos_x = 1:2:2*(GC_num - 0.5);
                    pos_x = (0:2:2*(GC_num-1)) - (GC_num-1);
                    gc_positions = transpose(vertcat(pos_x, zeros(size(pos_x))))*Iface.geom.fiberpitch/2;
                    % Rightmost input GC starts fiberpitch/2 left of the
                    % center. All other input GCs are to the left.
                    gc_positions = gc_positions + [width/2, 0];
                    
                    % Number of GCs that need vertical waveguide_spacing
                    num_offset = size(gc_positions(~cellfun(@(e)e >= Iface.geom.bendradius + width, ...
                        num2cell(gc_positions(:, 1))), :), 1) - 1;
                    
                    % Minimum possible distance between GCs and circuit.
                    % Connection consists of a minimum of three waveguide bends
                    circuit_connection_distance = 3*Iface.geom.bendradius + num_offset*waveguide_spacing + ...
                        gWG_position{1}{2};
                    % FAs (in this case opposite GC arrays) can have a minimum
                    % distance of oppo_distance, as defined in the config
                    % file.
                    % Select either oppo_distance/2 or minimum required
                    % distance.
                    y_offset = max(circuit_connection_distance, Iface.config.oppo_distance/2);
                    gc_positions = gc_positions + [0, y_offset];
                  
                    gc_orientations = pi + zeros(size(pos_x));
                    
                    % Generate connection between waveguides and GCs
                    [Iface, ggOutput] = Iface.generate_output_connection(gWG_position, ...
                                        gc_positions, waveguide_spacing, num_offset, width);

                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                case 'bottom'
                    % Center GCs and add y_offset
                    [Iface, width] = Iface.calc_circuit_width(ggMoments);
                    pos_x = 1:2:2*(GC_num - 0.5);
                    gc_positions = transpose(vertcat(pos_x, zeros(size(pos_x))))*Iface.geom.fiberpitch/2;
                    % Rightmost input GC starts fiberpitch/2 left of the
                    % center. All other input GCs are to the left.
                    gc_positions = gc_positions + [width/2, 0];
                    
                    % Number of GCs that need vertical waveguide_spacing
                    num_offset = size(gc_positions(~cellfun(@(e)e >= Iface.geom.bendradius + width, ...
                        num2cell(gc_positions(:, 1))), :), 1) - 1;
                    num_offset_init = num_offset;
                    
                    % Distance between GCs and circuit
                    y_offset = -3*Iface.geom.bendradius - num_offset*waveguide_spacing + ...
                        gWG_position{end}{2};
                    gc_positions = gc_positions + [0, y_offset];
                    
                    gc_orientations = zeros(size(pos_x));
                    
                    for j = 1:size(gc_positions, 1)
                        x = gc_positions(j, 1);
                        y = gc_positions(j, 2);
                        y_end = gWG_position{end - j + 1}{2};
                        x_end = gWG_position{end - j + 1}{1};
                        
                        if gc_positions(j, 1) >= width + Iface.geom.bendradius
                            % Only one bend to the right needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y_end;
                                x_end, y_end;]);
                        else
                            % Bend to right and left needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y + Iface.geom.bendradius + num_offset*waveguide_spacing;
                                width + (num_offset_init - num_offset)*waveguide_spacing + Iface.geom.bendradius, ...
                                y + Iface.geom.bendradius + num_offset*waveguide_spacing;
                                width + (num_offset_init - num_offset)*waveguide_spacing + Iface.geom.bendradius, y_end;
                                x_end, y_end;
                                ]);
                            
                            num_offset = num_offset - 1;
                        end
                        
                        ggOutput = [ggOutput ggConnection];
                    end
                    
                    % Align input and output GCs horizontally.
                    % Calculate the smallest vertical offset between
                    % input and output GCs
                    offset = -1;
                    if ~isempty(Iface.gc_positions)
                        % Iterate over output
                        for j = 1:size(gc_positions, 1)
                            % Iterate over input
                            for k = 1:size(Iface.gc_positions, 1)
                                c_offset = gc_positions(j, 2) - Iface.gc_positions(k, 2);
                                
                                if (abs(c_offset) < abs(offset)) || offset == -1
                                    offset = c_offset;
                                end
                            end
                        end
                    end

                    % Align GCs with Circuit
                    gc_positions = gc_positions + displacement;
                    
                    warning('Output - GC - Bottom - Alignment not tested and implemented!')
                otherwise
                    warning('Builder: Output alignment not supported!');
            end
            
            % TODO: Add description to GCs: e. g. Out <WaveguideNumber> 1550
        end
        
        function [Iface, ggOutput] = generate_output_connection(Iface, gWG_position, gc_positions, ...
                                     waveguide_spacing, num_offset, width)
            %GENERATE_INPUT_CONNECTION Generate connection between circuit and output source.
            %   Generate waveguides connecting the output photon detectors to
            %   the output waveguides of the circuit.
            
            ggOutput = {};
            
            switch(lower(Iface.config.alignment))
                case 'vertical'
                case {'horizontal', 'bottom'}
                    num_offset_init = num_offset;
                    %num_offset = 0;
                    
                    for j = 1:size(gc_positions, 1)
                        x = gc_positions(j, 1);
                        y = gc_positions(j, 2);
                        x_end = gWG_position{j}{1};
                        y_end = gWG_position{j}{2};
                        
                        if gc_positions(j, 1) >= width + Iface.geom.bendradius
                            % Only one bend to the right needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y_end;
                                x_end, y_end;]);
                        else
                            % Bend to right and left needed
                            [Iface, ggConnection] = Iface.build_waveguide([...
                                x, y;
                                x, y - Iface.geom.bendradius - num_offset*waveguide_spacing;
                                width + (num_offset_init - num_offset)*waveguide_spacing + Iface.geom.bendradius, ...
                                y - Iface.geom.bendradius - num_offset*waveguide_spacing;
                                width + (num_offset_init - num_offset)*waveguide_spacing + Iface.geom.bendradius, y_end;
                                x_end, y_end;
                                ]);
                            
                            num_offset = num_offset - 1;
                        end
                        
                        ggOutput = [ggOutput ggConnection];
                    end
                    
                    
            end
        end
        
        function [Iface, width] = calc_circuit_width(Iface, ggMoments)
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
        
        function gPositions_sorted = sort_position(Iface, gPositions)
            %SORT_POSITIONS Sort positions descending.
            %   Sort all positions in descending order according to their
            %   y-coordinates.
            
            gPositions_sorted = {};
            
            for k = 1:size(gPositions, 2)
                position = gPositions{k};
                
                if isempty(gPositions_sorted)
                    gPositions_sorted{end + 1} = position;
                else
                    pos = position{2};
                    inserted = false;
                    
                    for l = 1:size(gPositions_sorted, 2)
                        if gPositions_sorted{l}{2} < pos
                            gOld = gPositions_sorted(l:end);
                            gPositions_sorted = gPositions_sorted(1:l-1);
                            gPositions_sorted{end + 1} = position;
                            gPositions_sorted = [gPositions_sorted gOld];
                            
                            inserted = true;
                            break;
                        end
                    end
                    
                    if ~inserted
                        gPositions_sorted{end + 1} = position;
                    end
                end
            end
        end
    end
end

