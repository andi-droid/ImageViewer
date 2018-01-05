classdef Image < matlab.mixin.Copyable
    properties
        data
        dimx
        dimy
    end
    
    methods
        function obj = Image(varargin)
            switch nargin
                case 0
                case 1
                    if strcmp(class(varargin{1}), 'Image')
                        obj = copy(varargin{1});
                    elseif isnumeric(varargin{1}) || islogical(varargin{1})
                        obj.data = varargin{1};
                        obj.dimx = size(obj.data, 2);
                        obj.dimy = size(obj.data, 1);
                    else
                        error('Needs to be initialized with Image or Matrix');    
                    end
                case 2,
                    if(numel(varargin{1})>1)
                        image = varargin{1};
                        obj.dimx  = varargin{2};
                        obj.dimy = numel(image)/obj.dimx;
                        obj.data = reshape(image(:), obj.dimy, obj.dimx);
                    else
                        obj.dimx = varargin{1};
                        obj.dimy = varargin{2};
                        obj.data = zeros(obj.dimy, obj.dimx);
                    end
                case 3
                    image = varargin{1};
                    obj.dimx = varargin{2};
                    obj.dimy = varargin{3};
                    if isnumeric(image) && isnumeric(obj.dimx) && isnumeric(obj.dimy)
                        if numel(image) == obj.dimx*obj.dimy
                            obj.data = reshape(image(:), obj.dimy, obj.dimx);
                        else
                            error('dimx*dimy != numel(arg1)');
                        end
                    else
                    end
                    %implement vector, plus dimx, dimy
                    %reshape(obj.images(n,:), obj.dimy, obj.dimx);
                otherwise
                    error('Need 0, 1 or 3 contructor arguments');
            end
        end
        % basic image properties
        function dimxy = getDimXY(obj) 
            dimxy = obj.dimy*obj.dimx;
        end
        function dimx = getDimX(obj)
            dimx = obj.dimx;
        end
        function dimy = getDimY(obj)
            dimy = obj.dimy;
        end 
        function dim = getDim(o)
           dim = size(o.data); 
        end
        
        % access
        function img = vector(obj)
            img = obj.data(:);
        end
        
        function img = matrix(obj)
            img = obj.data;
        end
        
        % derived values
        function ret = abs(obj)
            ret = abs(sum(obj.data(:)));
        end
        
        function ret = centerOfMass(o, varargin)
            if nargin == 1
                [y, x] = ndgrid(1:o.dimy, 1:o.dimx);
                ret = [sum(sum(x.*o.data)); sum(sum(y.*o.data))]/o.abs();
            elseif nargin == 2
                cutoff = varargin{1};
                mask = o.data>cutoff;
                [y, x] = ndgrid(1:o.dimy, 1:o.dimx);
                y = y(mask);
                x = x(mask);
                ret = [sum(sum(x.*o.data(mask))); sum(sum(y.*o.data(mask)))]/(sum(sum(o.data(mask))));
            end
        end
        
        function clims = get_x_sigma_scale(o, x)
            sigma = std(o.vector());
            m = mean(o.vector());
            if sigma == 0
                sigma = x/10000;
            end
            clims = [ m-x*sigma m+x*sigma ];
        end
        function clims = get_quantile_scale(o, p)
                clims = quantile(o.vector(), [p 1-p]);
        end
        
        function [imgAmp imgArg]  = fft(o)
            F = fft2(o.matrix());
            F = fftshift(F); % Center FFT
            imgAmp = Image(abs(F));
            imgArg = Image(angle(F));
            % scaling, frequency limits?
        end
        
        % GUI
        function show(obj)
            f = figure();
            a = axes(...
                        'Parent',f,...
                        'Units', 'normalized',...
                        'Position', [0,0,1,1],...
                        'Box', 'on',...
                        'DataAspectRatio', [1 1 1]);
            imagesc(obj.data, 'Parent', a);
            set(a, 'DataAspectRatio', [1 1 1]);
        end
                
        function showInAxes(obj, a)
            imagesc(obj.data, 'Parent', a);
            set(a, 'DataAspectRatio', [1 1 1]);
        end
    end
    methods(Static)
        function cropped = crop(im, rect)
            %cropped = Image(im.data(rect(2):rect(4), rect(1):rect(3)));
            cropped = Image(im.data(rect(2):(rect(2)+rect(4)-1),rect(1):(rect(1)+rect(3)-1)));
        end
        
        function mask = maskFromRect(rect, dimx, dimy)
            mask = false(dimy, dimx);
            mask(rect(2):(rect(2)+rect(4)-1),rect(1):(rect(1)+rect(3)-1)) = true;
        end
        
        function img = OD(ref, atoms)
            %OD_korr = (1+ 4.*(Detuning.^2/Gamma.^2)).*reallog(Bild_noatoms_korr./max(1,Bild_atoms_korr)) + (Bild_noatoms_korr-Bild_atoms_korr).*CountToInt/ISat;
            img = Image(reallog(max(0.001, ref.matrix())./...
                max(0.001, atoms.matrix())));
        end
        
    end
    
end

