classdef ImageSet < ImageSetInterface
    properties
         
    end
    
    methods
        function obj = ImageSet(varargin)
            switch nargin
                case 0,
                case 1
                    img = varargin{1};
                    if isa(img, 'Image')
                        obj = ImageSet(1, img.getDimX(), img.getDimY());
                        obj.setImage(1, img);
                    elseif isa(img, 'ImageSet')
                        %obj = copy(img); %does not work for some
                        % reason, when calle by subclass. then obj becomes
                        % of type subclss
                        %obj = ImageSet(img.nImages, img.dimx, img.dimy, img.images);
                        % constructor seems to be unable to call
                        % constructor
                        obj.nImages = img.nImages;
                        obj.dimx = img.dimx;
                        obj.dimy = img.dimy;
                        obj.images = img.images;
                    elseif isnumeric(img) || ndims(img) == 4
                        % Assume dimensions as (iImage, iY, iX);
                        obj.dimx = size(img,3);
                        obj.dimy = size(img,2);
                        obj.nImages = size(img,1);
                        obj.images = reshape(img, obj.nImages, obj.dimx*obj.dimy);
                        
                    else
                        error('Could not initialize ImageSet, with one parameter');
                    end
                case 2,     [obj.images, obj.dimx]  = varargin{:};
                            obj.nImages = size(obj.images, 1);
                            obj.dimy = size(obj.images,2)/obj.dimx;
                case 3,     [obj.nImages, obj.dimx, obj.dimy]  = varargin{:};
                            obj.images = zeros([obj.nImages, obj.dimx*obj.dimy],'single');
                case 4,     [obj.nImages, obj.dimx, obj.dimy, obj.images]  = varargin{:};
                otherwise,  error('Error initializing ImageSet');
            end
        end
        
        % loading
        function loadblueroo(obj)
            [allframedata, map] = imread('../PCA/imseries/1138436.png', 'frames', 'all');
            I = im2double(squeeze(allframedata(:,:,:,:)));
            I = shiftdim(I,2);
            obj.nImages = size(I,1);
            obj.dimy = size(I,2);
            obj.dimx = size(I,3);
            obj.images = zeros(obj.nImages, obj.dimy*obj.dimx);
            obj.images(:) = I(:,:);
        end
        function loadone(obj, n)
            I = im2double(rgb2gray(imread('C:/Users/Dominik/Desktop/temp/team640x480.jpg')));
            [obj.dimy obj.dimx]  = size(I);
            obj.nImages = n;
            obj.images = zeros([n, obj.dimx*obj.dimy]);
            for i=1:n
                obj.images(i,:) = single(I(:));
            end
        end
        function loadNumbered(obj)
            path = '../Media/';
            names={'01.jpg', '02.jpg', '03.jpg', '04.jpg','05.jpg'};
            obj.nImages = size(names,2);
            I = im2double(rgb2gray(imread([path names{1}])));
            [obj.dimy obj.dimx]  = size(I);
            obj.images = zeros([obj.nImages, obj.dimx*obj.dimy]);
            for iFile = 1:obj.nImages
                disp(iFile)
                I = im2double(rgb2gray(imread([path names{iFile}])));
                obj.images(iFile,:) = single(I(:));
            end
            
        end
        function loadmany(obj)
            path = 'C:/Users/Dominik/Desktop/temp/';
            obj.nImages = 557;
            obj.dimy = 480;
            obj.dimx = 640;
            obj.images = zeros([obj.nImages, obj.dimx*obj.dimy]);
            for iFile = 1:obj.nImages
                fprintf('%simage%03d\n.jpg',path,iFile);
                I = imread(sprintf('%simage%03d.jpg',path,iFile));
                I = rgb2gray(I);
                I = im2double(I);
                obj.images(iFile,:) = single(I(:));
            end
        end
        % generating
        function createFullCanonicalBasis(obj, dimx, dimy)
            obj.dimx = dimx;
            obj.dimy = dimy;
            obj.nImages = dimx*dimy;
            obj.images = eye(obj.nImages);
        end
        
        function createCosineBasis(obj,imageSizeX, imageSizeY, baseCountX, baseCountY)
            obj.dimx = imageSizeX;
            obj.dimy = imageSizeY;
            obj.nImages = baseCountX*baseCountY;
            obj.images = zeros(obj.nImages, obj.dimx*obj.dimy);
            function v = basis(m, x, N)
                v = 1/sqrt(N)*cos(2*pi*(x)*(m-1)/2);
            end
            for iX = 1:baseCountX
                for iY = 1:baseCountY
                    x = basis(iX,linspace(0,1,obj.dimx), baseCountX);
                    y = basis(iY,linspace(0,1,obj.dimy), baseCountY);
                    obj.setImageMatrix((iY-1)*baseCountX+iX, kron(x,y'));
                end
            end
        end
        
        % dimension changing transform
        
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
        
        % Testcode:
%         resh = reshape(phis, 19, dimy, dimx);
%         img = Image(squeeze(resh(1,:,:)));
%         img.show
        function d  = getRaw3DData(obj)
        % returns 3d array: (iImage, iY, iX)
            d = reshape(obj.images, obj.getNImages(), obj.getDimY(), obj.getDimX());
        end
        
        function deleteImage(obj, n)
            obj.images(n,:) = [];
            obj.nImages = size(obj.images,1);
        end
        
    end
    
    methods(Static)
%         function IS = load(filenames)
%             if iscellstr(filenames)
%                 % Load several files
%                 nFiles =numel(filenames);
%                 imgs(nFiles) = Image();
%                 for iFile = 1:nFiles;
%                     % if ~mod(iFile, 10), disp(iFile); end;
%                     imgs(iFile) = Image(single(uint16(imread(filenames{iFile}))));
%                 end
%                 % xxx check if all could be loaded else skipp (all are same
%                 % res)
%                 
%                 data = NaN(nFiles, imgs(1).getDimXY(), 'single');
%                 for iFile = 1:nFiles;
%                    data(iFile, :) = imgs(iFile).vector();
%                 end
%                 IS = ImageSet(data, imgs(1).getDimX());
%                 % IS = ImageSet(data);
%             elseif ischar(filenames)
%                 % Only load one file
%                 imgs(1) = Image(single(uint16(imread(filenames))));
%                 data = NaN(1, imgs(1).getDimXY(), 'single');
%                 data(1, :) = imgs(1).vector();
%                 IS = ImageSet(data, imgs(1).getDimX());
%                 % IS = ImageSet(data);
%             end
%         end


    end
end

