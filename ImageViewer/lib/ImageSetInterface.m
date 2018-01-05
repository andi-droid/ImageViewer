classdef  ImageSetInterface < handle & matlab.mixin.Copyable
    properties
        dimx
        dimy
        dimxy
        nImages
        images
        
        % property that indicates which image exists and which image is just a placeholder
        empty
    end
    
    methods(Abstract)
        img = getImage(obj, n)
        setImage(obj, n, A)
        d = getRawData(obj)
        setRawData(obj,d)
        d = getRaw3DData(obj)
    end
    methods
        %dimensions
        function dimxy = getDimXY(obj)
           dimxy = obj.dimy*obj.dimx; 
        end
        function dimx = getDimX(obj)
            dimx = obj.dimx;
        end
        function dimy = getDimY(obj)
            dimy = obj.dimy;
        end
        function d = getDim(obj)
            d = [obj.dimy obj.dimx];
        end
        % indexing
        function p = getPixelIndex(o, x, y)
            % not yet tested, please test
            p = sub2ind(o.getDim(), y, x);
        end
        function [x, y] = getPixelXY(o, d)
            % not yet tested, please test
            [y, x] = ind2sub(o.getDim(), d);
        end
        % Image Structure / access
        function nImages = getNImages(obj)
            nImages = obj.nImages;
        end
        
        function s = getPixelSeries(o, x, y)
            % xxx not yet Implemented
        end
        
        function ISout = deleteImages(o, condition)
            % @todo implement emptiness
            n = o.getNImages();
            out = false(n,1);
            for iImage = 1:n
                out(iImage)=condition(o.getImage(iImage));
            end
            ISout = ImageSet(sum(out), o.getDimX(), o.getDimY());
            ISout.setRawData(o.getRawData(out,:));
        end
        
        %%% operations
        
        % general
        function everyPixel(o, func)
            % applies array = func(array) on every pixel series
            d = o.getRawData();
            for iPixel = 1:size(d,2)
                d(:, iPixel) = func(d(:, iPixel));
            end
            o.setRawData(d);
        end
        
        function everyImage(o, func)
            % applies Image=func(Image) on every image in set
            for iImage = 1:o.getNImages()
               o.setImage(iImage,func(o.getImage(iImage)));
            end
        end
        
        
        % Normalization
        function normalizePixels(o)
            % normalizes Pixels
            d = o.getRawData();
            m = sum(d,2);
            for i=1:numel(m)
                d(:,i) = d(:,i)/m(i);
            end
            o.setRawData(d);
        end
        
        function normalizeImages(o)
            divisor = repmat(o.getIntegrals(), [1,o.getDimXY()]);
            o.setRawData(o.getRawData()./divisor);
        end
        
        
        % transformations
        
        % every single pixels
        function lowerBound(o, b, varargin)
            % set all values below lower bound to x
            if nargin == 3
                x = varargin;
            else
                x = 0;
            end
            d = o.getRawData();
            d(d<b) = x;
            o.setRawData(d);
        end
        
        % every pixel set
        function [fftamp,fftarg, f] = fft(o, t, NFFT)
            % @todo implement emptiness
            %assumes Times to be equidistant
            if isnumeric(t(2)) && isnumeric(t(1))
                if nargin <= 2
                    N = numel(t);
                    NFFT = 2^nextpow2(N);
                end
                
                dt = t(2)-t(1);
                temp = fft(o.images, NFFT)/NFFT;
                fftamp = ImageSet(2*abs(temp(1:NFFT/2+1,:)), o.dimx);
                fftarg = ImageSet(angle(temp(1:NFFT/2+1,:)), o.dimx);
                f = linspace(0,0.5/dt,NFFT/2+1);
            else
                fftamp = NaN;
                fftarg = NaN;
                f = NaN;
            end
        end
        
        function fourierFilter(o,t,f_min, f_max)
            % @todo implement emptiness
            dt = t(2)-t(1);
            N = numel(t);
            f = linspace(-0.5/dt,0.5/dt,N);
            transform = fft(o.images);
            transform = fftshift(transform);
            transform(abs(f)<f_max,:) = 0;
            transform(abs(f)>f_min,:) = 0;
            transform = ifftshift(transform);
            o.images = abs(ifft(transform));
            
            % Filter
            L = 257;    % filter length
            fc = 600;   % cutoff frequency
            hsupp = (-(L-1)/2:(L-1)/2);
            hideal = (2*fc/dt)*sinc(2*fc*hsupp/dt); %% BR and NF : replaced Fs with dt
            h = hamming(L)' .* hideal; % h is our filter
            
            % Choose the next power of 2 greater than L+M-1
            Nfft = 2^(ceil(log2(L+M-1))); % or 2^nextpow2(L+M-1)

            % Zero pad the signal and impulse response:
            xzp = [ x zeros(1,Nfft-M) ];
            hzp = [ h zeros(1,Nfft-L) ];

        end
        
        % every Image
        function divide(o, image)
            divisor = repmat(image.vector(), [o.getNImages(),1]);
            o.setRawData(o.getRawData()./divisor);
        end
        
        function filter(o, f)
            % @todo implement emptiness
            for iImage = 1:o.getNImages()
               o.setImage(iImage, Image(imfilter(o.getImage(iImage).matrix(),f)));
            end
        end
        
        function applyMask(o, mask)
            % @todo implement emptiness
            for iImage = 1:o.getNImages()
               o.setImage(iImage, Image(o.getImage(iImage).matrix().*mask));
            end
        end

        % whole set
        function append(o, appObj)
            % @todo check how this works when starting with an empty set [DONE]
            if o.nImages > 0
                assert((o.dimx == appObj.dimx && o.dimy == appObj.dimy), 'Two ImageSets with different x and y dimensions can''t be appended.\n');
            else
                o.dimx = appObj.dimx;
                o.dimy = appObj.dimy;
                o.dimxy = appObj.dimxy;
            end
            o.images = cat(1,o.images,appObj.images);
            o.nImages = size(o.images,1);
        end
        
        % function to empty the whole set
        function clear(o)
            o.dimx = 0;
            o.dimy = 0;
            o.dimxy = 0;
            o.images = [];
            o.nImages = 0;
        end
        
        %%% extracted Values
        
        % value statistics
        
        % range
        
        function clims = get_x_sigma_scale(o, x)
            % @todo implement emptiness
            d = o.getRawData();
            sigma = std(d(:));
            m = mean(d(:));
            clims = [ m-x*sigma m+x*sigma ];
        end
        
        function clims = get_quantile_scale(o, p)
            % @todo implement emptiness
            d = o.getRawData();
            clims = quantile(d(:), [p 1-p]);
        end
        
        function clims = get_quantile_scale_randomPixels(o, p, n)
            % @todo implement emptiness
            d = o.getRawData();
            r= randi(n, size(d));
            clims = quantile(d(r), [p 1-p]);
        end
        
        function clims = get_quantile_scale_randomPixels_indvShots(o, p, n)
            % @todo implement emptiness
            n = o.getNImages();
            temp = zeros(n, 2);
            for iImage = 1:n
                r = randi(n, [1 o.getDimXY()]);
                temp(iImage,:) = quantile(o.getImage(iImage).vector(), [p 1-p]);
            end
            clims = [min(temp(:,1)) max(temp(:,2))];
        end
        
        function clims = get_quantile_scale_indv_shots(o, p)
            % @todo implement emptiness
            n = o.getNImages();
            temp = zeros(n, 2);
            for iImage = 1:n
                temp(iImage,:) = quantile(o.getImage(iImage).vector(), [p 1-p]);
            end
            clims = [min(temp(:,1)) max(temp(:,2))];
        end
        
        % Get the sum of all pixels for each image
        % @input void
        % @output vector of length nImages with the summed pixel values
        function int = getIntegrals(o)
            % @todo implement emptiness
            int = sum(o.getRawData(),2);
        end
        
                % Get the sum of all pixels for each image
        % @input void
        % @output vector of length nImages with the summed pixel values
        function int = getRowSum(o)
            % @todo implement emptiness
            int = sum(o.matrix(),2);
        end
        
        function out = mean(o)
            % @todo implement emptiness
            out = Image(mean(o.getRawData(), 1), o.getDimX());
        end
        
        function ret = centerOfMass(o, varargin)
            % @todo implement emptiness
            img = o.mean();
            d = img.matrix();
            if nargin == 1
                [y, x] = ndgrid(1:o.dimy, 1:o.dimx);
                ret = [sum(sum(x.*d)); sum(sum(y.*d))]/sum(sum(d(:)));
            elseif nargin == 2
                cutoff = varargin{1};
                mask = d>cutoff;
                [y, x] = ndgrid(1:o.dimy, 1:o.dimx);
                y = y(mask);
                x = x(mask);
                ret = [sum(sum(x.*d(mask))); sum(sum(y.*d(mask)))]/(sum(sum(d(mask))));
            end
        end

        
        % (sub) set extraction
        
        %returns averaged imageset, ids to the parameters and unique
        %parameters (p)
        function [isout, ids, p] = average(o, parameter)
            % @todo implement emptiness
            % if there are several parameters and they all need to be
            % unique use the 'rows' option
            if ismatrix(parameter) && size(parameter,1) > 1 && size(parameter,2) > 1 && ~iscell(parameter)
                [p ia ic] = unique(parameter, 'rows','stable');
            else
                [p ia ic] = unique(parameter,'stable');
            end
            o.nImages = numel(ia);
            isout = ImageSet(o.nImages, o.getDimX(), o.getDimY());
            % Average all the images with the same parameters
            for iAvgIm=1:o.nImages
                match = ic==iAvgIm;
                % careful here xxx
                sel = o.images(match,:);
                img = mean(sel,1);
                img = Image(img, o.getDimX(), o.getDimY());
                isout.setImage(iAvgIm, img);
            end
            ids = ia;
        end
        
        function croppedIS = crop(o, rect, debug)
            % @todo implement emptiness (not sure it is fully necessary)
            % this could be speeded up by acting on bulk matrix
            % which can get tricky when using masked Image Sets
            rect = round(rect);
            dimx = rect(3);
            dimy = rect(4);
            %croppedIS = (class(o))(o.getNImages(), dimx, dimy);
            croppedIS = copy(o);
            croppedIS.images = [];
            for iImage = 1:o.getNImages
                m = o.getImage(iImage).matrix;
                croppedIS.setImage(iImage,Image(m(rect(2):(rect(2)+rect(4)-1),rect(1):(rect(1)+rect(3)-1))));
                croppedIS.dimx = dimx;
                croppedIS.dimy = dimy;
                croppedIS.dimxy = dimx*dimy;
            end
        end
        
        function subIS = subset(o, ids)
            if isa(ids, 'logical')
                d = o.getRawData();
                subIS = ImageSet(d(ids,:), o.getDimX());
            elseif isa(ids, 'numeric')
                d = o.getRawData();
                subIS = ImageSet(d(ids,:), o.getDimX());
            else
                error('Not yet implemented for other than logical ids');
            end
        end
        
        function IS = extractSubSet(o, ids)
            if isa(ids, 'logical') || isa(ids, 'numeric')
                IS = copy(o);
                IS.images = IS.images(ids,:);
                IS.nImages = size(IS.images,1);
            else
                error('Not yet implemented for other than logical ids');
            end
        end
        
        % Function that adds an element to the end of the set and removes
        % the first element
        function error = queue(o, IS)
            % @todo implement emptiness
            % @todo extend this to allow for queuing of objects that have
            % more that 1 element
            if o.dimx ~= IS.dimx || o.dimy ~= IS.dimy
                error = true;
            else
                o.images = circshift(o.images,-1,1);
                o.images(o.nImages,:) = IS.images(1,:);
                error = false;
            end
        end
                
        %%% GUI
        function [f, isf] = show(o)
            % @todo implement emptiness
            isf = ImageSetFigure(o);
            f = isf.create();
        end
        
        function renderVideo(o, filename)
            % @todo implement emptiness
            vidObj = VideoWriter([filename '.avi'], 'Uncompressed AVI');
            vidObj.FrameRate = 5;
            open(vidObj);
            isf = ImageSetFigure(o);
            isf.allowPixelSelect = false;
            f = isf.create();
            for i=1:o.getNImages()
                writeVideo(vidObj,getframe);
                isf.onNextShot();
            end;
            close(vidObj);
            isf.delete();
        end
        
        % files
        
        
        %%% helper functions (do only refer to number and dimensionallity)
        
        

    end
    methods(Static)
        function IS = load(filenames)
            if iscellstr(filenames)
                % Load several files
                nFiles =numel(filenames);
                imgs(nFiles) = Image();
                for iFile = 1:nFiles;
                    % if ~mod(iFile, 10), disp(iFile); end;
                    imgs(iFile) = Image(single(uint16(imread(filenames{iFile}))));
                end
                % xxx check if all could be loaded else skipp (all are same
                % res)
                
                data = NaN(nFiles, imgs(1).getDimXY(), 'single');
                for iFile = 1:nFiles;
                   data(iFile, :) = imgs(iFile).vector();
                end
                IS = ImageSet(data, imgs(1).getDimX());
                % IS = ImageSet(data);
            elseif ischar(filenames)
                % Only load one file
                imgs(1) = Image(single(uint16(imread(filenames))));
                data = NaN(1, imgs(1).getDimXY(), 'single');
                data(1, :) = imgs(1).vector();
                IS = ImageSet(data, imgs(1).getDimX());
                % IS = ImageSet(data);
            end
        end
        
        %% Function to join ImageSets
        % @returns an ImageSet with all ImageSets combined
        % @input each input a ImageSet that needs to be joined or an array
        % of ImageSets
        function IS = join(varargin)
            % Check the number of inputs
            switch nargin
                case 0
                    error('Not enough inputs');
                case 1
                    % Input is an array of ImageSets
                    if size(varargin{1},1) > 1
                        IS = copy(varargin{1,1});
                        for iArg = 2:nargin
                            IS.append(varargin{1,iArg});
                        end
                    end
                otherwise
                    % Input are ImageSets
                    IS = copy(varargin{1});
                    for iArg = 2:nargin
                        IS.append(varargin{iArg});
                    end
            end
        end
    end
    
end

