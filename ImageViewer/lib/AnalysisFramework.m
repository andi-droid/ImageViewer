classdef AnalysisFramework
   
    properties
        % Cameras
    end
    
    
    methods(Static)
        function c = defringe(references, atoms)
            %tic;
            assert(isa(references, 'MaskedImageSet') && isa(atoms,'MaskedImageSet'));
            assert(all(references.getDim() == atoms.getDim()));
            assert(all(references.mask(:) == atoms.mask(:)), ...
                'Error masks of reference images and atom images must be identically');
            lsqProjector = LeastSquareProjector();
            lsqProjector.prepare(references.getMaskedRawData());
            c = lsqProjector.computeCoefficients(atoms.getMaskedRawData());
            references.setRawData(...
                LeastSquareProjector.vectorFromCoefficients(c, references.getRawData()));
            %toc
        end

        % MAYBE ADD FLUORESCENCE IMAGING ONE DAY?
%         function res = Fluorescence(reference, atoms)
%             res = atoms-reference;
%         end
        
        function res = OD(references, atoms)            
                function res = od(r,a)
                ISat = 17.5019;
                E_Photon = 2.5909e-019;

                PixSize = 13E-6;
                %Vergr   = 4.8449;  
                Vergr   = 2.02;
                C_F = 4*2800/2200*0.76; 
                TE = 0.9;
                t_Bel = 10e-6;
                QE = 0.93;
                CountToInt = (Vergr./PixSize).^2 * C_F * E_Photon / (QE * TE * t_Bel); % [W/(count*m�)]
           
                res  = reallog(max(0.001,r./max(0.001,a))) + (r-a).*CountToInt/ISat;
            end
            
            if isa(references, 'ImageSetInterface') && isa(atoms,'ImageSetInterface')
                assert(all(references.getDim() == atoms.getDim()));
                res = copy(atoms);
                res.setRawData(od( references.getRawData(), atoms.getRawData()));
            elseif isa(references, 'Image') && isa(atoms,'Image')
                res = Image(od(references.matrix(), atoms.matrix()));
            elseif isa(references, 'numeric') && isa(atoms, 'numeric')
                res = od(references, atoms);
            end
        end
        
        function res = OD_IS(references, atoms, varargin)            
            res = copy(atoms);
            if nargin == 4
                roiRect = varargin{1};
                atomsRect = varargin{2};
                mask = atoms.maskFromRect(roiRect) &...
                    ~atoms.maskFromRect(atomsRect);
                nImages = atoms.getNImages();
                correction = NaN(nImages,1);
                for iImage=1:nImages
                    countAtoms = sum(sum(atoms.getImage(iImage).matrix().*mask));
                    countReferences = sum(sum(references.getImage(iImage).matrix().*mask));
                    correction(iImage) = countAtoms/countReferences;
                end
                correction = repmat(correction, [1 atoms.getDimXY]);
                
                res.setRawData(od( references.getRawData().*correction, atoms.getRawData()));
            else
                res.setRawData(od( references.getRawData(), atoms.getRawData()));
            end
            
            function res = od(r,a)
                ISat = 17.5019;
                E_Photon = 2.5909e-019;

                PixSize = 13E-6;
                %Vergr   = 4.8449;
                Vergr   = 2.02;
                C_F = 4*2800/2200*0.76; 
                TE = 0.9;
                t_Bel = 50e-6;
                QE = 0.93;
                CountToInt = (Vergr./PixSize).^2 * C_F * E_Photon / (QE * TE * t_Bel); % [W/(count*m�)]
           
                res  = reallog(max(0.001,r./max(0.001,a))) + (r-a).*CountToInt/ISat;
            end
        end
        
        % timing
        function tic()
           tic; 
           [ST,I] = dbstack;
        end
        function toc()
            toc
        end
    end
    
end

