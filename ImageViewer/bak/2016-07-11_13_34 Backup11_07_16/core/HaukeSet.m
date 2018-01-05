classdef HaukeSet < matlab.mixin.Copyable
    % design decision: The parameters that belong to the HaukeSet are
    % saved externally
    properties(Constant)
        paramNames = {'offset','amp1','damp1','pha1','fre1'};
        paramNamesExt = {'offset','amp1','damp1','pha1','fre1', 'resnorm', 'exitFlag','iterations'};
    end
    properties
        % (haukeTime, pixY, pixX) -> hauke time first for
        % access to pixel data via (iTime,:)
        imageData
        times
        % atomCount(iTime)
        atomCount
        % (frequency, pixY, pixX)
        fftA % Amplitude
        fftP % phase
        fftF % frequency
        
        fftA3 % Amplitude
        fftP3 % phase
        fftF3 % frequency
        % structure of results same as 'display' in fit
        fitResults
        fitOptions
        fitFunction
        filterOptions
        
        info
        interpolated = false
    end
    
    methods
        function  o = HaukeSet()
            o.fitOptions = optimset('MaxFunEvals',1000,'TolFun',1e-8,'MaxIter',1000,'TolX',1E-8,'display','none');
            o.fitFunction = @(p,x) p(1)*(1+p(2).*exp(-p(3).*x).*sin(p(4)+2*pi*p(5)*x));
        end
        
        function filter(o, fo, varargin)
            o.filterOptions = varargin;
            p = inputParser;
            p.addOptional('smoothing', 0, @isnumeric);
            p.addOptional('fastSmooth', 0, @isnumeric);
            p.addOptional('fftCutoff', 0, @isnumeric);
            p.parse(varargin{:});
                                    
            % spatial filtering
            if ~isempty(p.Results.smoothing)
	        if (p.Results.smoothing > 0)
		        smoothing = p.Results.smoothing;
		        f = fspecial('gaussian',[smoothing smoothing],smoothing);
		        for iImage=1:size(o.imageData,1)
		            o.imageData(iImage,:,:) = ...
		                imfilter(squeeze(o.imageData(iImage,:,:)), f);
		        end
		end
            end
         

            % temporal filtering
            
            % fastsmooth
            if ~isempty(p.Results.fastSmooth)
		if p.Results.fastSmooth > 1
		        for iy=1:size(o.imageData,2)
		            for ix=1:size(o.imageData,3)
		                o.imageData(:,iy, ix) = fastsmooth( ...
		                    shiftdim(o.imageData(:,iy, ix)), p.Results.fastSmooth);
		            end
		        end
		end
            end
            
            % fourier component cutof
	    if p.Results.fftCutoff > 0
                ht = o.times;
                N = numel(ht);
                NFFT = N;
                dt = ht(2)-ht(1);
                nComp = p.Results.fftCutoff;
                for iy=1:size(o.imageData,2)
                    for ix=1:size(o.imageData,3)
                        fftVals = fft(o.imageData(:,iy, ix), NFFT)/NFFT;
                        fftVals(nComp:(end-nComp))=0;
                        o.imageData(:,iy, ix) = real(ifft(fftVals, NFFT)*NFFT);
                    end
                end
            end
                
                
            if ~isempty(fo)
                bpFilt = designfilt(fo{:}, ...
                          'SampleRate',1/(o.times(2)-o.times(1)));
                for iy=1:size(o.imageData,2)
                    for ix=1:size(o.imageData,3)                    
                        o.imageData(:,iy, ix) = ...
                            filtfilt(bpFilt, o.imageData(:,iy, ix));
                    end
                end
            end
          
        end
        
        function reduceFFT(o)
            o.fftA3 = o.fftA(3,:,:); % Amplitude
            o.fftP3 = o.fftP(3,:,:);% phase
            o.fftF3 = o.fftF(3);% frequency
            % delete ffts and images
            o.fftA = [];
            o.fftP = [];
            o.fftF = [];
            o.imageData = [];
        end
        
        function tt = getNonNormalizedTimeTrace(o, ix, iy)
            tt = squeeze(o.imageData(:,iy, ix)).*o.atomCount;
        end
        
        function ret = getfftA(o, component)
            if isempty(o.fftA)
                ret = squeeze(o.fftA3);
            else
                ret = squeeze(o.fftA(component,:,:));
            end
        end
        
         function ret = getfftP(o, component)
            if isempty(o.fftP)
                ret = squeeze(o.fftP3);
            else
                ret = squeeze(o.fftP(component,:,:));
            end
         end
        
          function ret = getfftF(o, component)
            if isempty(o.fftF)
                ret = o.fftF3;
            else
                ret = o.fftF(component);
            end
          end
        
         
        function createFFTs(o, N)
            %p = floor((numel(o.times)-1)/4);
            %selection = 1:4:4*p+1;
            %is = ImageSet(o.imageData(selection, :, :));
            is = ImageSet(o.imageData);
            %[fftamp,fftarg, f] = is.fft(o.times(selection));
            if nargin > 1
                [fftamp,fftarg, f] = is.fft(o.times, N);
            else
                [fftamp,fftarg, f] = is.fft(o.times);
            end
            o.fftA = fftamp.getRaw3DData();
            o.fftP = fftarg.getRaw3DData();
            o.fftF = f;
        end
        
        function normalizeFFTs(o)
            is = ImageSet(o.fftA);
            is.normalizeImages;
            o.fftA = is.getRaw3DData();
        end
        
        
        % fit related functions
        function [p, upperBound, lowerBound] = startParams(o, x,y)
%             p.offset = abs(nanmean(o.imageData(:,y,x),1));
%             p.amp1 = 0.5*(nanmax(o.imageData(:,y,x))-nanmin(o.imageData(:,y,x)))/p.offset;
%             p.damp1 = 1e-7;
%             p.pha1=(o.imageData(1,y,x)>p.offset)*pi-pi/2;
%             p.fre1=11.9e3;        

            p.offset = 0.5*o.fftA(1, y,x);
            p.amp1 = 2*o.fftA(3, y,x)/p.offset;
            p.damp1 = 0;
            p.pha1= o.fftP(3, y,x)+pi/2;
            p.fre1=o.fftF(3);          
            
            lowerBound.offset = p.offset*0.7;
            lowerBound.amp1 = p.amp1*0.7;
            lowerBound.damp1 = 0;
            lowerBound.pha1= -inf;
            lowerBound.fre1= 0e3;          %11.5e3;
            
            upperBound.offset = p.offset*1.3;
            upperBound.amp1 = p.amp1*1.3;
            upperBound.damp1 = 7e-7;
            upperBound.pha1= inf;
            upperBound.fre1= 34e3;          %12.5e3;
        end
        
        function [p, resnorm, exitFlag, iterations] =...
                fitPixel(o, x,y)
            
                trace = o.imageData(:, y,x);
                [pInit, upperBound, lowerBound] = o.startParams(x,y);
                pInit = struct2array(pInit);
                upperBound = struct2array(upperBound);
                lowerBound = struct2array(lowerBound);
                [p, resnorm, ~,exitFlag, output] = lsqcurvefit(...
                                o.fitFunction,...
                                pInit,...
                                o.times', trace,...
                                lowerBound, upperBound,...
                                o.fitOptions);
                iterations = output.iterations;
                p(4) = mod(p(4)+pi, 2*pi)-pi;
         
        end
        function f = timeTraceFromParameters(o, p)
            f = o.fitFunction(p, o.times);
        end
        
        function fitSet(o, center)
            % do the fit
            dimy = size(o.imageData, 2);
            dimx = size(o.imageData, 3);
            mask = uZoneMask(1,dimy,dimx,center(2),center(1), 58*2,1);
            p = NaN(numel(o.paramNames), dimy, dimx);
            resnorm = NaN(dimy, dimx);
            exitFlag = NaN(dimy, dimx);
            iterations = NaN(dimy, dimx);
            parfor iX=1:dimx
                for iY=1:dimy
                   if mask(iY,iX)
                    %if true
                        [p(:,iY,iX), resnorm(iY,iX), exitFlag(iY,iX), iterations(iY,iX)] = o.fitPixel(iX, iY);
                    end
                end
            end
            
            % save results
            o.fitResults.resnorm = resnorm;
            o.fitResults.exitFlag = exitFlag;
            o.fitResults.iterations = iterations;
            
            for iParam = 1:numel(o.paramNames)
                o.fitResults.(o.paramNames{iParam}) = squeeze(p(iParam,:,:));
            end    
        end
    end
    
end

