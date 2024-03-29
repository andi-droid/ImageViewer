% Class works as configuration file. Here we set different camera and atom
% parameters, specifically different camera IDs.

% This is now a untracked file used for configuration
% Lalalalalalalala

classdef Camera_Default < handle
    properties
        
        ID
        species
        
        ISat
        E_Photon
        PixSize
        HotPix
        magnification
        C_F
        TE
        t_Bel
        QE
        CountToInt
        Detuning
        Lambda
        Atomfaktor
        Gamma
        
            roi = [220    100   350   300]
            abscenter = [376,272]
            defringeatoms = [247,68,238,395]
            defringeroi = [181,39,394,462]
        
%         basepath = 'C:\Users\LithiumMicroscope\Desktop\Data\Images\';
%         protocolpath = '\\LASO2013-D3\Data\ExpProtocols\';
%         imageDirectoryNode = 'C:\Users\LithiumMicroscope\Desktop\Data\Images\2017\';
        basepath = 'D:\\Data/absimg/';
        protocolpath = '//192.168.1.6/d/Data/ExpProtocols/';
        % [1] = datestring, [2] = datestringreduced, [3] = id
        protocolfile; % Please update this for your system
        %protocolfile = '//afs/physnet.uni-hamburg.de/project/bfm/ExpProtocols/%s/%s_%s_t_proto.dat';
        %protocolfile = '//192.168.1.6/d/Data/ExpProtocols/%s\\Protocol-%s_%s.xml';
        imageDirectoryNode = 'D:\\Data/absimg/2017/';
        
        defRectsPath
    end
    
    methods
        % super constructor
        function Default(o,ID,species)
            o.ID = ID;
            o.species = species;
            
            hPlanck  = 6.62606896e-34  ; % Plancksches Wirkungsquantum
            hbar     = hPlanck / (2*pi);
            kBoltz   = 1.3806503e-23   ; % Boltzmann Konstante
            cspeed   = 2.99792458e8    ; % Lichtgeschwindigkeit
            AMU      = 1.660538e-27    ; % Atomic Mass Unit kg/u
            mue_Bohr = 9.27400915e-24  ; % J/T
            mue_Kern = 1.410606662e-26 ; % J/T Proton magnetic moment ???
            r_Bohr   = 5.29177e-11     ; % m ; Bohrscher Radius
            eV       = 1.60217653e-19  ; % eV in J
            
            g = 9.813749 ;
            
            MasseRb  = 86.909187           ; % Istopengewicht laut webelements.com
            mRb      = MasseRb * AMU       ; % Masse Rb87 in kg
            MasseK   = 39.9639992          ; % Istopengewicht laut webelements.com
            mK       = MasseK * AMU        ;
            
            GammaRb_D1 = 2.*pi.*5.7500e6   ; % entnommen aus "Steck" (s.u.)
            GammaRb    = 2.*pi.*6.0666e6   ; % Linienbreite des zyklischen Uebergangs aus "Alkali D Line Data", Daniel Steck - August 2009
            GammaK     = 2.*pi.*6.035e6    ; % Linienbreite des zyklischen Uebergangs aus T.G. Tiecke "Properties of Potassium"
            
            LambdaRb_D1 = 794.978851156e-9 ; % Rubidium D1 Wellenlaenge, entnommen aus "Steck"
            LambdaRb    = 780.241209686e-9 ; % Rubidium D2 Detektionswellenlaenge, entnommen aus "Steck"
            LambdaK     = 766.700674872e-9 ; % Kalium D2 Detektionswellenlaenge, T.G. Tiecke "Properties of Potassium"
            LambdaK_D1  = 770.108136507e-9 ; % Kalium D1 Detektionswellenlaenge, T.G. Tiecke "Properties of Potassium"
            
            DetuningRb = 0e6         ; % [Hz] Nicht Kreisfrequenz!
            DetuningK  = 0e6         ; % [Hz] Nicht Kreisfrequenz!
            
            nueRb_D1 = cspeed/LambdaRb_D1  ; % Frequenz der Rb87 D1-Linie
            nueRb    = cspeed/LambdaRb     ; % Frequenz des Detektionslasers Rb
            nueK_D1  = cspeed/LambdaK_D1   ; % Frequenz der K D1 Linie
            nueK     = cspeed/LambdaK      ; % Frequenz des Detektionslasers K
            
            omegaRb_D1  = nueRb_D1*(2*pi)  ; % Kreisfrequenz der D1-Linie Rb
            omegaRb     = nueRb*(2*pi)     ; % Kreisfrequenz des Detektionslasers Rb
            omegaRb_center = (omegaRb_D1+ 2.*omegaRb)./3;
            omegaK      = nueK*(2*pi)      ; % Kreisfrequenz des Detektionslasers K
            omegaK_D1   = nueK_D1*(2*pi)   ; % Kreisfrequenz der K D1 Linie
            omegaK_center = (omegaK_D1+ 2.*omegaK)./3;
            
            MasseLi6 = 6.0151223        ; % Isotopengewicht von Li6 laut webelements.com
            mLi6 = MasseLi6 * AMU       ; % Masse von Li6 in kg
            
            MasseLi7 = 7.0160040        ; % Isotopengewicht von Li7 laut webelements.com
            mLi7 = MasseLi7 * AMU       ; % Masse von Li7 in kg
            
            GammaLi6_D1 = 2.*pi.*5.8724e6    ; % Linienbreite der Li6 D1-Linie aus M. Gehm "Properties of 6Li"
            GammaLi6_D2 = 2.*pi.*5.8724e6    ; % Linienbreite der Li6 D2-Linie aus M. Gehm "Properties of 6Li"
            
            GammaLi7_D1 = 2.*pi.*5.9e6       ; % Linienbreite der Li7 D1-Linie
            GammaLi7_D2 = 2.*pi.*5.9e6       ; % Linienbreite der Li7 D2-Linie
            
            LambdaLi6_D1 = 670.992421e-9    ; % Wellenl�nge der Li6 D1-Linie aus M. Gehm "Properties of 6Li"               ;
            LambdaLi6_D2 = 670.977338e-9    ; % Wellenl�nge der Li6 D2-Linie aus M. Gehm "Properties of 6Li"
            
            LambdaLi7_D1 = 670.9767e-9      ; % Wellenl�nge der Li7 D1-Linie
            LambdaLi7_D2 = 670.9616e-9      ; % Wellenl�nge der Li7 D2-Linie
            
            kLi6_D1 = 2.*pi./LambdaLi6_D1       ; % Wellenzahl der Li6 D1-Linie
            kLi6_D2 = 2.*pi./LambdaLi6_D2       ; % Wellenzahl der Li6 D2-Linie
            
            kLi7_D1 = 2.*pi./LambdaLi7_D1       ; % Wellenzahl der Li7 D1-Linie
            kLi7_D2 = 2.*pi./LambdaLi7_D2       ; % Wellenzahl der Li7 D2-Linie
            
            nueLi6_D1 = cspeed/LambdaLi6_D1     ; % Frequenz der Li6 D1-Linie
            nueLi6_D2 = cspeed/LambdaLi6_D2     ; % Frequenz der Li6 D2-Linie
            
            nueLi7_D1 = cspeed/LambdaLi7_D1     ; % Frequenz der Li7 D1-Linie
            nueLi7_D2 = cspeed/LambdaLi7_D2     ; % Frequenz der Li7 D2-Linie
            
            omegaLi6_D1 = 2.*pi.*nueLi6_D1      ; % Kreisfrequenz der Li6 D1-Linie
            omegaLi6_D2 = 2.*pi.*nueLi6_D2      ; % Kreisfrequenz der Li6 D2-Linie
            
            omegaLi7_D1 = 2.*pi.*nueLi7_D1    ; % Kreisfrequenz der Li7 D1-Linie
            omegaLi7_D2 = 2.*pi.*nueLi7_D2    ; % Kreisfrequenz der Li7 D2-Linie
            
            ISatLi6_D1 = pi.*hPlanck*cspeed*GammaLi6_D1/(3.*(LambdaLi6_D1^3)) ; %Saettigungsintensitaet der Li6 D1-Linie
            ISatLi6_D2 = pi.*hPlanck*cspeed*GammaLi6_D2/(3.*(LambdaLi6_D2^3)) ; %Saettigungsintensitaet der Li6 D2-Linie
            
            ISatLi7_D1 = pi.*hPlanck*cspeed*GammaLi7_D1/(3.*(LambdaLi7_D1^3)) ; %Saettigungsintensitaet der Li7 D1-Linie
            ISatLi7_D2 = pi.*hPlanck*cspeed*GammaLi7_D2/(3.*(LambdaLi7_D2^3)) ; %Saettigungsintensitaet der Li7 D2-Linie
            
            DetuningLi6_D1 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
            DetuningLi6_D2 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
            
            DetuningLi7_D1 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
            DetuningLi7_D2 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
            
            k_Rb = 2.*pi./LambdaRb                ; % Wellenzahl Rubidium D2-Linie
            k_K  = 2.*pi./LambdaK                 ; % Wellenzahl Kalium D2-Linie
            k_Li6  = 2.*pi./LambdaLi6_D2          ; % Wellenzahl Kalium D2-Linie
            k_Li7  = 2.*pi./LambdaLi7_D2          ; % Wellenzahl Kalium D2-Linie
            
            ISatRb   = hPlanck*GammaRb*omegaRb.^3/(2*pi*12*pi*cspeed.^2) ; % Saettigungsintensitaet 16.7 W/m^2 fuer cycling transition (sigma+/sigma-)
            % Saettigungsintensitaet 35.7 W/m^2 fuer isotropic light polarization
            ISatK    = hPlanck*GammaK*omegaK.^3/(2*pi*12*pi*cspeed.^2)   ; % Saettigungsintensitaet 17.6 W/m^2
            
            
            if strcmp(species,'Rb')
                o.Detuning = DetuningRb;
                o.Gamma = GammaRb;
                o.ISat = ISatRb;
                o.Lambda = LambdaRb;              
                o.E_Photon = hbar.*omegaRb;
                
            elseif strcmp(species,'K')
                o.Detuning = DetuningK;
                o.Gamma = GammaK;
                o.ISat = ISatK;
                o.Lambda = LambdaK;              
                o.E_Photon = hbar.*omegaK;
                
            elseif strcmp(species,'Li6')
                o.Detuning = DetuningLi6_D2;
                o.Gamma = GammaLi6_D2;
                o.ISat = ISatLi6_D2;
                o.Lambda = LambdaLi6_D2;
                o.E_Photon = hbar.*omegaLi6_D2;
                
            elseif strcmp(species,'Li7')
                o.Detuning = DetuningLi7_D2;
                o.Gamma = GammaLi7_D2;
                o.ISat = ISatLi7_D2;
                o.Lambda = LambdaLi7_D2;
                o.E_Photon = hbar.*omegaLi7_D2;
                
            else
                disp('Wrong species')
            end
            
        end
        
    end
    
end

