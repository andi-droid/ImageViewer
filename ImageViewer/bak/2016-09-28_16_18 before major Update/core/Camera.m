classdef Camera < handle
    properties
        
        ISat
        E_Photon
        PixSize
        magnification
        C_F
        TE
        t_Bel
        QE
        CountToInt
    end
    
    methods
        % constructor
        function o = Camera(ID,species)
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
            
            k_Rb = 2.*pi./LambdaRb         ; % Wellenzahl Rubidium D2-Linie
            k_K  = 2.*pi./LambdaK          ; % Wellenzahl Kalium D2-Linie
            
            ISatRb   = hPlanck*GammaRb*omegaRb.^3/(2*pi*12*pi*cspeed.^2) ; % Saettigungsintensitaet 16.7 W/m^2 für cycling transition (sigma+/sigma-)
                                                                   % Saettigungsintensitaet 35.7 W/m^2 für isotropic light polarization
            ISatK    = hPlanck*GammaK*omegaK.^3/(2*pi*12*pi*cspeed.^2)   ; % Saettigungsintensitaet 17.6 W/m^2
            
            if (species=='Rb')
                Detuning = DetuningRb;
                Gamma = GammaRb;
                ISat = ISatRb;
                Lambda = LambdaRb;
                E_Photon = hbar.*omegaRb;
            elseif (species=='K')
                Detuning = DetuningK;
                Gamma = GammaK;
                ISat = ISatK;
                Lambda = LambdaK;
                E_Photon = hbar.*omegaK;
            end
                
                
                if strcmp(ID,'0') %PCO HD
                    o.ISat = ISat;
                    o.E_Photon = E_Photon;
                    o.PixSize = 6.45E-6;
                    o.magnification   = 1.1;
                    o.C_F = 3.8;
                    o.TE = 0.9;
                    o.t_Bel = 50e-6;
                    if species == 'K'
                        o.QE = 0.155;
                    elseif species == 'Rb'
                       o.QE = 0.1275;
                    end
                    o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                    
                elseif strcmp(ID,'1') %PCO LA
                    o.ISat = ISat;
                    o.E_Photon = E_Photon;
                    o.PixSize = 6.45E-6;
                    o.magnification   = 1.1;
                    o.C_F = 3.8;
                    o.TE = 0.9;
                    o.t_Bel = 50e-6;
                    if (species == 'K')
                        o.QE = 0.155;
                    elseif (species == 'Rb')
                       o.QE = 0.1275;
                    end
                    o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                    
                elseif strcmp(ID,'2') %Andor HD
                    o.ISat = ISat;
                    o.E_Photon = E_Photon;
                    o.PixSize = 13E-6;
                    o.magnification   = 2.15;
                    o.C_F = 0.76;
                    o.TE = 0.9;
                    o.t_Bel = 50e-6;
                    if (species == 'K')
                        o.QE = 0.93;
                    elseif (species == 'Rb')
                       o.QE = 0.94;
                    end
                    o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                    
                elseif strcmp(ID,'3') %Andor LA
                    o.ISat = ISat;
                    o.E_Photon = E_Photon;
                    o.PixSize = 13E-6;
                    o.magnification   = 2.15;
                    o.C_F = 4*2800/2200*0.76;
                    o.TE = 0.9;
                    o.t_Bel = 50e-6;
                    if (species == 'K')
                        o.QE = 0.93;
                    elseif (species == 'Rb')
                       o.QE = 0.94;
                    end
                    o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
                else
                    disp('Wrong camera ID')
                end
            end
            
        end
        
    end
    
