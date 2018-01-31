% Class works as configuration file. Here we set different camera and atom
% parameters, specifically different camera IDs.

% This is now a untracked file used for configuration
% Lalalalalalalala

classdef Camera < Camera_Default
    properties

    end
    
    methods
        % constructor
        function o = Camera(ID,species)
            o.Default(ID,species)
            
            o.basepath = 'D:\\Data/absimg/';
            o.protocolpath = '//192.168.1.6/d/Data/ExpProtocols/';
            o.protocolfile = '//192.168.1.6/d/Data/ExpProtocols/%s\\Protocol-%s_%s.xml';
            o.imageDirectoryNode = 'D:\\Data/absimg/2018/';
            o.defRectsPath = './roi_defringe.mat';
            
            % Lithium camera properties
            if strcmp(ID,'0') % Pixelfly QE / Parameter anpassen!
                
                o.roi = [270    314   323   305]; % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [151 186 597 528];     %defringe atoms only, needed for background zero
                o.defringeroi = [97 141 788 747];        %defringe roi larger than atoms, needed for background zero
       
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.magnification   = 100/250; % 4f image: f1 = 250 mm, f2 = 100 mm
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.9; % ??? Transmission Efficiency
                o.t_Bel = 50e-6; % !
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
            
            elseif strcmp(ID,'1') % Pixelfly QE /Parameter anpassen!
                
                o.roi = [270    314   323   305]; % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [151 186 597 528];     %defringe atoms only, needed for background zero
                o.defringeroi = [97 141 788 747];        %defringe roi larger than atoms, needed for background zero
       
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.magnification   = 100/250; % 4f image: f1 = 250 mm, f2 = 100 mm
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.9; % ??? Transmission Efficiency
                o.t_Bel = 50e-6; % !
                if strcmp(species,'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'2') % Pixelfly QE / Parameter anpassen!
                
                o.roi = [270    314   323   305]; % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [151 186 597 528];     %defringe atoms only, needed for background zero
                o.defringeroi = [97 141 788 747];        %defringe roi larger than atoms, needed for background zero
                     
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.magnification   = 300/150; %; % 4f image: f1 = 150 mm, f2 = 300 mm
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.9; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % !
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);

            elseif strcmp(ID,'3') %Andor LA / Paramter anpassen
       
            
                o.roi = [270    314   323   305]; % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [151 186 597 528];     %defringe atoms only, needed for background zero
                o.defringeroi = [97 141 788 747];        %defringe roi larger than atoms, needed for background zero
                                      
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
                    o.QE = 1; % Have to be looked up
                elseif strcmp(species,'Li7')
                    o.QE = 1; % Have to be looked up
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
           
            else
                disp('Wrong camera ID')
            end
        end
        
    end
    
end