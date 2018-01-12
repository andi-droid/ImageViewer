% Class works as configuration file. Here we set different camera and atom
% parameters, specifically different camera IDs.

% This is now a untracked file used for configuration
% Lalalalalalalala

classdef Camera < Camera_Default
    properties
        roi = [220    100   350   300]
        abscenter = [376,272]
        defringeatoms = [247,68,238,395]
        defringeroi = [181,39,394,462]
        
    end
    
    methods
        % constructor
        function o = Camera(ID,species)
            o.Default(ID,species)
            
            o.basepath = '//afs/physnet.uni-hamburg.de/project/bfm/Daten/';
            o.protocolpath = '//afs/physnet.uni-hamburg.de/project/bfm/ExpProtocols/';
            o.protocolfile = '//afs/physnet.uni-hamburg.de/project/bfm/ExpProtocols/%s/%s_%s_t_proto.dat';
            o.imageDirectoryNode = '//afs/physnet.uni-hamburg.de/project/bfm/Daten/2017/';
            
            
            %% BFM Camera parameters
           if strcmp(ID,'0') %PCO HD

                o.PixSize = 6.45E-6;
                o.magnification   = 1.1;
                o.C_F = 3.8;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li7')
                    o.QE = 0.1275;
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
            elseif strcmp(ID,'1') %PCO LA

                o.PixSize = 6.45E-6;
                o.magnification   = 1.1;
                o.C_F = 3.8;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                if strcmp(species,'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li7')
                    o.QE = 0.1275;
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'2') %Andor HD

                o.PixSize = 13E-6;
                o.magnification   = 2.15;
                o.C_F = 0.76;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                if strcmp(species,'K')
                    o.QE = 0.93;
                elseif strcmp(species,'Rb')
                    o.QE = 0.94;
                elseif strcmp(species,'Li6')
                    o.QE = 1;
                elseif strcmp(species,'Li7')
                    o.QE = 1;
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
            elseif strcmp(ID,'3') %Andor LA

                o.PixSize = 13E-6;
                o.magnification   = 2.15;
                o.C_F = 4*2800/2200*0.76;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                if strcmp(species,'K')
                    o.QE = 0.93;
                elseif strcmp(species,'Rb')
                    o.QE = 0.94;
                elseif strcmp(species,'Li6')
                    o.QE = 1;
                elseif strcmp(species,'Li7')
                    o.QE = 1;
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
            else
                disp('Wrong camera ID')
            end
        end
        
    end
    
end

