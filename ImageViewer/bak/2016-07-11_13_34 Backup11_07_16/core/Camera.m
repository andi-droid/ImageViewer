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
        function o = Camera(model)
            if strcmp(model,'Andor')
                o.ISat = 17.5019;
                o.E_Photon = 2.5909e-019;
                o.PixSize = 13E-6;
                o.magnification   = 2.15;
                o.C_F = 4*2800/2200*0.76;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                o.QE = 0.93;
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
            else
                o.ISat = 17.5019;
                o.E_Photon = 2.5909e-019;
                o.PixSize = 6.45E-6;
                o.magnification   = 1.1;
                o.C_F = 3.8;
                o.TE = 0.9;
                o.t_Bel = 50e-6;
                o.QE = 0.155;
                o.CountToInt = (o.magnification./o.PixSize).^2 * o.C_F * o.E_Photon / (o.QE * o.TE * o.t_Bel); % [W/(count*m�)]
            end
        end
        
    end
    
end

