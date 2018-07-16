 classdef GeneralFitFunctions %< FitFigure
    % SinusFits a class that allows to fit data with different types of
    % sine functions
    properties
        type
        fitFunction
        fitFunctionName
        startParams
        lowerBound
        upperBound
        paramNames
        xdata
        ydata
        startfreq
    end
    
    methods
        % The constructor
        % @input type is the type of sine function (DampedSinus, Sinus, TwoSinus)
        % @returns object of type SinusFit
        function o = GeneralFitFunctions(type,xdata,ydata)
            o.type = type;
            o.xdata = xdata;
            o.ydata = ydata;


            if strcmp(o.type, 'Sinus')
                o.fitFunctionName = 'Sinus';
                [ymax xmax] = max(o.ydata);
                [ymin xmin] = min(o.ydata);
                o.startfreq = 1./(abs(o.xdata(xmax)-o.xdata(xmin))*2);
                o.fitFunction = @(p,x) p(1)+p(2).*exp(-p(3).*x).*sin(p(4)+2*pi*p(5)*x);
                
                o.paramNames =         {    'offset',   'amp1',       'damp1',     'pha1',   'fre1'};
                
                o.startParams = double([    mean(o.ydata);     max(o.ydata)./2-min(o.ydata)./2;   0; 0;  o.startfreq]);
                o.lowerBound  = double([0; 0.0;      0;   -(2*pi+0.05);   o.startfreq./5]);
                o.upperBound  = double([max(o.ydata); 2*max(o.ydata);   4E-2;    (2*pi+0.05);   5*o.startfreq]);

                
            elseif strcmp(o.type, 'Gauss')              
                o.fitFunctionName = 'Gauss';
                o.fitFunction = @(p,x) p(1)+p(2)*exp(-((x-p(3))./(sqrt(2)*p(4))).^2);
                
                o.paramNames =         {'offset',   'amp1',   'res1',   'sig1'   };
                
                [ymax,ymaxind] = max(o.ydata);
                
                o.startParams = double([     mean(o.ydata);   ymax;  o.xdata(ymaxind) ;  mean(o.xdata)./100]);
                o.lowerBound  = double([    0;   0;      0;   0 ]);
                o.upperBound  = double([     max(o.ydata);    3*max(o.ydata);  max(o.xdata);  mean(o.xdata) ]);
                
                elseif strcmp(o.type, 'Lorentz')              
                o.fitFunctionName = 'Lorentz';
                o.fitFunction = @(p,x) p(1)+p(2)./(p(2).^2+(x-p(3).^2));
                
                o.paramNames =         {'offset',   'amp1',   'res1'   };
                
                o.startParams = double([     mean(o.ydata);   mean(o.xdata)./10;  mean(o.xdata)]);
                o.lowerBound  = double([    0;   0; 0  ]);
                o.upperBound  = double([     max(o.ydata);    max(o.xdata);  max(o.xdata) ]);
                
                elseif strcmp(o.type, 'ToFFit')              
                o.fitFunctionName = 'ToFFit';
                o.fitFunction = @(p,x) sqrt(p(1).^2+p(2)*x.^2);
                
                o.paramNames =         {'sigma0',   'slope'   };
                
                o.startParams = double([     min(o.ydata);   (max(o.ydata)-min(o.ydata)/(max(o.xdata)-min(o.xdata))).^2]);
                o.lowerBound  = double([    0;   0 ]);
                o.upperBound  = double([     max(o.ydata);   inf ]);
            
            else
                error('fit function type unknown');
            end
        end
        
        % Initialise the fit start parameters, using special functions
        % @input void
        % @returns void
%         function initStartParams(o)
%             nPixel = o.imageSet.getDimXY();
%             U = ones(1,nPixel);
%             o.tmin=3;
%             o.tmax=numel(o.parameter)-3;
%             
%             o.offsets=abs(nanmean(double(o.imageSet.images(o.tmin:o.tmax,:)),1));
%             o.amplitudes=abs(0.5*(nanmax(double(o.imageSet.images(o.tmin:o.tmax,:)))-nanmin(double(o.imageSet.images(o.tmin:o.tmax,:))))./mean(double(o.imageSet.images(o.tmin:o.tmax,:)),1));
%             if 25>o.tmax
%                 [maxod time_of_maxod]=nanmax(double(o.imageSet.images(o.tmin:o.tmax,:)));
%                 [minod time_of_minod]=nanmin(double(o.imageSet.images(o.tmin:o.tmax,:)));
%             else
%                 [maxod time_of_maxod]=nanmax(double(o.imageSet.images(15:25,:)));
%                 [minod time_of_minod]=nanmin(double(o.imageSet.images(15:25,:)));
%             end
%             timedifferences=abs(o.parameter(time_of_maxod)-o.parameter(time_of_minod));
%             % o.frequencies=0.5./timedifferences';
%             o.frequencies=ones(1,nPixel).*17.75E-2;
%             %o.frequencies=ones(1,nPixel).*0.9E-2;
%             % load ('../Analysis/meanfreqs.mat') % Loading old previously used data
%             % o.frequencies=test;
%             for i=1:nPixel
%                 difference(i)=double(o.imageSet.images(1,i))-nanmean(double(o.imageSet.images(o.tmin:o.tmax,i)),1);
%             end
%             o.phases=difference>0;
%             o.phases=pi.*o.phases;
%             o.phases=o.phases-pi./2;
%             
%             
%             o.fitOptions = optimset('MaxFunEvals',20000,'TolFun',1e-16,'MaxIter',20000,'TolX',1E-16,'display' , 'none' );
%             
%             % Here the actual parameters are set
%             if strcmp(o.type, 'DampedSinus')
%                 o.startParams = double([    o.offsets;     0.7*o.amplitudes;   1E-2*U; o.phases;      o.frequencies;]);
%                 o.lowerBound  = double([0.7*o.offsets; 0.0*o.amplitudes;      0*U;   -(2*pi+0.05).*U;   10E-2.*U;]);
%                 o.upperBound  = double([1.3*o.offsets; 1.3*o.amplitudes;   4E-2*U;    (2*pi+0.05).*U;   24E-2.*U;]);
% 
%             elseif strcmp(o.type, 'DampedSinusfixedfreqanddamp')
%                 o.startParams = double([    o.offsets;     o.amplitudes; o.phases;]);
%                 o.lowerBound  = double([0.7*o.offsets; 0.7*o.amplitudes;   -(pi+0.05).*U;]);
%                 o.upperBound  = double([1.3*o.offsets; 1.3*o.amplitudes;    (pi+0.05).*U;]);
%             elseif strcmp(o.type, 'DampedSinusfixeddamp')
%                 o.startParams = double([    o.offsets;     o.amplitudes; o.phases;      o.frequencies;]);
%                 o.lowerBound  = double([0.7*o.offsets; 0.7*o.amplitudes;-(pi+0.05).*U;   11E-2.*U;]);
%                 o.upperBound  = double([1.3*o.offsets; 1.3*o.amplitudes;(pi+0.05).*U;   12.4E-2.*U;]);
%             elseif strcmp(o.type, 'DampedSinusfixedfreq')
%                 o.startParams = double([    o.offsets;     o.amplitudes;   1E-2*U; o.phases;]);
%                 o.lowerBound  = double([0.7*o.offsets; 0.7*o.amplitudes;      0*U;   -(pi+0.05).*U;]);
%                 o.upperBound  = double([1.3*o.offsets; 1.3*o.amplitudes;   4E-2*U;    (pi+0.05).*U;]);
% 
% 
%             elseif strcmp(o.type, 'Sinus')
%                 o.startParams = double([1.3E-4*U;     0.2*U;      0*U;     2.5E-2*U]);
%                 o.lowerBound  = double([     0*U;       0*U;    -pi*U;     0.0E-2*U]);
%                 o.upperBound  = double([  1E-3*U;       1*U;     pi*U;     9.0E-2*U]);
%             elseif strcmp(o.type, 'TwoSinus')
%                 o.startParams = double([  2E-2*U;     0.2*U;      0*U;     16.0E-2*U;  0.1*U;       0*U;    31.0E-2*U;  20*U]);
%                 o.lowerBound  = double([     0*U;       0*U;    -2*pi*U;     13.0E-2*U;   0.0*U;     -2*pi*U;    26.0E-2*U;  2*U]);
%                 o.upperBound  = double([  8E-2*U;       1*U;     2*pi*U;     20.0E-2*U;     1*U;      2*pi*U;    35.0E-2*U; 1000*U]);
%             elseif strcmp(o.type, 'ThreeSinus')
%                 o.startParams = double([  2E-2*U;     0.2*U;      0*U;     11.0E-2*U;  0.1*U;       0*U;    30.0E-2*U;  0.1*U;       0*U;    20*U]);
%                 o.lowerBound  = double([     0*U;       0*U;    -pi*U;     9.0E-2*U;   0.0*U;     -pi*U;    14.0E-2*U;  0.0*U;     -pi*U;   2*U]);
%                 o.upperBound  = double([  5E-2*U;       1*U;     pi*U;     14.0E-2*U;     1*U;      pi*U;    40.0E-2*U;  1*U;      pi*U;    1000*U]);
%             elseif strcmp(o.type, 'ThreeSinusV2')
%                 o.startParams = double([  2E-2*U;     0.2*U;      0*U;     18.0E-2*U;  0.1*U;       0*U;    30.0E-2*U;  0*U]);
%                 o.lowerBound  = double([     0*U;       0*U;    -2*pi*U;     16.0E-2*U;   0.0*U;     -2*pi*U;    14.0E-2*U; -pi*U]);
%                 o.upperBound  = double([  5E-2*U;       1*U;     2*pi*U;     20.0E-2*U;     1*U;      2*pi*U;    40.0E-2*U; pi*U]);
%             elseif strcmp(o.type, 'TwoSinus2')
%                 o.startParams = double([  2E-2*U;     0.2*U;      0*U;   0.1*U;       0*U]);
%                 o.lowerBound  = double([     0*U;       0*U;    -pi*U;   0.0*U;     -pi*U]);
%                 o.upperBound  = double([  5E-2*U;       1*U;     pi*U;   1*U;      pi*U]);
%             else
%                 error('fit function type unknown');
%             end
%         end
        
        
    end
    
end
