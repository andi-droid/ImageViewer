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
            
            o.basepath = 'C:\\Data/absimg/'; %%old version
            %to look on PC changed: 2018-03-26
            %o.basepath = '//afs/physnet.uni-hamburg.de/project/las_o/Lithium_microscope/Data/absimg/';
            o.protocolpath = '//afs/physnet.uni-hamburg.de/project/las_o/Lithium_microscope/Data/ExpProtocols/';
            o.protocolfile = '//afs/physnet.uni-hamburg.de/project/las_o/Lithium_microscope/Data/ExpProtocols/%s/Protocol-%s_%s.xml';
            o.imageDirectoryNode = 'C:\\Data/absimg/'; %%old version
            %to look on PC changed: 2018-03-26
            %o.imageDirectoryNode = '//afs/physnet.uni-hamburg.de/project/las_o/Lithium_microscope/Data/absimg/2018/';
            
            o.defRectsPath = './roi_defringe.mat';
            
            % Lithium camera properties
            if strcmp(ID,'0') % Pixelfly QE / Parameter anpassen! MOTY
                
                
                o.roi = [200   222   448   466];                % begin roi
                o.abscenter = [368,408];
                o.defringeatoms = [200   222   448   466];             %defringe atoms only, needed for background zero
                o.defringeroi = [96   237   617   662];        %defringe roi larger than atoms, needed for background zero
                
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.HotPix = [];
                o.magnification   = .3991; %measured by glass cell wall distances %100/250; % 4f image: f1 = 250 mm, f2 = 100 mm
                o.C_F = 3.8; % A/D conversion factor electrons/count
                o.TE = 0.99; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % 10µs!
                %Quantum efficiency in electrons/photon
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'1') % Pixelfly QE /Parameter anpassen! MOTX
                
                
                o.roi = [634   430   137    47];                % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [503   189   411   431];             %defringe atoms only, needed for background zero
                o.defringeroi = [303    99   854   596];        %defringe roi larger than atoms, needed for background zero
                
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.HotPix = [];
                o.magnification   = 100/250; % 4f image: f1 = 250 mm, f2 = 100 mm
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.9; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % !
                if strcmp(species,'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'2') % Pixelfly QE / Parameter anpassen! MOT Z
                
                
                o.roi = [627   565   321   156];                % begin roi
                o.abscenter = [136,155];
                o.defringeatoms = [692   383   133   201];             %defringe atoms only, needed for background zero
                o.defringeroi = [472   379   576   398];        %defringe roi larger than atoms, needed for background zero
                
                
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.HotPix = [932 730;...
                    1116 231];
                %o.magnification = 250/25; %; % 4f image: f1 = 25 mm(high NA objective), f2 = 250 mm
                o.magnification = 8.7; % Calibrated with Kapitza-Dirac Peaks
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.9; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % !
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.458; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                %CountToInt is important for Intensity
                %Correction&AtomNumber definition
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m^2)]
                %Atomfaktor is always important for AtomNumber defintion!
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'3') % Pixelfly QE / Parameter anpassen! Push
                
                o.roi = [560   310    81   335];                % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [665   371    63   181];             %defringe atoms only, needed for background zero
                o.defringeroi = [573   487   109   113];        %defringe roi larger than atoms, needed for background zero
                
                
                
                o.PixSize = 6.45E-6; % Pixel Size in m
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.HotPix = [];
                o.magnification   = 500/150; %; % 4f image: f1 = 150 mm, f2 = 500 mm %30-04-2018 checked the push beam lenses.
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.7; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % !
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.458; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'4') %zLatt
                
                o.roi = [560   310    81   335];                % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [615   603    58    32];             %defringe atoms only, needed for background zero
                o.defringeroi = [571   569   150    94];        %defringe roi larger than atoms, needed for background zero
                
                
                o.PixSize = 6.45E-6;
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.magnification   = 400/85;
                o.C_F = 1;
                o.TE = 0.9;
                o.t_Bel = 10e-6;
                if strcmp(species,'K')
                    o.QE = 0.93;
                elseif strcmp(species,'Rb')
                    o.QE = 0.94;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 1; % Have to be looked up
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
                
            elseif strcmp(ID,'4') %zLatt
                
                o.roi = [560   310    81   335];                % begin roi
                o.abscenter = [165,147];
                o.defringeatoms = [615   603    58    32];             %defringe atoms only, needed for background zero
                o.defringeroi = [571   569   150    94];        %defringe roi larger than atoms, needed for background zero
                
                
                o.PixSize = 6.45E-6;
                o.PixDepth = 2^12; % Maximum Pixel counts
                o.ColorScaling = .1; %scaling for colorbar
                o.magnification   = 400/85;
                o.C_F = 1;
                o.TE = 0.9;
                o.t_Bel = 10e-6;
                if strcmp(species,'K')
                    o.QE = 0.93;
                elseif strcmp(species,'Rb')
                    o.QE = 0.94;
                elseif strcmp(species,'Li6')
                    o.QE = 0.3; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 1; % Have to be looked up
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
            elseif strcmp(ID,'5') % Andor iXon Ultra / Parameter anpassen! Push
                
                o.roi = [17    25    99    76];                % begin roi
                o.abscenter = [64,64];
                o.defringeatoms = [42    53    42    24];             %defringe atoms only, needed for background zero
                o.defringeroi = [18    19    97    86];        %defringe roi larger than atoms, needed for background zero
                
                
                
                o.PixSize = 16E-6; % Pixel Size in m
                o.PixDepth = 2^16; % Maximum Pixel counts
                o.ColorScaling = 1; %scaling for colorbar
                o.HotPix = [];
                o.magnification   = 500/150; %; % 4f image: f1 = 150 mm, f2 = 500 mm %30-04-2018 checked the push beam lenses.
                o.C_F = 3.8; % A/D conversion factor
                o.TE = 0.7; % ??? Transmission Efficiency
                o.t_Bel = 10e-6; % !
                if strcmp(species, 'K')
                    o.QE = 0.155;
                elseif strcmp(species,'Rb')
                    o.QE = 0.1275;
                elseif strcmp(species,'Li6')
                    o.QE = 0.458; % First estimation from the data sheet
                elseif strcmp(species,'Li7')
                    o.QE = 0.3; % First estimation from the data sheet
                end
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                o.Atomfaktor = (o.PixSize.^2/o.magnification.^2) .* 2 .* pi .* (1+ 4.*(o.Detuning.^2/o.Gamma.^2)) ./ (3.*o.Lambda.^2);
                
                
            else
                disp('Wrong camera ID')
            end
        end
        
    end
    
end