%classdef OD_ImageSet < ImageSetInterface & handle
%classdef OD_ImageSet < MaskedImageSet & handle
classdef OD_ImageSet < ImageSet & handle
    %OD_IMAGESET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        references
        atoms
        weights
    end
    
    methods
        function obj = OD_ImageSet(references, atoms, varargin)
            obj.references = references;
            obj.atoms = atoms;
            if nargin ==3
                obj.weights = varargin{1};
            else
                obj.weights = ones(obj.atoms.getNImages(),1);
            end
        end
        
        
        
        % access
        function setImage(obj, n, img)
            obj.images(n,:) = img.vector();
        end
        function img = getImage(obj, n)
            img = Image(obj.images(n,:), obj.dimx, obj.dimy);
        end
        function d = getRawData(obj)
            d = obj.images;
        end
        function setRawData(obj, d)
            obj.images = d;
        end
        % function img = getImage(obj, n)
        %     img =Image(AnalysisFramework.OD(obj.weights(n)* obj.references.getImage(n).matrix, obj.atoms.getImage(n).matrix));
        % end
        
        
        % construct OD images
        function populate(o)
            assert(o.atoms.nImages == o.references.nImages, 'Atom ImageSet and reference ImageSet need to have the same number of Images')
            o.nImages = o.atoms.nImages;
            o.dimx = o.atoms.dimx;
            o.dimy = o.atoms.dimy;
            o.dimxy = o.atoms.dimxy;
            for iIm = 1:o.nImages
                img = o.constructImage(iIm);
                o.images(iIm,:) = img.vector();
            end
        end
        function img = constructImage(obj, n)
            img = Image(AnalysisFramework.OD(obj.weights(n)* obj.references.getImage(n).matrix...
                                     , obj.atoms.getImage(n).matrix));
        end
        
        
        % function setImage(obj, n, A)
        %     error('Images cant be set OD_ImageSet is readonly');
        % end

        function dimx = getDimX(obj)
            % dimx = obj.atoms.getDimX();
            dimx = obj.dimx;
        end
        function dimy = getDimY(obj)
            % dimy = obj.atoms.getDimY();
            dimy = obj.dimy;
        end
        function dimxy = getDimXY(obj) 
            % dimxy = obj.atoms.getDimXY();
            dimxy = obj.dimxy;
        end
        function nImages = getNImages(obj)
            % nImages = obj.atoms.getNImages();
            nImages = obj.nImages;
        end
        
        % Functions that operate on all images
        
        function croppedIS = crop(o, rect)
            % Crop the atoms and references ImageSets
            if ~isempty(o.atoms), o.atoms = o.atoms.crop(rect, false);end
            if ~isempty(o.atoms), o.references = o.references.crop(rect, false);end
            % Crop the ODs
            croppedIS = crop@ImageSetInterface(o, rect, true);
            o.images = croppedIS;
        end
        
        
%         function  d = getRawData(obj)
%              error('Not yet implemented');
%         end
        
        % function setRawData(obj,d)
        %      error('Images cant be set OD_ImageSet is readonly');
        % end
        
        function d = getRaw3DData(obj)
            error('Not yet implemented');
        end
        
        
    end
    
    methods(Static)
        
    end
    
end

