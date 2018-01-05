classdef MaskedImageSet < ImageSet
    % @todo at some point need to somehow implement cropping on a MaskedImageSet...
    properties
        mask
        maskvalue = 0;
        domask = false;
    end
    
    methods
        function o = MaskedImageSet(varargin)
            switch nargin
                case 0,
                case 1
                    img = varargin{1};
                    if isa(img, 'MaskedImageSet')
                        o.nImages = img.nImages;
                        o.dimx = img.dimx;
                        o.dimy = img.dimy;
                        o.dimxy = img.dimxy;
                        o.mask = img.mask;
                        o.images = img.images;
                    elseif isa(img, 'ImageSet')
                        o.nImages = img.nImages;
                        o.dimx = img.dimx;
                        o.dimy = img.dimy;
                        o.dimxy = o.dimy*o.dimx;
                        o.mask = true(o.dimy, o.dimx);
                        o.images = img.images;
                    elseif isa(img, 'Image')
                        o = MaskedImageSet(ImageSet(img));                       
                    else
                        error('Could not initialize ImageSet, with one parameter');
                    end
                case 3,     [o.nImages, o.dimx, o.dimy]  = varargin{:};
                            o.images = zeros([o.nImages, o.dimx*o.dimy],'single');
                            o.dimxy = o.dimy*o.dimx;
                            o.mask = true(o.dimy, o.dimx);
                case 4,     [o.nImages, o.dimx, o.dimy, o.images]  = varargin{:};
                            o.dimxy = o.dimy*o.dimx;
                            o.mask = true(o.dimy, o.dimx);
                otherwise,  error('Error initializing MaskedImageSet');
            end
        end
        
        function applyMask(obj, mask)
            if all(size(mask) == [1 4])
                mask = obj.maskFromRect(mask);
            end
            obj.unMask();
            obj.mask = logical(mask);
            obj.dimxy = sum(mask(:));
            obj.images(:,:) = [obj.images(:, mask(:))  obj.images(:,not(mask(:)))];
        end
        
        function unMask(obj)
            tmp = obj.images; %could not find any solution without copying the whole datastructure....
            obj.images(:,obj.mask(:)) = tmp(:,1:obj.dimxy);
            obj.images(:,~obj.mask(:)) = tmp(:,obj.dimxy+1:end);
            obj.dimxy = obj.dimx*obj.dimy;
        end
        
        function img = getImage(obj, n)
            m = obj.maskvalue*ones(obj.dimy, obj.dimx, 'single');
            if obj.domask
                m(obj.mask) = obj.images(n,1:obj.dimxy);
            else
                m(obj.mask) = obj.images(n,1:obj.dimxy);
                m(~obj.mask) = obj.images(n,(obj.dimxy+1):end);
            end
            img = Image(m);
        end
              
        function d = getRawData(obj)
            d  = obj.images;
        end
        
        function setRawData(obj, d)
            obj.images = d;
        end
        
        function d = getMaskedRawData(obj)
            d  = obj.images(:,1:obj.getDimXY());
        end
        
        function setMaskedRawData(obj, d)
            obj.images(:,1:obj.getDimXY()) = d;
        end
        
        function dimxy = getDimXY(obj)
           dimxy = obj.dimxy;
        end
        
        
        % Get the sum of all pixels for each image
        % @input void
        % @output vector of length nImages with the summed pixel values,
        % but only for the part that is not masked
        function res = getIntegrals(o)
            % @todo implement emptiness
            res = sum(o.getMaskedRawData(),2);
        end
        
        function mask = maskFromRect(obj, rect)
            mask = false(obj.getDim());
            mask(rect(2):(rect(2)+rect(4)-1),rect(1):(rect(1)+rect(3)-1)) = true;
        end
        
    end
    methods(Static)
        function IS = load(filenames)
            IS = MaskedImageSet(load@ImageSetInterface(filenames));
        end
    end
    
end

