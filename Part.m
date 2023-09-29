classdef Part
    %PART Representation of all available parts.
    %   This part class allows for easier instantiation and configuration of 
    %   parts. 
    
    enumeration
        directional_standard;
        directional_heated;
        waveguide_double;
        hresonator;
        hdirectional;
        waveguide_sspd;
        waveguide_crossing;
        ring;
    end
    
    methods(Access = public)
        function part = Part(part)
        end
        
        function [pPart, ggPart] = build(part, geom, properties)
            %BUILD Generate the geomtery of the selected part.
            
            ggPart = {};
            pPart = [];
            
            switch(part)
                case Part.directional_standard
                    [pPart, ggPart] = part.build_directional_standard(geom, properties);
                case Part.waveguide_double
                    [pPart, ggPart] = part.build_waveguide_double(geom, properties);
                case Part.directional_heated
                    [pPart, ggPart] = part.build_directional_heated(geom, properties);
                case Part.hresonator
                    [pPart, ggPart] = part.build_hresonator(geom, properties);
                case Part.hdirectional
                    [pPart, ggPart] = part.build_hdirectional(geom, properties);
                case Part.waveguide_sspd
                    [pPart, ggPart] = part.build_waveguide_sspd(geom, properties);
                case Part.ring
                    [pPart, ggPart] = part.build_ring(geom, properties);
                case Part.waveguide_crossing
                    [pPart, ggPart] = part.build_waveguide_crossing(geom, properties);
                otherwise
                    warning('Part not supported!');
            end
        end
    end
    
    methods(Access = private)
        function [obj, ggPart] = build_directional_standard(~, geom, properties)
            %BUILD_DIRECTIONAL_STANDARD Generate the standard DC
            
            obj = directional_standard('splitter_separation', geom.splitter_separation, ...
                'splitter_length', geom.splitter_length, 'interaction_length', geom.interaction_length, ...
                'interaction_separation', geom.interaction_separation, 'layers', geom.layers, ...
                'orientation', 0, 'wwg', geom.wwg);
            
            [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_directional_heated(~, geom, properties)
            %BUILD_DIRECTIONAL_HEATED Generate the heated DC
            
            obj = directional_heated(geom);
            obj.interaction_length = [obj.interaction_length, obj.interaction_length];
            obj.heater_length = 10;
            obj.interaction_length = 5;
            obj.splitter_length = 10;
            obj.heater_width = 1;
            obj.simplified = true;
            obj.heater_bottom = false;

            [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_waveguide_double(~, geom, properties)
           %BUILD_WAVEGUIDE_DOUBLE Generate waveguide double 
           
           obj = waveguide_double(geom);
           obj.phase = 0;%pi/2;
           
           [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_hresonator(~, geom, properties)
            %BUILD_HRESONATOR Generate the Hresonator
            
            obj = Hresonator(geom);
            obj.electrode_position = 'in';
            obj.mech_length = 50;
            obj.support_type = false;
            obj.armwidth = geom.wwg;
            
            [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_hdirectional(~, geom, properties)
            %BUILD_HDIRECTIONAL Generate the Hdirectional
            
            obj = Hdirectional(geom, 'interaction_separation', 1);
            obj = obj.set('interaction_length',200);
            obj.interaction_separation = 1;
            
            [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_waveguide_sspd(~, geom, properties)
            %BUILD_WAVGEUIDE_SSPD Generate the SSPD on a waveguide
            
            obj = waveguide_SSPD(geom);
            obj.xstart = 0;
            obj.ystart = 0;
            obj.xend = 30;
            obj.yend = 0;
            obj.sspd_width = 0.1;
            obj.sspd_gap = 0.12;
            obj.sspd_type = 0;
            obj.sspd_con_finalwidth = 1;
            obj.sspd_con_length = 3;
            obj.sspd_finalwidth = 20;
            obj.cut = geom.cut/2;
            
            [obj, ggPart] = obj.generate_geometry();
        end
        
        function [obj, ggPart] = build_ring(~, geom, properties)
            %BUILD_Ring Generate the racetrack part
            
            obj = racetrack_part(geom);
            obj.ringradius = 40;
            obj.length_flat = 30;
            obj.theta = pi/12;
            obj.window_num = 1;

            [obj, ggPart] = generate_geometry(obj);
        end
        
        function [obj, ggPart] = build_waveguide_crossing(~, geom, properties)
            %BUILD_WAVEGUIDE_CROSSING Build the waveguide crossing part
            
            obj = waveguide_crossing(geom);
            obj.wwg_taper_LL = 2*geom.wwg;
            obj.wwg_taper_UL = 0.3*geom.wwg;
%             obj.interaction_separation = 2;
%             obj.splitter_separation = 3*obj.splitter_separation;
            
            [obj, ggPart] = obj.generate_geometry();
        end
        
    end
end

