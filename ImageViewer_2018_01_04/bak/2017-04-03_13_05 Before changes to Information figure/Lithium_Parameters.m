clear all;
close all;

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
            

MasseLi6 = 6.0151223        ; % Isotopengewicht von Li6 laut webelements.com
mLi6 = MasseLi6 * AMU       ; % Masse von Li6 in kg

MasseLi7 = 7.0160040        ; % Isotopengewicht von Li7 laut webelements.com
mLi7 = MasseLi7 * AMU       ; % Masse von Li7 in kg

GammaLi6_D1 = 2.*pi.*5.8724e6    ; % Linienbreite der Li6 D1-Linie aus M. Gehm "Properties of 6Li" 
GammaLi6_D2 = 2.*pi.*5.8724e6    ; % Linienbreite der Li6 D2-Linie aus M. Gehm "Properties of 6Li"
 
GammaLi7_D1 = 2.*pi.*5.9e6       ; % Linienbreite der Li7 D1-Linie
GammaLi7_D2 = 2.*pi.*5.9e6       ; % Linienbreite der Li7 D2-Linie
 
LambdaLi6_D1 = 670.992421e-9    ; % Wellenlänge der Li6 D1-Linie aus M. Gehm "Properties of 6Li"               ;
LambdaLi6_D2 = 670.977338e-9    ; % Wellenlänge der Li6 D2-Linie aus M. Gehm "Properties of 6Li"

LambdaLi7_D1 = 670.9767e-9      ; % Wellenlänge der Li7 D1-Linie
LambdaLi7_D2 = 670.9616e-9      ; % Wellenlänge der Li7 D2-Linie

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

ISatLi6_D1 = pi.*hPlanck*cspeed*GammaLi6_D1/(3.*(LambdaLi6_D1^3)) ; %Sättigungsintensität der Li6 D1-Linie
ISatLi6_D2 = pi.*hPlanck*cspeed*GammaLi6_D2/(3.*(LambdaLi6_D2^3)) ; %Sättigungsintensität der Li6 D2-Linie

ISatLi7_D1 = pi.*hPlanck*cspeed*GammaLi7_D1/(3.*(LambdaLi7_D1^3)) ; %Sättigungsintensität der Li7 D1-Linie
ISatLi7_D2 = pi.*hPlanck*cspeed*GammaLi7_D2/(3.*(LambdaLi7_D2^3)) ; %Sättigungsintensität der Li7 D2-Linie

DetuningLi6_D1 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
DetuningLi6_D2 = 0e6     ; % [Hz] Nicht Kreisfrequenz!

DetuningLi7_D1 = 0e6     ; % [Hz] Nicht Kreisfrequenz!
DetuningLi7_D2 = 0e6     ; % [Hz] Nicht Kreisfrequenz!


elseif (species=='6Li')
                Detuning = DetuningLi6_D2;
                Gamma = GammaLi6_D2;
                ISat = ISatLi6_D2;
                Lambda = LambdaLi6_D2;
                E_Photon = hbar.*omegaLi6_D2;
                                   
elseif (species=='7Li')
                Detuning = DetuningLi7_D2;
                Gamma = GammaLi7_D2;
                ISat = ISatLi7_D2;
                Lambda = LambdaLi7_D2;
                E_Photon = hbar.*omegaLi7_D2;
                
                
 elseif o.compositor.species == '6Li'
                DetuningLi6_D2 = 0e6;
                GammaLi6_D2 = 2.*pi.*5.8724e6   ; % Linienbreite der Li6 D2-Linie aus M. Gehm "Properties of 6Li"
                LambdaLi6_D2 = 670.977338e-9    ; % Wellenlänge der Li6 D2-Linie aus M. Gehm "Properties of 6Li"
                o.AtomfaktorLi6_D2 = (o.compositor.camera.PixSize.^2/o.compositor.camera.magnification.^2) .* 2 .* pi .* (1+ 4.*(DetuningLi6_D2.^2/GammaLi6_D2.^2)) ./ (3.*LambdaLi6_D2.^2);
                atomnumber = atomcount.*o.AtomfaktorLi6_D2;
                if ~isempty(o.compositor.fitdatax)
                    atomnumberfit(1) = o.compositor.fitdatax(2).*o.compositor.fitdatax(4)*sqrt(2*pi).*o.AtomfaktorLi6_D2;
                    atomnumberfit(2) = o.compositor.fitdatay(2).*o.compositor.fitdatay(4)*sqrt(2*pi).*o.AtomfaktorLi6_D2;
                    sigmax = o.compositor.fitdatax(4);
                    sigmay = o.compositor.fitdatay(4);
                else
                    atomnumberfit = [];
                    sigmax = [];
                    sigmay = [];
                end
                
                
elseif o.compositor.species == '7Li'
                DetuningLi7_D2 = 0e6;
                GammaLi7_D2 = 2.*pi.*5.9e6       ; % Linienbreite der Li7 D2-Linie
                LambdaLi7_D2 = 670.9616e-9       ; % Wellenlänge der Li7 D2-Linie
                o.AtomfaktorLi7_D2 = (o.compositor.camera.PixSize.^2/o.compositor.camera.magnification.^2) .* 2 .* pi .* (1+ 4.*(DetuningLi7_D2.^2/GammaLi7_D2.^2)) ./ (3.*LambdaLi7_D2.^2);
                atomnumber = atomcount.*o.AtomfaktorLi7_D2;
                if ~isempty(o.compositor.fitdatax)
                    atomnumberfit(1) = o.compositor.fitdatax(2).*o.compositor.fitdatax(4)*sqrt(2*pi).*o.AtomfaktorLi7_D2;
                    atomnumberfit(2) = o.compositor.fitdatay(2).*o.compositor.fitdatay(4)*sqrt(2*pi).*o.AtomfaktorLi7_D2;
                    sigmax = o.compositor.fitdatax(4);
                    sigmay = o.compositor.fitdatay(4);
                else
                    atomnumberfit = [];
                    sigmax = [];
                    sigmay = [];
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
                    o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*mï¿½)]
                    